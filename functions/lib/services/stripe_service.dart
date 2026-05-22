import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  static Future<void> startCheckout(String userEmail) async {
    try {
      // Récupère le token Firebase de l'utilisateur connecté
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Force le rafraîchissement du token
      await user.getIdToken(true);

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable(
        'createCheckoutSession',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final result = await callable.call({
        'email': userEmail,
      });

      final url = result.data['url'];

      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Erreur Stripe: $e');
      rethrow;
    }
  }
}