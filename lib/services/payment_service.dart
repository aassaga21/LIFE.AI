import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<void> startCheckout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final callable =
        FirebaseFunctions.instance.httpsCallable('createCheckoutSession');

    final result = await callable.call<Map<String, dynamic>>({
      'email': user.email,
    });

    final url = result.data['url'] as String?;
    if (url == null) throw Exception('URL de paiement introuvable');

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
