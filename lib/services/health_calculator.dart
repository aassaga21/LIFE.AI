import '../models/checkin_model.dart';
import '../models/user_health_profile.dart';

/// Moteur de calcul IA des scores de santé
class HealthCalculator {
  /// Délègue au getter calculé de CheckIn
  static double calculateStressScore(CheckIn checkin) => checkin.scoreStress;

  static double calculateFatigueScore(CheckIn checkin) => checkin.scoreFatigue;

  static double calculateWellbeingScore(CheckIn checkin) =>
      checkin.scoreBienEtre;

  /// Niveau de stress selon le score de bien-être (0-100)
  static String getStressLevel(double wellbeingScore) {
    if (wellbeingScore < 50) return 'CRITIQUE';
    if (wellbeingScore < 70) return 'MODÉRÉ';
    return 'BON';
  }

  /// Analyse les 7 derniers jours et retourne une alerte si nécessaire
  static String? getAlert(List<CheckIn> checkins) {
    if (checkins.length < 5) return null;

    final sorted = [...checkins]
      ..sort((a, b) => b.date.compareTo(a.date));
    final last5 = sorted.take(5).toList();

    // Stress élevé 5 jours consécutifs
    if (last5.every((c) => c.stress > 7)) {
      return 'Niveau de stress élevé détecté sur 5 jours consécutifs. '
          'Une consultation avec un professionnel est recommandée.';
    }

    // Sommeil insuffisant 5 jours consécutifs
    if (last5.every((c) => c.sommeil < 4)) {
      return 'Qualité de sommeil très faible sur 5 jours consécutifs. '
          'Pensez à améliorer votre hygiène de sommeil.';
    }

    // Bien-être moyen inférieur à 40
    final avgWellbeing = last5
            .map((c) => c.scoreBienEtre)
            .reduce((a, b) => a + b) /
        last5.length;
    if (avgWellbeing < 40) {
      return 'Votre bien-être global est en baisse depuis plusieurs jours. '
          'Prenez soin de vous.';
    }

    return null;
  }

  /// Recommandations personnalisées selon le profil et l'historique récent
  static List<Map<String, String>> getRecommendations(
    UserHealthProfile profile,
    List<CheckIn> recentCheckins,
  ) {
    final recs = <Map<String, String>>[];

    final avgStress = recentCheckins.isEmpty
        ? profile.stressLevel.toDouble()
        : recentCheckins.map((c) => c.stress).reduce((a, b) => a + b) /
            recentCheckins.length;

    final avgSleep = recentCheckins.isEmpty
        ? profile.sleepQuality.toDouble()
        : recentCheckins.map((c) => c.sommeil).reduce((a, b) => a + b) /
            recentCheckins.length;

    final avgEnergy = recentCheckins.isEmpty
        ? 5.0
        : recentCheckins.map((c) => c.energie).reduce((a, b) => a + b) /
            recentCheckins.length;

    if (avgStress > 6) {
      recs.add({
        'categorie': 'Stress',
        'icone': '🧘',
        'titre': 'Méditation de 5 minutes',
        'description':
            'Une courte séance de respiration peut réduire votre cortisol de 25%.',
      });
    }

    if (avgSleep < 6) {
      recs.add({
        'categorie': 'Sommeil',
        'icone': '😴',
        'titre': 'Routine du coucher',
        'description':
            'Éteignez les écrans 1h avant de dormir pour améliorer la qualité du sommeil.',
      });
    }

    if (profile.activityLevel == 'sédentaire' ||
        profile.activityLevel == 'modéré') {
      recs.add({
        'categorie': 'Activité',
        'icone': '🚶',
        'titre': '10 000 pas aujourd\'hui',
        'description':
            'Une marche quotidienne améliore l\'humeur et réduit le stress.',
      });
    }

    if (avgEnergy < 5) {
      recs.add({
        'categorie': 'Nutrition',
        'icone': '🥗',
        'titre': 'Hydratation optimale',
        'description':
            'Buvez 8 verres d\'eau par jour pour maintenir votre niveau d\'énergie.',
      });
    }

    if (profile.goals.any((g) =>
        g.toLowerCase().contains('perdre') ||
        g.toLowerCase().contains('poids'))) {
      recs.add({
        'categorie': 'Activité',
        'icone': '🏃',
        'titre': 'Cardio 20 minutes',
        'description':
            'Un entraînement léger aujourd\'hui vous rapproche de votre objectif.',
      });
    }

    if (recs.isEmpty) {
      recs.add({
        'categorie': 'Bien-être',
        'icone': '⭐',
        'titre': 'Continuez comme ça !',
        'description':
            'Vos indicateurs sont bons. Maintenez vos bonnes habitudes.',
      });
    }

    return recs.take(5).toList();
  }

  /// Tendance du score de stress sur la période : IMPROVING / DEGRADING / STABLE
  ///
  /// Compare la première moitié de la liste à la seconde.
  /// IMPROVING = stress qui baisse (bon signe).
  /// DEGRADING  = stress qui monte (mauvais signe).
  /// STABLE     = variation < 10 %.
  static String getTrend(List<CheckIn> checkins) {
    if (checkins.length < 2) return 'STABLE';

    final sorted = [...checkins]..sort((a, b) => a.date.compareTo(b.date));
    final mid = sorted.length ~/ 2;
    final firstHalf = sorted.sublist(0, mid);
    final secondHalf = sorted.sublist(mid);

    double avg(List<CheckIn> list) =>
        list.map((c) => c.scoreStress).reduce((a, b) => a + b) / list.length;

    final avgFirst = avg(firstHalf);
    final avgSecond = avg(secondHalf);

    // Évite la division par zéro
    if (avgFirst == 0 && avgSecond == 0) return 'STABLE';
    final base = avgFirst > 0 ? avgFirst : 1.0;
    final changePercent = (avgSecond - avgFirst) / base * 100;

    if (changePercent.abs() < 10) return 'STABLE';
    // Score stress qui baisse = amélioration
    return changePercent < 0 ? 'IMPROVING' : 'DEGRADING';
  }
}
