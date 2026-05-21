import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai/models/checkin_model.dart';
import 'package:life_ai/models/user_health_profile.dart';
import 'package:life_ai/services/ai/alert_engine.dart';

/// Profil utilisateur de test
final _testProfile = UserHealthProfile(
  uid: 'test_uid',
  firstName: 'Test',
  lastName: 'User',
  email: 'test@test.com',
  profession: 'Dev',
  age: 30,
  height: 175,
  weight: 70,
  gender: 'Homme',
  sleepQuality: 7,
  stressLevel: 4,
  activityLevel: 'modéré',
  goals: [],
  subscription: 'FREE',
  createdAt: DateTime(2025, 1, 1),
);

/// Crée un CheckIn pour la date d'il y a N jours
CheckIn _checkinDaysAgo(int daysAgo,
    {int stress = 5, int sommeil = 7, int energie = 6, int humeur = 3}) {
  return CheckIn(
    id: 'test_$daysAgo',
    uid: 'test_uid',
    date: DateTime.now().subtract(Duration(days: daysAgo)),
    humeur: humeur,
    energie: energie,
    sommeil: sommeil,
    stress: stress,
  );
}

void main() {
  final engine = AlertEngine();

  group('AlertEngine', () {
    // ── Règle BURNOUT ────────────────────────────────────────────────────────

    test('déclenche BURNOUT après 5 jours consécutifs de stress > 7', () {
      final checkins = List.generate(
          5, (i) => _checkinDaysAgo(i, stress: 8));
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) =>
            a.type == AlertType.BURNOUT &&
            a.level == AlertLevel.CRITICAL),
        isTrue,
        reason: 'Alerte BURNOUT CRITICAL attendue',
      );
    });

    test('ne déclenche PAS BURNOUT si seulement 4 jours de stress > 7', () {
      final checkins = [
        _checkinDaysAgo(0, stress: 8),
        _checkinDaysAgo(1, stress: 8),
        _checkinDaysAgo(2, stress: 8),
        _checkinDaysAgo(3, stress: 8),
        _checkinDaysAgo(4, stress: 3), // jour 4 : stress faible
      ];
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) => a.type == AlertType.BURNOUT),
        isFalse,
        reason: 'Pas d\'alerte BURNOUT attendue avec seulement 4 jours',
      );
    });

    test('ne déclenche PAS BURNOUT si 5 jours mais non consécutifs', () {
      // Jours 0, 1, 3, 4, 5 (trou au jour 2)
      final checkins = [
        _checkinDaysAgo(0, stress: 8),
        _checkinDaysAgo(1, stress: 8),
        _checkinDaysAgo(3, stress: 8), // pas de jour 2
        _checkinDaysAgo(4, stress: 8),
        _checkinDaysAgo(5, stress: 8),
      ];
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) => a.type == AlertType.BURNOUT),
        isFalse,
        reason: 'Les jours doivent être consécutifs',
      );
    });

    // ── Règle FATIGUE ────────────────────────────────────────────────────────

    test('déclenche FATIGUE après 3 jours consécutifs scoreFatigue > 60%', () {
      // scoreFatigue > 6.0/10 → stress=9, sommeil=2, energie=2, humeur=1
      final checkins = List.generate(
          3,
          (i) => _checkinDaysAgo(i,
              stress: 9, sommeil: 2, energie: 2, humeur: 1));
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) =>
            a.type == AlertType.FATIGUE &&
            a.level == AlertLevel.WARNING),
        isTrue,
        reason: 'Alerte FATIGUE WARNING attendue',
      );
    });

    // ── Règle SOMMEIL ────────────────────────────────────────────────────────

    test('déclenche SOMMEIL après 4 jours consécutifs de sommeil < 6', () {
      final checkins = List.generate(
          4, (i) => _checkinDaysAgo(i, sommeil: 4));
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) =>
            a.type == AlertType.SOMMEIL &&
            a.level == AlertLevel.WARNING),
        isTrue,
        reason: 'Alerte SOMMEIL WARNING attendue',
      );
    });

    // ── Règle INACTIVITE ─────────────────────────────────────────────────────

    test('déclenche INACTIVITE si aucun check-in depuis 3+ jours', () {
      // Dernier check-in il y a 4 jours
      final checkins = [_checkinDaysAgo(4)];
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) => a.type == AlertType.INACTIVITE),
        isTrue,
        reason: 'Alerte INACTIVITE attendue',
      );
    });

    test('ne déclenche PAS INACTIVITE si check-in aujourd\'hui', () {
      final checkins = [_checkinDaysAgo(0)];
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) => a.type == AlertType.INACTIVITE),
        isFalse,
      );
    });

    // ── Règle STRESS chronique ────────────────────────────────────────────────

    test('déclenche STRESS WARNING si stress moyen > 6.5 sur 7 jours', () {
      final checkins = List.generate(
          7, (i) => _checkinDaysAgo(i, stress: 8));
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      expect(
        alerts.any((a) =>
            a.type == AlertType.STRESS &&
            a.level == AlertLevel.WARNING),
        isTrue,
      );
    });

    // ── Pas d'alerte ─────────────────────────────────────────────────────────

    test('aucune alerte quand tout va bien', () {
      final checkins = List.generate(
          7, (i) => _checkinDaysAgo(i, stress: 3, sommeil: 8, humeur: 4));
      final alerts = engine.analyzeCheckins(checkins, _testProfile);
      // Peut avoir STRESS chronique si stress > 6.5, ici stress=3 donc non
      expect(
        alerts.where((a) =>
            a.type != AlertType.INACTIVITE).isEmpty,
        isTrue,
        reason: 'Aucune alerte de santé avec de bonnes valeurs',
      );
    });
  });
}
