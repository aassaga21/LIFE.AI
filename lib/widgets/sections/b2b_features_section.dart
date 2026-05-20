import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animated_entrance.dart';

class B2bFeaturesSection extends StatelessWidget {
  const B2bFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Fonctionnalités Entreprise',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Une solution complète pour la santé préventive en entreprise',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 48),
          if (isWide)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 100), child: HoverCard(child: _FeatureCard(Icons.shield_rounded, 'Anonymat Garanti', 'Les données individuelles restent strictement privées. Les RH ne voient que des statistiques agrégées et anonymisées.')))),
                    const SizedBox(width: 24),
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 200), child: HoverCard(child: _FeatureCard(Icons.bar_chart_rounded, 'Tableau de Bord RH', 'Visualisez la santé globale de vos équipes avec des indicateurs clés : stress, fatigue, bien-être général.')))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 300), child: HoverCard(child: _FeatureCard(Icons.my_location_rounded, 'Alertes Préventives', 'Recevez des alertes quand un risque collectif est détecté (ex: augmentation du stress dans un département).')))),
                    const SizedBox(width: 24),
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 400), child: HoverCard(child: _FeatureCard(Icons.schedule_rounded, 'Programmes Sur-Mesure', 'Nous adaptons nos recommandations à votre secteur, votre culture d\'entreprise et vos enjeux spécifiques.')))),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                AnimatedEntrance(delay: const Duration(milliseconds: 100), child: _FeatureCard(Icons.shield_rounded, 'Anonymat Garanti', 'Les données individuelles restent strictement privées. Les RH ne voient que des statistiques agrégées et anonymisées.')),
                const SizedBox(height: 16),
                AnimatedEntrance(delay: const Duration(milliseconds: 200), child: _FeatureCard(Icons.bar_chart_rounded, 'Tableau de Bord RH', 'Visualisez la santé globale de vos équipes avec des indicateurs clés : stress, fatigue, bien-être général.')),
                const SizedBox(height: 16),
                AnimatedEntrance(delay: const Duration(milliseconds: 300), child: _FeatureCard(Icons.my_location_rounded, 'Alertes Préventives', 'Recevez des alertes quand un risque collectif est détecté (ex: augmentation du stress dans un département).')),
                const SizedBox(height: 16),
                AnimatedEntrance(delay: const Duration(milliseconds: 400), child: _FeatureCard(Icons.schedule_rounded, 'Programmes Sur-Mesure', 'Nous adaptons nos recommandations à votre secteur, votre culture d\'entreprise et vos enjeux spécifiques.')),
              ],
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard(this.icon, this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText)),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.grayText, height: 1.6)),
        ],
      ),
    );
  }
}
