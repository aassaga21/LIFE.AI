import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/sections/contact_hero_section.dart';
import '../widgets/sections/contact_main_section.dart';
import '../widgets/sections/team_section.dart';
import '../widgets/sections/footer_section.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const Navbar(currentRoute: '/contact'),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      ContactHeroSection(),
                      ContactMainSection(),
                      TeamSection(),
                      FooterSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Boutons flottants
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _FloatingBtn(
                  icon: Icons.phone_android_rounded,
                  label: 'App Mobile',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                _FloatingBtn(
                  icon: Icons.settings_rounded,
                  label: 'Admin',
                  color: AppColors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingBtn({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
