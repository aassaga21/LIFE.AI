import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProblemSection extends StatelessWidget {
  const ProblemSection({super.key});

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
            'Le Problème que Nous Résolvons',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'La santé moderne est réactive, pas préventive.\nOn attend d\'être malade pour agir.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText, height: 1.5),
          ),
          const SizedBox(height: 56),
          isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _stats(),
                )
              : Column(
                  children: _stats()
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: w,
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  List<Widget> _stats() => [
        const _StatItem(
          value: '76%',
          title: 'Stress Chronique',
          description: 'des actifs français se sentent stressés au quotidien',
        ),
        const _StatItem(
          value: '1/2',
          title: 'Fatigue Chronique',
          description:
              'des personnes souffrent de fatigue chronique non diagnostiquée',
        ),
        const _StatItem(
          value: '3Md€',
          title: 'Coût du Burnout',
          description:
              'coût annuel du burnout pour les entreprises françaises',
        ),
      ];
}

class _StatItem extends StatelessWidget {
  final String value;
  final String title;
  final String description;

  const _StatItem({
    required this.value,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
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
        const SizedBox(height: 8),
        SizedBox(
          width: 220,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grayText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
