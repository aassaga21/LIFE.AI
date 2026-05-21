import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/checkin_model.dart';
import '../../models/user_health_profile.dart';
import 'alert_engine.dart';

/// Une recommandation personnalisée
class Recommendation {
  final String id;
  final String category; // STRESS / SOMMEIL / ACTIVITÉ / NUTRITION / MINDFULNESS
  final String title;
  final String description;
  final String icon;
  final String duration;
  final String difficulty;
  final Map<String, dynamic> conditions;

  const Recommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
    required this.difficulty,
    this.conditions = const {},
  });
}

/// Base de données des 30 recommandations
const List<Recommendation> _allRecommendations = [
  // ── STRESS (8) ────────────────────────────────────────────────────────────
  Recommendation(
    id: 'breathing_478',
    category: 'STRESS',
    title: 'Cohérence cardiaque 4-7-8',
    description: 'Inspirez 4s, retenez 7s, expirez 8s. Répétez 4 fois.',
    icon: '🧘',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {'minStress': 6},
  ),
  Recommendation(
    id: 'box_breathing',
    category: 'STRESS',
    title: 'Respiration en boîte',
    description: 'Inspirez 4s, pause 4s, expirez 4s, pause 4s. Répétez 6 fois.',
    icon: '📦',
    duration: '4 min',
    difficulty: 'Facile',
    conditions: {'minStress': 5},
  ),
  Recommendation(
    id: 'cold_shower',
    category: 'STRESS',
    title: 'Douche froide 30 secondes',
    description: 'Terminez votre douche par 30s d\'eau froide. Réduit le cortisol.',
    icon: '🚿',
    duration: '2 min',
    difficulty: 'Modéré',
    conditions: {'minStress': 7},
  ),
  Recommendation(
    id: 'journaling',
    category: 'STRESS',
    title: 'Journal des émotions',
    description: 'Écrivez 3 choses qui vous ont pesé aujourd\'hui. Libérez-les sur papier.',
    icon: '📓',
    duration: '10 min',
    difficulty: 'Facile',
    conditions: {'minStress': 6},
  ),
  Recommendation(
    id: 'digital_detox',
    category: 'STRESS',
    title: 'Pause numérique 30 min',
    description: 'Éteignez notifications et réseaux sociaux pendant 30 minutes.',
    icon: '📵',
    duration: '30 min',
    difficulty: 'Facile',
    conditions: {'minStress': 5},
  ),
  Recommendation(
    id: 'meditation_body',
    category: 'STRESS',
    title: 'Body scan 10 minutes',
    description: 'Allongez-vous et scannez mentalement chaque partie de votre corps.',
    icon: '🛁',
    duration: '10 min',
    difficulty: 'Facile',
    conditions: {'minStress': 6},
  ),
  Recommendation(
    id: 'yoga_stress',
    category: 'STRESS',
    title: 'Yoga anti-stress',
    description: 'Séquence de 5 postures apaisantes : enfant, chat/vache, torsion.',
    icon: '🧎',
    duration: '15 min',
    difficulty: 'Facile',
    conditions: {'minStress': 6},
  ),
  Recommendation(
    id: 'tea_ceremony',
    category: 'STRESS',
    title: 'Rituel thé chaud',
    description: 'Préparez un thé sans écran, en pleine conscience. Appréciez l\'instant.',
    icon: '🍵',
    duration: '10 min',
    difficulty: 'Facile',
    conditions: {'minStress': 4},
  ),

  // ── SOMMEIL (7) ───────────────────────────────────────────────────────────
  Recommendation(
    id: 'sleep_routine',
    category: 'SOMMEIL',
    title: 'Routine du coucher',
    description: 'Créez une routine fixe : lecture, tisane, lumière tamisée pendant 20 min.',
    icon: '🌙',
    duration: '20 min',
    difficulty: 'Facile',
    conditions: {'maxSleep': 7},
  ),
  Recommendation(
    id: 'no_screen_1h',
    category: 'SOMMEIL',
    title: 'Stop écrans 1h avant',
    description: 'La lumière bleue retarde la mélatonine. Éteignez les écrans à 21h.',
    icon: '📺',
    duration: '60 min',
    difficulty: 'Modéré',
    conditions: {'maxSleep': 6},
  ),
  Recommendation(
    id: 'room_temperature',
    category: 'SOMMEIL',
    title: 'Chambre à 18°C',
    description: 'La température idéale pour dormir est 16-19°C. Aérez 10 min.',
    icon: '🌡️',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {'maxSleep': 8},
  ),
  Recommendation(
    id: 'magnesium',
    category: 'SOMMEIL',
    title: 'Magnésium bisglycinate',
    description: 'Prenez 200mg de magnésium bisglycinate 1h avant de dormir.',
    icon: '💊',
    duration: '1 min',
    difficulty: 'Facile',
    conditions: {'maxSleep': 6},
  ),
  Recommendation(
    id: 'relaxation_sounds',
    category: 'SOMMEIL',
    title: 'Sons relaxants',
    description: 'Écoutez bruit blanc ou sons de pluie pendant l\'endormissement.',
    icon: '🎵',
    duration: '20 min',
    difficulty: 'Facile',
    conditions: {'maxSleep': 7},
  ),
  Recommendation(
    id: 'sleep_schedule',
    category: 'SOMMEIL',
    title: 'Horaires fixes de sommeil',
    description: 'Levez-vous à la même heure 7j/7. Le rythme circadien se stabilise en 3 semaines.',
    icon: '⏰',
    duration: '0 min',
    difficulty: 'Difficile',
    conditions: {'maxSleep': 7},
  ),
  Recommendation(
    id: 'power_nap',
    category: 'SOMMEIL',
    title: 'Sieste 20 minutes',
    description: 'Une sieste de 20 min avant 15h restaure l\'attention sans créer d\'inertie.',
    icon: '😴',
    duration: '20 min',
    difficulty: 'Facile',
    conditions: {'maxSleep': 5},
  ),

  // ── ACTIVITÉ (6) ──────────────────────────────────────────────────────────
  Recommendation(
    id: 'walk_10k',
    category: 'ACTIVITÉ',
    title: '10 000 pas aujourd\'hui',
    description: 'Une marche quotidienne améliore l\'humeur via les endorphines.',
    icon: '🚶',
    duration: '30 min',
    difficulty: 'Facile',
    conditions: {'activityLevels': ['sédentaire', 'modéré']},
  ),
  Recommendation(
    id: 'cardio_20',
    category: 'ACTIVITÉ',
    title: 'Cardio 20 minutes',
    description: 'Course, vélo ou natation à intensité modérée. Libère des endorphines.',
    icon: '🏃',
    duration: '20 min',
    difficulty: 'Modéré',
    conditions: {'activityLevels': ['modéré', 'actif', 'très actif']},
  ),
  Recommendation(
    id: 'stretching',
    category: 'ACTIVITÉ',
    title: 'Étirements 10 minutes',
    description: 'Relâchez les tensions musculaires avec 5 étirements progressifs.',
    icon: '🤸',
    duration: '10 min',
    difficulty: 'Facile',
    conditions: {},
  ),
  Recommendation(
    id: 'stairs_elevator',
    category: 'ACTIVITÉ',
    title: 'Escaliers plutôt qu\'ascenseur',
    description: 'Montez les escaliers toute la journée. Jusqu\'à 500 kcal supplémentaires.',
    icon: '🏢',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {'activityLevels': ['sédentaire']},
  ),
  Recommendation(
    id: 'desk_breaks',
    category: 'ACTIVITÉ',
    title: 'Pauses actives horaires',
    description: 'Toutes les heures, levez-vous 5 min. Marchez, étirez-vous.',
    icon: '🪑',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {'activityLevels': ['sédentaire', 'modéré']},
  ),
  Recommendation(
    id: 'cycling_commute',
    category: 'ACTIVITÉ',
    title: 'Vélo pour les trajets',
    description: 'Remplacez un trajet en transport par le vélo. 30 min cardio gratuit.',
    icon: '🚴',
    duration: '30 min',
    difficulty: 'Modéré',
    conditions: {'activityLevels': ['sédentaire', 'modéré']},
  ),

  // ── NUTRITION (5) ─────────────────────────────────────────────────────────
  Recommendation(
    id: 'hydration',
    category: 'NUTRITION',
    title: 'Hydratation optimale',
    description: 'Buvez 8 verres d\'eau. La déshydratation amplifie fatigue et stress.',
    icon: '💧',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {},
  ),
  Recommendation(
    id: 'omega3',
    category: 'NUTRITION',
    title: 'Oméga-3 quotidien',
    description: 'Poisson gras, noix ou complément EPA/DHA. Réduit l\'inflammation cérébrale.',
    icon: '🐟',
    duration: '2 min',
    difficulty: 'Facile',
    conditions: {'minStress': 5},
  ),
  Recommendation(
    id: 'plant_breakfast',
    category: 'NUTRITION',
    title: 'Petit-déjeuner végétal',
    description: 'Flocons d\'avoine, banane, amandes. Énergie stable sans pic glycémique.',
    icon: '🌿',
    duration: '10 min',
    difficulty: 'Facile',
    conditions: {},
  ),
  Recommendation(
    id: 'snack_healthy',
    category: 'NUTRITION',
    title: 'Collation anti-stress',
    description: 'Noix, chocolat noir 70%, banane. Ces aliments régulent le cortisol.',
    icon: '🥜',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {'minStress': 5},
  ),
  Recommendation(
    id: 'coffee_limit',
    category: 'NUTRITION',
    title: 'Stop café après 14h',
    description: 'La caféine a une demi-vie de 5h. Elle perturbe le sommeil du soir.',
    icon: '☕',
    duration: '0 min',
    difficulty: 'Modéré',
    conditions: {'maxSleep': 7},
  ),

  // ── MINDFULNESS (4) ───────────────────────────────────────────────────────
  Recommendation(
    id: 'gratitude',
    category: 'MINDFULNESS',
    title: 'Journal de gratitude',
    description: 'Notez 3 choses positives de la journée. Recâble le cerveau vers le positif.',
    icon: '🙏',
    duration: '5 min',
    difficulty: 'Facile',
    conditions: {},
  ),
  Recommendation(
    id: '5_senses',
    category: 'MINDFULNESS',
    title: 'Exercice 5 sens',
    description: '5 choses vues, 4 entendues, 3 touchées, 2 senties, 1 goûtée.',
    icon: '👁️',
    duration: '3 min',
    difficulty: 'Facile',
    conditions: {'minStress': 5},
  ),
  Recommendation(
    id: 'mindful_eating',
    category: 'MINDFULNESS',
    title: 'Manger en pleine conscience',
    description: 'Un repas sans écran ni distraction. Mâchez lentement, savourez.',
    icon: '🍽️',
    duration: '20 min',
    difficulty: 'Modéré',
    conditions: {},
  ),
  Recommendation(
    id: 'nature_walk',
    category: 'MINDFULNESS',
    title: 'Marche en nature 15 min',
    description: 'La nature réduit le cortisol de 20%. Parc, forêt ou jardin, 15 min sans téléphone.',
    icon: '🌳',
    duration: '15 min',
    difficulty: 'Facile',
    conditions: {'minStress': 4},
  ),
];

/// Moteur de recommandations personnalisées avec scoring et blacklist
class RecommendationEngine {
  // Getter lazy : Firebase n'est accédé qu'au premier appel Firestore
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static const String _prefKey = 'rec_blacklist_';

  // ── SÉLECTION DES RECOMMANDATIONS ─────────────────────────────────────────

  Future<List<Recommendation>> getRecommendations({
    required UserHealthProfile profile,
    required List<CheckIn> recentCheckins,
    List<AlertRule> activeAlerts = const [],
    int count = 5,
  }) async {
    final blacklist = await getBlacklist(profile.uid);

    // Calcul des moyennes récentes
    final avgStress = recentCheckins.isEmpty
        ? profile.stressLevel.toDouble()
        : recentCheckins.map((c) => c.stress).reduce((a, b) => a + b) /
            recentCheckins.length;
    final avgSleep = recentCheckins.isEmpty
        ? profile.sleepQuality.toDouble()
        : recentCheckins.map((c) => c.sommeil).reduce((a, b) => a + b) /
            recentCheckins.length;

    // Score chaque recommandation
    final scored = _allRecommendations.map((rec) {
      final s = _score(
        rec: rec,
        profile: profile,
        avgStress: avgStress,
        avgSleep: avgSleep,
        activeAlerts: activeAlerts,
        blacklist: blacklist,
      );
      return (rec, s);
    }).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    // Filtre les recommandations blacklistées et prend les N meilleures
    return scored
        .where((e) => e.$2 > -50)
        .take(count)
        .map((e) => e.$1)
        .toList();
  }

  // ── ALGORITHME DE SCORING ─────────────────────────────────────────────────

  double _score({
    required Recommendation rec,
    required UserHealthProfile profile,
    required double avgStress,
    required double avgSleep,
    required List<AlertRule> activeAlerts,
    required List<String> blacklist,
  }) {
    double score = 0;

    // Blacklist — exclure
    if (blacklist.contains(rec.id)) return -100;

    // +30 si correspond à un objectif utilisateur
    final goalKeywords = {
      'STRESS': ['stress', 'burnout', 'anxiété'],
      'SOMMEIL': ['sommeil', 'dormir', 'fatigue'],
      'ACTIVITÉ': ['sport', 'bouger', 'activité', 'poids'],
      'NUTRITION': ['manger', 'nutrition', 'poids', 'énergie'],
      'MINDFULNESS': ['bien-être', 'stress', 'mental'],
    };
    final keywords = goalKeywords[rec.category] ?? [];
    if (profile.goals.any((g) =>
        keywords.any((k) => g.toLowerCase().contains(k)))) {
      score += 30;
    }

    // +25 si conditions remplies
    if (_conditionsMet(rec, avgStress, avgSleep, profile.activityLevel)) {
      score += 25;
    }

    // +20 si lié à une alerte active
    final alertCategories = {
      AlertType.BURNOUT: 'STRESS',
      AlertType.STRESS: 'STRESS',
      AlertType.FATIGUE: 'SOMMEIL',
      AlertType.SOMMEIL: 'SOMMEIL',
      AlertType.INACTIVITE: 'ACTIVITÉ',
    };
    if (activeAlerts.any(
        (a) => alertCategories[a.type] == rec.category)) {
      score += 20;
    }

    // +10 si adapté au niveau d'activité
    final levels = rec.conditions['activityLevels'];
    if (levels == null ||
        (levels is List && levels.contains(profile.activityLevel))) {
      score += 10;
    }

    // +5 si heure appropriée
    final hour = DateTime.now().hour;
    if (rec.category == 'SOMMEIL' && hour >= 20) score += 5;
    if (rec.category == 'STRESS' && hour >= 9 && hour <= 18) score += 5;
    if (rec.category == 'MINDFULNESS' && (hour < 9 || hour >= 20)) score += 5;

    return score;
  }

  bool _conditionsMet(
    Recommendation rec,
    double avgStress,
    double avgSleep,
    String activityLevel,
  ) {
    final c = rec.conditions;
    if (c.isEmpty) return true;
    if (c['minStress'] != null && avgStress < (c['minStress'] as num)) {
      return false;
    }
    if (c['maxSleep'] != null && avgSleep > (c['maxSleep'] as num)) {
      return false;
    }
    return true;
  }

  // ── FEEDBACK ──────────────────────────────────────────────────────────────

  Future<void> saveFeedback({
    required String uid,
    required String recommendationId,
    required bool isPositive,
  }) async {
    // Blacklist locale en premier — indépendante de Firestore
    if (!isPositive) {
      await updateBlacklist(uid, recommendationId);
    }
    // Persistance Firestore (non bloquante en cas d'indisponibilité)
    try {
      await _db.collection('users').doc(uid).collection('feedback').add({
        'recommendationId': recommendationId,
        'isPositive': isPositive,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Firestore non disponible (tests, hors-ligne) — on ignore
    }
  }

  // ── BLACKLIST (SharedPreferences) ─────────────────────────────────────────

  Future<List<String>> getBlacklist(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefKey$uid') ?? [];
    final now = DateTime.now().millisecondsSinceEpoch;

    // Filtre les entrées expirées
    final valid =
        raw.where((entry) {
          final parts = entry.split(':');
          if (parts.length != 2) return false;
          return (int.tryParse(parts[1]) ?? 0) > now;
        }).toList();

    if (valid.length != raw.length) {
      await prefs.setStringList('$_prefKey$uid', valid);
    }
    return valid.map((e) => e.split(':')[0]).toList();
  }

  Future<void> updateBlacklist(String uid, String recId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now()
        .add(const Duration(days: 2))
        .millisecondsSinceEpoch;
    final raw = prefs.getStringList('$_prefKey$uid') ?? [];
    raw.removeWhere((e) => e.startsWith('$recId:'));
    raw.add('$recId:$expiry');
    await prefs.setStringList('$_prefKey$uid', raw);
  }
}
