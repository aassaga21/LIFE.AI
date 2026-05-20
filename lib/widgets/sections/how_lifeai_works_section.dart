import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HowLifeAIWorksSection extends StatelessWidget {
  const HowLifeAIWorksSection({super.key});

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
            'Comment LIFE.AI Fonctionne',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Une technologie sophistiquée rendue simple',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText),
          ),
          const SizedBox(height: 56),

          const _Step(
            number: '1',
            title: 'Collecte de Données Passive',
            paragraphs: [
              'LIFE.AI se connecte à vos appareils (smartphone, montre connectée) et collecte automatiquement vos données de santé : sommeil, activité physique, fréquence cardiaque, humeur quotidienne.',
              'Aucune saisie manuelle fastidieuse - tout se fait en arrière-plan pendant que vous vivez votre vie normalement.',
            ],
          ),
          const SizedBox(height: 40),

          const _Step(
            number: '2',
            title: 'Analyse Prédictive par IA',
            paragraphs: [
              'Notre algorithme d\'intelligence artificielle, entraîné sur plus de 100 000 profils de santé, analyse vos patterns comportementaux en temps réel.',
              'Il détecte les signaux faibles : baisse progressive de la qualité du sommeil, augmentation du stress, diminution de l\'activité - des indicateurs que vous ne remarqueriez pas seul.',
            ],
          ),
          const SizedBox(height: 40),

          const _Step(
            number: '3',
            title: 'Alertes Préventives Intelligentes',
            paragraphs: [
              'Quand un risque est identifié, vous recevez une alerte préventive claire et non alarmiste, 2 à 3 semaines avant que les symptômes ne deviennent problématiques.',
              'Exemple : "Votre pattern de sommeil suggère un risque de fatigue chronique dans 2 semaines si non corrigé."',
            ],
          ),
          const SizedBox(height: 40),

          const _Step(
            number: '4',
            title: 'Recommandations Personnalisées',
            paragraphs: [
              'Pour chaque alerte, LIFE.AI vous propose des actions concrètes et réalistes adaptées à votre profil : exercices de respiration, ajustement des horaires de coucher, pauses régulières.',
              'Notre coaching IA est disponible 24/7 pour répondre à vos questions et vous accompagner dans vos changements.',
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String title;
  final List<String> paragraphs;

  const _Step({
    required this.number,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numéro bleu
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Texte
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 10),
              ...paragraphs.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    p,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.grayText,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
