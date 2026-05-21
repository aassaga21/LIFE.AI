import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil de santé complet de l'utilisateur
class UserHealthProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String profession;
  final int age;
  final double height; // en cm
  final double weight; // en kg
  final String gender; // Homme / Femme / Autre
  final int sleepQuality; // 1-10
  final int stressLevel; // 1-10
  final String activityLevel; // sédentaire / modéré / actif / très actif
  final List<String> goals;
  final String subscription; // FREE / PREMIUM / B2B
  final DateTime createdAt;

  const UserHealthProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profession,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.sleepQuality,
    required this.stressLevel,
    required this.activityLevel,
    required this.goals,
    required this.subscription,
    required this.createdAt,
  });

  /// Indice de masse corporelle
  double get bmi => weight / ((height / 100) * (height / 100));

  /// Score sommeil sur 100
  int get sleepScore => sleepQuality * 10;

  /// Score stress sur 100 (inversé : bas stress = bon score)
  int get stressScore => (10 - stressLevel) * 10;

  /// Score activité selon le niveau déclaré
  int get activityScore {
    switch (activityLevel) {
      case 'sédentaire':
        return 30;
      case 'modéré':
        return 65;
      case 'actif':
        return 82;
      case 'très actif':
        return 95;
      default:
        return 50;
    }
  }

  /// Score global de bien-être sur 100
  int get globalScore =>
      (sleepScore * 0.35 + stressScore * 0.40 + activityScore * 0.25).round();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profession': profession,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
      'activityLevel': activityLevel,
      'goals': goals,
      'subscription': subscription,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserHealthProfile.fromMap(Map<String, dynamic> map) {
    return UserHealthProfile(
      uid: map['uid'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 170.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 70.0,
      gender: map['gender'] as String? ?? 'Autre',
      sleepQuality: (map['sleepQuality'] as num?)?.toInt() ?? 5,
      stressLevel: (map['stressLevel'] as num?)?.toInt() ?? 5,
      activityLevel: map['activityLevel'] as String? ?? 'modéré',
      goals: List<String>.from(map['goals'] as List? ?? []),
      subscription: map['subscription'] as String? ?? 'FREE',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  UserHealthProfile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? profession,
    int? age,
    double? height,
    double? weight,
    String? gender,
    int? sleepQuality,
    int? stressLevel,
    String? activityLevel,
    List<String>? goals,
    String? subscription,
    DateTime? createdAt,
  }) {
    return UserHealthProfile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profession: profession ?? this.profession,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      goals: goals ?? this.goals,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
