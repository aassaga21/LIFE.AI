import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Flux d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur courant
  User? get currentUser => _auth.currentUser;

  // Traduit les codes d'erreur Firebase en messages français
  String _traductionErreur(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // Inscription : crée le compte Firebase Auth + document Firestore
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? profession,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Sauvegarde du profil utilisateur dans Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName.trim(),
        'lastName': lastName?.trim() ?? '',
        'email': email.trim(),
        'profession': profession?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'subscription': 'FREE',
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(_traductionErreur(e.code));
    }
  }

  // Connexion par email et mot de passe
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_traductionErreur(e.code));
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Envoi du mail de réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_traductionErreur(e.code));
    }
  }
}
