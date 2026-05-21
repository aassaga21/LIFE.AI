import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_ai/models/checkin_model.dart';
import 'package:life_ai/models/user_health_profile.dart';
import 'package:life_ai/services/ai/alert_engine.dart';
import 'package:life_ai/services/ai/recommendation_engine.dart';

/// Profil de test avec stress élevé et objectif réduction stress
UserHealthProfile _profileStresse({
  int stressLevel = 8,
  String activityLevel = 'sédentaire',
  List<String> goals = const ['Réduire le stress'],
}) =>
    UserHealthProfile(
      uid: 'test_uid',
      firstName: 'Test',
      lastName: 'User',
      email: 'test@test.com',
      profession: 'Dev',
      age: 30,
      height: 175,
      weight: 70,
      gender: 'Homme',
      sleepQuality: 5,
      stressLevel: stressLevel,
      activityLevel: activityLevel,
      goals: goals,
      subscription: 'FREE',
      createdAt: DateTime(2025, 1, 1),
    );

CheckIn _checkinWithStress(int stress, {int daysAgo = 0}) => CheckIn(
      id: 'rec_test_$daysAgo',
      uid: 'test_uid',
      date: DateTime.now().subtract(Duration(days: daysAgo)),
      humeur: 2,
      energie: 4,
      sommeil: 5,
      stress: stress,
    );

void main() {
  group('RecommendationEngine', () {
    late RecommendationEngine engine;

    setUp(() {
      // Mock SharedPreferences pour les tests
      SharedPreferences.setMockInitialValues({});
      engine = RecommendationEngine();
    });

    // ── Nombre minimum ────────────────────────────────────────────────────────

    test('retourne au minimum 3 recommandations', () async {
      final profile = _profileStresse();
      final recs = await engine.getRecommendations(
        profile: profile,
        recentCheckins: [],
        count: 5,
      );
      expect(recs.length, greaterThanOrEqualTo(3));
    });

    test('ne retourne pas plus de count recommandations', () async {
      final profile = _profileStresse();
      final recs = await engine.getRecommendations(
        profile: profile,
        recentCheckins: [],
        count: 3,
      );
      expect(recs.length, lessThanOrEqualTo(3));
    });

    // ── Alertes actives en priorité ───────────────────────────────────────────

    test(
        'recommandations liées aux alertes BURNOUT/STRESS en première position',
        () async {
      final profile = _profileStresse(stressLevel: 9);
      final checkins = List.generate(
          5, (i) => _checkinWithStress(8, daysAgo: i));
      final alerts = AlertEngine().analyzeCheckins(checkins, profile);

      // Il doit y avoir une alerte BURNOUT ou STRESS
      expect(
        alerts.any((a) =>
            a.type == AlertType.BURNOUT || a.type == AlertType.STRESS),
        isTrue,
      );

      final recs = await engine.getRecommendations(
        profile: profile,
        recentCheckins: checkins,
        activeAlerts: alerts,
        count: 5,
      );

      expect(recs.isNotEmpty, isTrue);
      // La première recommandation doit être liée au STRESS
      expect(
        recs.first.category,
        anyOf('STRESS', 'MINDFULNESS'),
        reason:
            'Avec une alerte BURNOUT active, STRESS doit être prioritaire',
      );
    });

    // ── Blacklist ─────────────────────────────────────────────────────────────

    test('blacklist exclut les recommandations ajoutées', () async {
      const recId = 'breathing_478';
      await engine.updateBlacklist('test_uid', recId);

      final profile = _profileStresse();
      final recs = await engine.getRecommendations(
        profile: profile,
        recentCheckins: [],
        count: 10,
      );

      expect(
        recs.any((r) => r.id == recId),
        isFalse,
        reason: '$recId doit être exclu car dans la blacklist',
      );
    });

    test('getBlacklist retourne les ids non expirés', () async {
      SharedPreferences.setMockInitialValues({});
      await engine.updateBlacklist('test_uid', 'rec_a');
      await engine.updateBlacklist('test_uid', 'rec_b');

      final bl = await engine.getBlacklist('test_uid');
      expect(bl, containsAll(['rec_a', 'rec_b']));
    });

    // ── Feedback ──────────────────────────────────────────────────────────────

    test('feedback négatif ajoute à la blacklist', () async {
      SharedPreferences.setMockInitialValues({});
      await engine.saveFeedback(
        uid: 'test_uid',
        recommendationId: 'hydration',
        isPositive: false,
      );
      // Firestore non mocké, mais la blacklist locale doit être mise à jour
      final bl = await engine.getBlacklist('test_uid');
      expect(bl, contains('hydration'));
    });

    // ── Scoring selon le profil ────────────────────────────────────────────────

    test(
        'profil sédentaire stressé → première catégorie STRESS ou ACTIVITÉ',
        () async {
      final profile = _profileStresse(
        stressLevel: 8,
        activityLevel: 'sédentaire',
        goals: ['Réduire le stress', 'Bouger davantage'],
      );
      final checkins = List.generate(
          3, (i) => _checkinWithStress(8, daysAgo: i));

      final recs = await engine.getRecommendations(
        profile: profile,
        recentCheckins: checkins,
        count: 5,
      );

      expect(recs.isNotEmpty, isTrue);
      expect(
        recs.first.category,
        anyOf('STRESS', 'ACTIVITÉ', 'MINDFULNESS'),
      );
    });

    test('recommandations de catégorie SOMMEIL avec faible sommeil', () async {
      final profile = UserHealthProfile(
        uid: 'test_uid',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@test.com',
        profession: '',
        age: 30,
        height: 175,
        weight: 70,
        gender: 'Autre',
        sleepQuality: 3, // mauvais sommeil
        stressLevel: 3,
        activityLevel: 'actif',
        goals: ['Améliorer le sommeil'],
        subscription: 'FREE',
        createdAt: DateTime(2025, 1, 1),
      );
      final checkins = List.generate(
          5,
          (i) => CheckIn(
                id: 'sleep_$i',
                uid: 'test_uid',
                date: DateTime.now().subtract(Duration(days: i)),
                humeur: 3,
                energie: 5,
                sommeil: 3, // sommeil faible
                stress: 3,
              ));

      final recs = await engine.getRecommendations(
        profile: profile,
        recentCheckins: checkins,
        count: 5,
      );

      expect(
        recs.any((r) => r.category == 'SOMMEIL'),
        isTrue,
        reason: 'Au moins une recommandation SOMMEIL attendue',
      );
    });
  });
}
