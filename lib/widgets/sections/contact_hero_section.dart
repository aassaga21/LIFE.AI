import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ContactHeroSection extends StatelessWidget {
  const ContactHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: const Column(
        children: [
          Text(
            'Contactez-Nous',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Une question, une suggestion ou besoin d\'aide ?\nNotre équipe est là pour vous.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grayText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
