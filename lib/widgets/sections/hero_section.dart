import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final h = isWide ? 80.0 : 48.0;
    final v = isWide ? 80.0 : 48.0;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: _HeroText()),
                const SizedBox(width: 56),
                Expanded(child: _ScoreCard()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroText(),
                const SizedBox(height: 40),
                _ScoreCard(),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, color: AppColors.primary, size: 16),
              SizedBox(width: 4),
              Text(
                'IA Préventive de Santé',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Titre principal
        const Text(
          'Votre Santé\nen Avance',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),

        // Sous-titre
        const Text(
          'Prévenir Avant de Subir',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.grayText,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),

        // Description
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grayText,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text:
                    'LIFE.AI analyse vos habitudes de vie et détecte les déséquilibres ',
              ),
              TextSpan(
                text: '2-3 semaines avant',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              TextSpan(
                text:
                    ' les symptômes visibles. Votre médecin préventif dans votre poche 24/7, sans rendez-vous ni jugement.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Champ email + bouton
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Votre email',
                    hintStyle: TextStyle(color: AppColors.grayText, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rejoindre la bêta',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Text(
          'Gratuit pendant la période bêta • Sans engagement',
          style: TextStyle(fontSize: 13, color: AppColors.grayText),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score de Bien-être',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  '89%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Barres de progression
            const _ProgressBar(
              label: 'Sommeil',
              value: 0.85,
              percentage: '85%',
              color: AppColors.green,
            ),
            const SizedBox(height: 14),
            const _ProgressBar(
              label: 'Activité',
              value: 0.92,
              percentage: '92%',
              color: AppColors.green,
            ),
            const SizedBox(height: 14),
            const _ProgressBar(
              label: 'Stress',
              value: 0.78,
              percentage: '78%',
              color: AppColors.orange,
            ),
            const SizedBox(height: 20),

            // Alerte préventive
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alerte Préventive',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pattern de stress détecté. Risque de fatigue dans 2 semaines si non corrigé.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final String percentage;
  final Color color;

  const _ProgressBar({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.grayText),
            ),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
