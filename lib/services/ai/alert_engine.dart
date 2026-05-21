import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/checkin_model.dart';
import '../../models/user_health_profile.dart';

enum AlertType { BURNOUT, FATIGUE, SOMMEIL, INACTIVITE, STRESS }

enum AlertLevel { INFO, WARNING, CRITICAL }

/// Règle d'alerte déclenchée par le moteur d'analyse
class AlertRule {
  final String id;
  final AlertType type;
  final AlertLevel level;
  final String title;
  final String message;
  final String actionSuggested;
  final String route;
  final DateTime triggeredAt;
  final bool isAcknowledged;

  const AlertRule({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.message,
    required this.actionSuggested,
    required this.route,
    required this.triggeredAt,
    this.isAcknowledged = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'level': level.name,
        'title': title,
        'message': message,
        'actionSuggested': actionSuggested,
        'route': route,
        'triggeredAt': Timestamp.fromDate(triggeredAt),
        'isAcknowledged': isAcknowledged,
      };

  factory AlertRule.fromMap(Map<String, dynamic> map) => AlertRule(
        id: map['id'] as String? ?? '',
        type: AlertType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => AlertType.STRESS,
        ),
        level: AlertLevel.values.firstWhere(
          (e) => e.name == map['level'],
          orElse: () => AlertLevel.INFO,
        ),
        title: map['title'] as String? ?? '',
        message: map['message'] as String? ?? '',
        actionSuggested: map['actionSuggested'] as String? ?? '',
        route: map['route'] as String? ?? '/',
        triggeredAt:
            (map['triggeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isAcknowledged: map['isAcknowledged'] as bool? ?? false,
      );
}

/// Moteur d'alertes intelligentes — analyse les check-ins et détecte les risques
class AlertEngine {
  // Getter lazy : Firebase n'est accédé qu'au premier appel Firestore
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ── ANALYSE PURE (testable sans Firestore) ─────────────────────────────────

  /// Analyse les check-ins et retourne les alertes actives.
  /// Logique synchrone — pas d'appels réseau.
  List<AlertRule> analyzeCheckins(
    List<CheckIn> checkins,
    UserHealthProfile profile,
  ) {
    final alerts = <AlertRule>[];
    final now = DateTime.now();

    // Tri par date décroissante
    final sorted = [...checkins]..sort((a, b) => b.date.compareTo(a.date));

    // 1 ─ BURNOUT CRITICAL : stress > 7 pendant 5 jours consécutifs
    final highStress = sorted.where((c) => c.stress > 7).toList();
    if (_hasConsecutiveDays(highStress, 5)) {
      alerts.add(AlertRule(
        id: '${AlertType.BURNOUT.name}_${now.millisecondsSinceEpoch}',
        type: AlertType.BURNOUT,
        level: AlertLevel.CRITICAL,
        title: 'Risque de burnout détecté',
        message:
            'Votre niveau de stress est élevé depuis 5 jours. Prenez une pause.',
        actionSuggested: 'Exercices de respiration',
        route: '/checkin',
        triggeredAt: now,
      ));
    }

    // 2 ─ FATIGUE WARNING : scoreFatigue > 60% pendant 3 jours consécutifs
    final highFatigue =
        sorted.where((c) => c.scoreFatigue * 10 > 60).toList();
    if (_hasConsecutiveDays(highFatigue, 3)) {
      alerts.add(AlertRule(
        id: '${AlertType.FATIGUE.name}_${now.millisecondsSinceEpoch}',
        type: AlertType.FATIGUE,
        level: AlertLevel.WARNING,
        title: 'Fatigue accumulée détectée',
        message: 'Votre fatigue augmente. Priorisez le repos.',
        actionSuggested: 'Conseils sommeil',
        route: '/checkin',
        triggeredAt: now,
      ));
    }

    // 3 ─ SOMMEIL WARNING : sommeil < 6 pendant 4 jours consécutifs
    final lowSleep = sorted.where((c) => c.sommeil < 6).toList();
    if (_hasConsecutiveDays(lowSleep, 4)) {
      alerts.add(AlertRule(
        id: '${AlertType.SOMMEIL.name}_${now.millisecondsSinceEpoch}',
        type: AlertType.SOMMEIL,
        level: AlertLevel.WARNING,
        title: 'Qualité de sommeil insuffisante',
        message: 'Votre sommeil perturbé impacte votre santé.',
        actionSuggested: 'Routine du soir',
        route: '/checkin',
        triggeredAt: now,
      ));
    }

    // 4 ─ INACTIVITE INFO : aucun check-in depuis 3 jours
    if (_isInactive(sorted)) {
      alerts.add(AlertRule(
        id: '${AlertType.INACTIVITE.name}_${now.millisecondsSinceEpoch}',
        type: AlertType.INACTIVITE,
        level: AlertLevel.INFO,
        title: 'On vous cherche !',
        message: 'Revenez faire votre check-in quotidien.',
        actionSuggested: 'Faire mon check-in',
        route: '/checkin',
        triggeredAt: now,
      ));
    }

    // 5 ─ STRESS WARNING : stress moyen > 6.5 sur 7 jours
    final last7 = sorted.take(7).toList();
    if (last7.length >= 5) {
      final avgStress =
          last7.map((c) => c.stress).reduce((a, b) => a + b) / last7.length;
      if (avgStress > 6.5) {
        alerts.add(AlertRule(
          id: '${AlertType.STRESS.name}_${now.millisecondsSinceEpoch}',
          type: AlertType.STRESS,
          level: AlertLevel.WARNING,
          title: 'Stress chronique détecté',
          message: 'Votre stress moyen est élevé cette semaine.',
          actionSuggested: 'Méditation guidée',
          route: '/checkin',
          triggeredAt: now,
        ));
      }
    }

    return alerts;
  }

  // ── PERSISTANCE FIRESTORE ──────────────────────────────────────────────────

  /// Sauvegarde une alerte — vérifie qu'il n'y a pas de doublon dans les 24h
  Future<void> saveAlert(AlertRule alert, String uid) async {
    final since = DateTime.now().subtract(const Duration(hours: 24));
    final existing = await _db
        .collection('users')
        .doc(uid)
        .collection('alerts')
        .where('type', isEqualTo: alert.type.name)
        .where('triggeredAt',
            isGreaterThan: Timestamp.fromDate(since))
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _db
          .collection('users')
          .doc(uid)
          .collection('alerts')
          .doc(alert.id)
          .set(alert.toMap());
    }
  }

  Future<List<AlertRule>> getActiveAlerts(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('alerts')
        .where('isAcknowledged', isEqualTo: false)
        .orderBy('triggeredAt', descending: true)
        .get();
    return snap.docs.map((d) => AlertRule.fromMap(d.data())).toList();
  }

  Future<void> acknowledgeAlert(String alertId, String uid) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('alerts')
        .doc(alertId)
        .update({'isAcknowledged': true});
  }

  // ── HELPERS PRIVÉS ─────────────────────────────────────────────────────────

  /// Vérifie si les check-ins couvrent N jours calendaires consécutifs
  bool _hasConsecutiveDays(List<CheckIn> checkins, int required) {
    if (checkins.isEmpty) return false;

    // Dates uniques en jours calendaires, triées décroissantes
    final days = checkins
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (days.length < required) return false;

    int streak = 1;
    for (int i = 1; i < days.length; i++) {
      if (days[i - 1].difference(days[i]).inDays == 1) {
        streak++;
        if (streak >= required) return true;
      } else {
        streak = 1;
      }
    }
    return streak >= required;
  }

  /// Retourne true si aucun check-in depuis 3 jours
  bool _isInactive(List<CheckIn> sorted) {
    if (sorted.isEmpty) return true;
    return DateTime.now().difference(sorted.first.date).inDays >= 3;
  }
}
