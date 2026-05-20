import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AboutMissionSection extends StatelessWidget {
  const AboutMissionSection({super.key});

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
          // Titre + description mission
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _MissionText()),
                    const SizedBox(width: 64),
                    Expanded(child: _StatsColumn()),
                  ],
                )
              : Column(
                  children: [
                    const _MissionText(),
                    const SizedBox(height: 48),
                    _StatsColumn(),
                  ],
                ),

          const SizedBox(height: 72),

          // Origines
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notre Histoire',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'LIFE.AI est né d\'un constat simple : nous vivons dans un monde où la médecine intervient trop tard. '
                  'Nos fondateurs, confrontés à des burnouts dans leur entourage, ont voulu créer un outil qui anticipe plutôt que de guérir.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grayText,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'En 2024, une équipe de passionnés de santé numérique, d\'intelligence artificielle et de bien-être s\'est réunie '
                  'pour construire la première plateforme de santé véritablement préventive. LIFE.AI analyse vos données de vie '
                  'pour détecter les signaux faibles, 2 à 3 semaines avant que les problèmes ne deviennent visibles.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grayText,
                    height: 1.7,
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

class _MissionText extends StatelessWidget {
  const _MissionText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notre Mission',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Démocratiser la santé préventive grâce à l\'intelligence artificielle, '
          'pour que chaque personne puisse vivre en meilleure santé, plus longtemps, '
          'sans attendre d\'être malade.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grayText,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Nous croyons qu\'une technologie bienveillante, combinée à des données de santé '
          'fiables, peut transformer radicalement notre rapport au bien-être.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grayText,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _StatsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _StatBox('2024', 'Année de création', AppColors.primaryLight,
            AppColors.primary),
        SizedBox(height: 16),
        _StatBox('100K+', 'Profils analysés par notre IA',
            AppColors.greenLight, AppColors.green),
        SizedBox(height: 16),
        _StatBox('89%', 'Taux de détection préventive',
            AppColors.purpleLight, AppColors.purple),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color bgColor;
  final Color color;

  const _StatBox(this.value, this.label, this.bgColor, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
