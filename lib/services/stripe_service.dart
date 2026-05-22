import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  static const _functionUrl =
      'https://createcheckoutsession-7bxn6rvp2q-uc.a.run.app';

  static Future<void> startCheckout(String userEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Récupère le token Firebase
      final token = await user.getIdToken(true);

      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'data': {'email': userEmail}
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final url = json['result']['url'] as String?;
        if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        print('Erreur HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur Stripe: $e');
    }
  }
}