import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animated_entrance.dart';

class B2bHeroSection extends StatelessWidget {
  const B2bHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 80 : 48,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _HeroText()),
                const SizedBox(width: 56),
                Expanded(child: _BurnoutCard()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroText(),
                const SizedBox(height: 40),
                _BurnoutCard(),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        AnimatedEntrance(
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_center_rounded,
                    color: AppColors.primary, size: 16),
                SizedBox(width: 6),
                Text(
                  'Solution B2B',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Titre
        AnimatedEntrance(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            'Investissez dans le\nBien-être de Vos Équipes',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        AnimatedEntrance(
          delay: const Duration(milliseconds: 300),
          child: const Text(
            'LIFE.AI Entreprise : La solution de prévention santé qui réduit l\'absentéisme et améliore la performance de vos équipes.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grayText,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Boutons
        AnimatedEntrance(
          delay: const Duration(milliseconds: 400),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: const Text('Demander une Démo'),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkText,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: const Text('Nous Contacter'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BurnoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withAlpha(8),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Le Coût du Burnout en France',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),

            _BurnoutStat('3Md€', 'par an',
                'Coût total du burnout pour les entreprises françaises'),
            const SizedBox(height: 20),
            _BurnoutStat('480k€', 'en moyenne',
                'Coût d\'un burnout pour une entreprise de 100 personnes'),

            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            const Text(
              'LIFE.AI permet de détecter et prévenir ces situations avant qu\'il ne soit trop tard.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurnoutStat extends StatelessWidget {
  final String value;
  final String period;
  final String description;

  const _BurnoutStat(this.value, this.period, this.description);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                period,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.grayText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 13, color: AppColors.grayText),
        ),
      ],
    );
  }
}
