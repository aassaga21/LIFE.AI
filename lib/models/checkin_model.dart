import 'package:cloud_firestore/cloud_firestore.dart';

/// Check-in quotidien de l'utilisateur
class CheckIn {
  final String id;
  final String uid;
  final DateTime date;
  final int humeur;  // 1-5 (😔😐🙂😊😁)
  final int energie; // 1-10
  final int sommeil; // 1-10
  final int stress;  // 1-10
  final String? notes;

  const CheckIn({
    required this.id,
    required this.uid,
    required this.date,
    required this.humeur,
    required this.energie,
    required this.sommeil,
    required this.stress,
    this.notes,
  });

  /// Score de stress calculé (0-10)
  double get scoreStress =>
      stress * 0.40 +
      (10 - sommeil) * 0.30 +
      (10 - energie) * 0.20 +
      (5 - humeur) * 2 * 0.10;

  /// Score de fatigue calculé (0-10)
  double get scoreFatigue =>
      (10 - sommeil) * 0.35 +
      (10 - energie) * 0.25 +
      stress * 0.25 +
      (5 - humeur) * 2 * 0.15;

  /// Score de bien-être sur 100
  double get scoreBienEtre {
    final s = scoreStress * 10;
    final f = scoreFatigue * 10;
    final e = (10 - energie) * 10.0;
    return (100 - (s * 0.40 + f * 0.35 + e * 0.25)).clamp(0.0, 100.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'humeur': humeur,
      'energie': energie,
      'sommeil': sommeil,
      'stress': stress,
      'notes': notes,
      'scoreStress': scoreStress,
      'scoreFatigue': scoreFatigue,
      'scoreBienEtre': scoreBienEtre,
    };
  }

  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      humeur: (map['humeur'] as num?)?.toInt() ?? 3,
      energie: (map['energie'] as num?)?.toInt() ?? 5,
      sommeil: (map['sommeil'] as num?)?.toInt() ?? 5,
      stress: (map['stress'] as num?)?.toInt() ?? 5,
      notes: map['notes'] as String?,
    );
  }
}
