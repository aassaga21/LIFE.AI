import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  static Future<void> startCheckout(String userEmail) async {
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('createCheckoutSession');

      final result = await callable.call({
        'email': userEmail,
      });

      final url = result.data['url'];
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Erreur Stripe: $e');
    }
  }
}