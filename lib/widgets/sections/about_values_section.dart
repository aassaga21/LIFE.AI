import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AboutValuesSection extends StatelessWidget {
  const AboutValuesSection({super.key});

  static const List<_ValueData> _values = [
    _ValueData(
      icon: Icons.shield_rounded,
      iconColor: AppColors.primary,
      bgColor: AppColors.primaryLight,
      title: 'Prévention Avant Tout',
      description:
          'Nous croyons fermement que la meilleure médecine est celle qui anticipe. Chaque fonctionnalité est conçue pour agir avant le problème.',
    ),
    _ValueData(
      icon: Icons.favorite_rounded,
      iconColor: AppColors.rose,
      bgColor: AppColors.roseLight,
      title: 'Technologie Bienveillante',
      description:
          'L\'IA au service de l\'humain, jamais l\'inverse. Nos algorithmes sont entraînés pour conseiller avec empathie, sans alarmisme.',
    ),
    _ValueData(
      icon: Icons.lock_rounded,
      iconColor: AppColors.green,
      bgColor: AppColors.greenLight,
      title: 'Confidentialité & Confiance',
      description:
          'Vos données de santé vous appartiennent. Chiffrement de bout en bout, conformité RGPD totale, aucune vente de données.',
    ),
    _ValueData(
      icon: Icons.science_rounded,
      iconColor: AppColors.purple,
      bgColor: AppColors.purpleLight,
      title: 'Science & Evidence',
      description:
          'Nos recommandations reposent sur des études cliniques validées et des algorithmes entraînés sur plus de 100 000 profils réels.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMedium = MediaQuery.of(context).size.width > 600;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        children: [
          const Text(
            'Nos Valeurs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Les principes qui guident chaque décision chez LIFE.AI',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText),
          ),
          const SizedBox(height: 48),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _values
                  .map((v) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _ValueCard(v),
                        ),
                      ))
                  .toList(),
            )
          else if (isMedium)
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ValueCard(_values[0])),
                    const SizedBox(width: 16),
                    Expanded(child: _ValueCard(_values[1])),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ValueCard(_values[2])),
                    const SizedBox(width: 16),
                    Expanded(child: _ValueCard(_values[3])),
                  ],
                ),
              ],
            )
          else
            Column(
              children: _values
                  .map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ValueCard(v),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ValueData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;

  const _ValueData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
  });
}

class _ValueCard extends StatelessWidget {
  final _ValueData data;

  const _ValueCard(this.data);

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
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
