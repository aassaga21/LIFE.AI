import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_health_profile.dart';
import '../models/checkin_model.dart';

/// Service d'accès à Firestore — profils et check-ins
///
/// Structure Firestore :
///   users/{uid}             → UserHealthProfile (fusionné avec les champs auth)
///   users/{uid}/checkins/   → collection de CheckIn
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── PROFIL ──────────────────────────────────────────────────────────────

  /// Sauvegarde le profil en fusionnant avec les champs existants
  Future<void> saveUserProfile(UserHealthProfile profile) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserHealthProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserHealthProfile.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<UserHealthProfile?> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserHealthProfile.fromMap(snap.data()!);
    });
  }

  // ── CHECK-INS ────────────────────────────────────────────────────────────

  Future<void> saveCheckin(CheckIn checkin) async {
    await _db
        .collection('users')
        .doc(checkin.uid)
        .collection('checkins')
        .doc(checkin.id)
        .set(checkin.toMap());
  }

  Future<List<CheckIn>> getCheckins(String uid, {int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final query = await _db
        .collection('users')
        .doc(uid)
        .collection('checkins')
        .where('date', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('date', descending: true)
        .get();
    return query.docs.map((d) => CheckIn.fromMap(d.data())).toList();
  }

  Stream<List<CheckIn>> checkinsStream(String uid, {int days = 7}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('users')
        .doc(uid)
        .collection('checkins')
        .where('date', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CheckIn.fromMap(d.data())).toList());
  }

  Future<CheckIn?> getTodayCheckin(String uid) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final query = await _db
        .collection('users')
        .doc(uid)
        .collection('checkins')
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return CheckIn.fromMap(query.docs.first.data());
  }

  Future<bool> hasCheckinToday(String uid) async {
    return await getTodayCheckin(uid) != null;
  }

  /// Charge une page de check-ins avec curseur date (pour infinite scroll)
  Future<List<CheckIn>> getCheckinsBefore({
    required String uid,
    required DateTime before,
    int limit = 20,
    int? filterDays,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .doc(uid)
        .collection('checkins')
        .where('date', isLessThan: Timestamp.fromDate(before))
        .orderBy('date', descending: true)
        .limit(limit);

    if (filterDays != null) {
      final since = DateTime.now().subtract(Duration(days: filterDays));
      query = _db
          .collection('users')
          .doc(uid)
          .collection('checkins')
          .where('date', isGreaterThan: Timestamp.fromDate(since))
          .where('date', isLessThan: Timestamp.fromDate(before))
          .orderBy('date', descending: true)
          .limit(limit);
    }

    final snap = await query.get();
    return snap.docs.map((d) => CheckIn.fromMap(d.data())).toList();
  }

  // ── STATISTIQUES ─────────────────────────────────────────────────────────

  /// Statistiques agrégées des 7 derniers jours
  Future<Map<String, dynamic>> getWeeklyStats(String uid) async {
    final checkins = await getCheckins(uid, days: 7);

    if (checkins.isEmpty) {
      return {
        'avgStress': 0.0,
        'avgSleep': 0.0,
        'avgEnergy': 0.0,
        'avgMood': 0.0,
        'bestDay': null,
        'streak': 0,
        'trend': 'stable',
      };
    }

    final avgStress =
        checkins.map((c) => c.stress).reduce((a, b) => a + b) /
            checkins.length;
    final avgSleep =
        checkins.map((c) => c.sommeil).reduce((a, b) => a + b) /
            checkins.length;
    final avgEnergy =
        checkins.map((c) => c.energie).reduce((a, b) => a + b) /
            checkins.length;
    final avgMood =
        checkins.map((c) => c.humeur).reduce((a, b) => a + b) /
            checkins.length;

    // Meilleure journée selon le score de bien-être
    final bestDay = checkins
        .reduce((a, b) => a.scoreBienEtre > b.scoreBienEtre ? a : b);

    // Nombre de jours consécutifs avec check-in
    int streak = 0;
    for (var i = 0; i < 7; i++) {
      final day = DateTime.now()
          .subtract(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      final hasEntry = checkins.any((c) {
        final d = DateTime(c.date.year, c.date.month, c.date.day);
        return d == dayKey;
      });
      if (hasEntry) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    // Tendance : compare première et deuxième moitié de la semaine
    String trend = 'stable';
    if (checkins.length >= 4) {
      final mid = checkins.length ~/ 2;
      final olderHalf =
          checkins.sublist(mid).map((c) => c.scoreBienEtre).toList();
      final recentHalf =
          checkins.sublist(0, mid).map((c) => c.scoreBienEtre).toList();
      final avgOlder =
          olderHalf.reduce((a, b) => a + b) / olderHalf.length;
      final avgRecent =
          recentHalf.reduce((a, b) => a + b) / recentHalf.length;
      if (avgRecent - avgOlder > 5) {
        trend = 'hausse';
      } else if (avgOlder - avgRecent > 5) {
        trend = 'baisse';
      }
    }

    return {
      'avgStress': avgStress,
      'avgSleep': avgSleep,
      'avgEnergy': avgEnergy,
      'avgMood': avgMood,
      'bestDay': bestDay.date,
      'streak': streak,
      'trend': trend,
    };
  }
}
