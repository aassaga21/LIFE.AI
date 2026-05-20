import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FeaturesGridSection extends StatelessWidget {
  const FeaturesGridSection({super.key});

  static const List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.show_chart,
      iconColor: AppColors.primary,
      bgColor: AppColors.primaryLight,
      title: 'Suivi Continu et Passif',
      description:
          'Enregistrement automatique de vos données de santé sans saisie manuelle. Sommeil, activité, humeur - tout est mesuré en arrière-plan.',
    ),
    _FeatureData(
      icon: Icons.psychology_rounded,
      iconColor: AppColors.purpleDeep,
      bgColor: AppColors.purpleLight2,
      title: 'IA Prédictive Avancée',
      description:
          'Notre intelligence artificielle analyse vos patterns et détecte les déséquilibres 2-3 semaines avant les symptômes visibles.',
    ),
    _FeatureData(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.orangeVibrant,
      bgColor: AppColors.orangeLight,
      title: 'Alertes Préventives',
      description:
          'Recevez des notifications intelligentes quand un risque est détecté : burnout, fatigue chronique, stress accumulé.',
    ),
    _FeatureData(
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: AppColors.green,
      bgColor: AppColors.greenLight,
      title: 'Coaching IA Personnalisé',
      description:
          'Un assistant santé disponible 24/7 qui répond à vos questions et vous guide vers de meilleures habitudes.',
    ),
    _FeatureData(
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.purpleDeep,
      bgColor: AppColors.purpleLight2,
      title: 'Analyses Approfondies',
      description:
          'Visualisez vos tendances de santé sur des semaines et des mois. Identifiez les corrélations entre vos habitudes et votre bien-être.',
    ),
    _FeatureData(
      icon: Icons.my_location_rounded,
      iconColor: AppColors.rose,
      bgColor: AppColors.roseLight,
      title: 'Recommandations Actionnables',
      description:
          'Des conseils concrets et personnalisés adaptés à votre profil unique et à votre contexte de vie.',
    ),
    _FeatureData(
      icon: Icons.watch_rounded,
      iconColor: AppColors.cyan,
      bgColor: AppColors.cyanLight,
      title: 'Intégration Wearables',
      description:
          'Compatible avec Apple Watch, Fitbit, Garmin, Samsung et tous les appareils connectés majeurs.',
    ),
    _FeatureData(
      icon: Icons.security_rounded,
      iconColor: AppColors.red,
      bgColor: AppColors.roseLight,
      title: 'Sécurité & Confidentialité',
      description:
          'Chiffrement de bout en bout, conformité RGPD, vos données de santé restent privées et sécurisées.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final isMedium = width > 600;
    final crossAxisCount = isWide ? 3 : (isMedium ? 2 : 1);
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: isWide ? 1.3 : (isMedium ? 1.2 : 2.0),
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) => _FeatureCard(_features[index]),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard(this.data);

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
