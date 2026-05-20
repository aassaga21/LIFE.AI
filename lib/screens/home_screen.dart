import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/sections/hero_section.dart';
import '../widgets/sections/problem_section.dart';
import '../widgets/sections/how_it_works_section.dart';
import '../widgets/sections/results_section.dart';
import '../widgets/sections/pricing_section.dart';
import '../widgets/sections/cta_section.dart';
import '../widgets/sections/footer_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Navbar fixe en haut
              const Navbar(currentRoute: '/'),
              const Divider(height: 1, color: AppColors.border),
              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      HeroSection(),
                      ProblemSection(),
                      HowItWorksSection(),
                      ResultsSection(),
                      PricingSection(),
                      CtaSection(),
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
