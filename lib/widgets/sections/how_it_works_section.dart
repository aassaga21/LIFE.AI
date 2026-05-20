import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        children: [
          const Text(
            'Comment Ça Marche',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Trois étapes simples pour prendre soin de votre santé en avance',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText, height: 1.5),
          ),
          const SizedBox(height: 48),
          isWide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StepCard(
                        icon: Icons.bar_chart_rounded,
                        step: '1. Mesurer',
                        description:
                            'Enregistrement continu et passif de vos données : sommeil, activité, humeur, comportements. Aucune saisie manuelle fastidieuse.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _StepCard(
                        icon: Icons.psychology_rounded,
                        step: '2. Prédire',
                        description:
                            'Notre IA détecte les déséquilibres 2-3 semaines avant les symptômes visibles grâce à des algorithmes entraînés sur 100 000+ profils.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _StepCard(
                        icon: Icons.trending_up_rounded,
                        step: '3. Agir',
                        description:
                            'Recevez des recommandations personnalisées et actionnables adaptées à votre profil unique et à votre contexte de vie.',
                      ),
                    ),
                  ],
                )
              : const Column(
                  children: [
                    _StepCard(
                      icon: Icons.bar_chart_rounded,
                      step: '1. Mesurer',
                      description:
                          'Enregistrement continu et passif de vos données : sommeil, activité, humeur, comportements. Aucune saisie manuelle fastidieuse.',
                    ),
                    SizedBox(height: 16),
                    _StepCard(
                      icon: Icons.psychology_rounded,
                      step: '2. Prédire',
                      description:
                          'Notre IA détecte les déséquilibres 2-3 semaines avant les symptômes visibles grâce à des algorithmes entraînés sur 100 000+ profils.',
                    ),
                    SizedBox(height: 16),
                    _StepCard(
                      icon: Icons.trending_up_rounded,
                      step: '3. Agir',
                      description:
                          'Recevez des recommandations personnalisées et actionnables adaptées à votre profil unique et à votre contexte de vie.',
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String step;
  final String description;

  const _StepCard({
    required this.icon,
    required this.step,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            step,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grayText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
