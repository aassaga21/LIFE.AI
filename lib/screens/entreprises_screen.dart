import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/sections/b2b_hero_section.dart';
import '../widgets/sections/b2b_stats_section.dart';
import '../widgets/sections/b2b_features_section.dart';
import '../widgets/sections/b2b_sectors_section.dart';
import '../widgets/sections/b2b_pricing_section.dart';
import '../widgets/sections/b2b_demo_section.dart';
import '../widgets/sections/footer_section.dart';

class EntreprisesScreen extends StatelessWidget {
  const EntreprisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const Navbar(currentRoute: '/entreprises'),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      B2bHeroSection(),
                      B2bStatsSection(),
                      B2bFeaturesSection(),
                      B2bSectorsSection(),
                      B2bPricingSection(),
                      B2bDemoSection(),
                      FooterSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 600),
                  child: _FloatingBtn(
                    icon: Icons.phone_android_rounded,
                    label: 'App Mobile',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 700),
                  child: _FloatingBtn(
                    icon: Icons.settings_rounded,
                    label: 'Admin',
                    color: AppColors.purple,
                  ),
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

  const _FloatingBtn(
      {required this.icon, required this.label, required this.color});

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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
