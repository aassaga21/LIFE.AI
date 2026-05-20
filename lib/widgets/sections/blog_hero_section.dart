import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BlogHeroSection extends StatelessWidget {
  const BlogHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 64,
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article_rounded, color: AppColors.primary, size: 16),
                SizedBox(width: 6),
                Text(
                  'Santé Préventive',
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Blog LIFE.AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Conseils, actualités et insights sur la santé préventive',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grayText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Filtres catégories
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _CategoryChip('Tous', isSelected: true),
              _CategoryChip('IA & Santé'),
              _CategoryChip('Bien-être'),
              _CategoryChip('Prévention'),
              _CategoryChip('Entreprise'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryChip(this.label, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.grayText,
        ),
      ),
    );
  }
}
