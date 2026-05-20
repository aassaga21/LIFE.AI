import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        children: [
          const Text(
            'Résultats Prouvés',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Des milliers d\'utilisateurs ont déjà transformé leur santé avec LIFE.AI',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText),
          ),
          const SizedBox(height: 48),

          // Cartes statistiques
          isWide
              ? const Row(
                  children: [
                    Expanded(
                      child: _ResultCard(
                        percentage: '89%',
                        title: 'Identification du stress',
                        description: 'avant que l\'utilisateur ne se sente "au bout"',
                        color: AppColors.primary,
                        bgColor: AppColors.primaryLight,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _ResultCard(
                        percentage: '76%',
                        title: 'Amélioration du sommeil',
                        description: 'en moins de 3 semaines d\'utilisation',
                        color: AppColors.green,
                        bgColor: AppColors.greenLight,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _ResultCard(
                        percentage: '-34%',
                        title: 'Réduction de l\'absentéisme',
                        description: 'pour les entreprises utilisatrices',
                        color: AppColors.purple,
                        bgColor: AppColors.purpleLight,
                      ),
                    ),
                  ],
                )
              : const Column(
                  children: [
                    _ResultCard(
                      percentage: '89%',
                      title: 'Identification du stress',
                      description: 'avant que l\'utilisateur ne se sente "au bout"',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                    ),
                    SizedBox(height: 16),
                    _ResultCard(
                      percentage: '76%',
                      title: 'Amélioration du sommeil',
                      description: 'en moins de 3 semaines d\'utilisation',
                      color: AppColors.green,
                      bgColor: AppColors.greenLight,
                    ),
                    SizedBox(height: 16),
                    _ResultCard(
                      percentage: '-34%',
                      title: 'Réduction de l\'absentéisme',
                      description: 'pour les entreprises utilisatrices',
                      color: AppColors.purple,
                      bgColor: AppColors.purpleLight,
                    ),
                  ],
                ),

          const SizedBox(height: 32),

          // Témoignages
          isWide
              ? const Row(
                  children: [
                    Expanded(
                      child: _TestimonialCard(
                        quote:
                            '"LIFE.AI m\'a alerté d\'un risque de burnout 3 semaines avant que je ne craque. J\'ai pu ajuster mon rythme à temps. Cette app m\'a littéralement sauvé."',
                        name: 'Marie L.',
                        role: 'Directrice Marketing',
                        initial: 'M',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _TestimonialCard(
                        quote:
                            '"En tant que parent solo, je jongle constamment. LIFE.AI me donne des conseils simples et adaptés à ma réalité. Je ne me sens plus seul face à ma santé."',
                        name: 'Thomas B.',
                        role: 'Entrepreneur',
                        initial: 'T',
                      ),
                    ),
                  ],
                )
              : const Column(
                  children: [
                    _TestimonialCard(
                      quote:
                          '"LIFE.AI m\'a alerté d\'un risque de burnout 3 semaines avant que je ne craque. J\'ai pu ajuster mon rythme à temps. Cette app m\'a littéralement sauvé."',
                      name: 'Marie L.',
                      role: 'Directrice Marketing',
                      initial: 'M',
                    ),
                    SizedBox(height: 16),
                    _TestimonialCard(
                      quote:
                          '"En tant que parent solo, je jongle constamment. LIFE.AI me donne des conseils simples et adaptés à ma réalité. Je ne me sens plus seul face à ma santé."',
                      name: 'Thomas B.',
                      role: 'Entrepreneur',
                      initial: 'T',
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String percentage;
  final String title;
  final String description;
  final Color color;
  final Color bgColor;

  const _ResultCard({
    required this.percentage,
    required this.title,
    required this.description,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            percentage,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String role;
  final String initial;

  const _TestimonialCard({
    required this.quote,
    required this.name,
    required this.role,
    required this.initial,
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
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_rounded,
                  color: AppColors.yellow, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            quote,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
