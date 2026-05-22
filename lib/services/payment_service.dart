import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const _functionUrl =
      'https://createcheckoutsession-7bxn6rvp2q-uc.a.run.app';

  static Future<void> startCheckout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final token = await user.getIdToken(true);

    final response = await http.post(
      Uri.parse(_functionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'data': {'email': user.email}
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['result']?['url'] as String?;
    if (url == null) throw Exception('URL de paiement introuvable');

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
