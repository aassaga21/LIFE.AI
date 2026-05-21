import 'package:flutter/foundation.dart';
import '../models/user_health_profile.dart';
import '../models/checkin_model.dart';
import '../services/firestore_service.dart';
import '../services/health_calculator.dart';

/// Provider global pour l'état utilisateur (profil + check-ins)
class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserHealthProfile? _profile;
  List<CheckIn> _recentCheckins = [];
  bool _loading = false;
  String? _error;

  UserHealthProfile? get profile => _profile;
  List<CheckIn> get recentCheckins => _recentCheckins;
  bool get loading => _loading;
  String? get error => _error;

  /// Score de bien-être actuel : depuis le dernier check-in ou le profil
  double get currentWellbeingScore {
    if (_recentCheckins.isNotEmpty) {
      return _recentCheckins.first.scoreBienEtre;
    }
    return _profile?.globalScore.toDouble() ?? 50.0;
  }

  /// Alerte active si détectée par le calculateur
  String? get currentAlert => HealthCalculator.getAlert(_recentCheckins);

  /// Charge le profil et les check-ins des 7 derniers jours
  Future<void> loadUserData(String uid) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _firestoreService.getUserProfile(uid);
      _recentCheckins = await _firestoreService.getCheckins(uid, days: 7);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Sauvegarde un check-in et met à jour la liste locale
  Future<void> saveCheckin(CheckIn checkin) async {
    await _firestoreService.saveCheckin(checkin);
    _recentCheckins = [checkin, ..._recentCheckins];
    notifyListeners();
  }

  /// Réinitialise l'état à la déconnexion
  void clear() {
    _profile = null;
    _recentCheckins = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
