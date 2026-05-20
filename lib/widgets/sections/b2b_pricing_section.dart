import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animated_entrance.dart';

class B2bPricingSection extends StatelessWidget {
  const B2bPricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Tarification Entreprise',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Un prix adapté à la taille de votre organisation',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Tiers de prix
                  isWide
                      ? Row(
                          children: const [
                            Expanded(child: _PriceTier('1-50 employés', '50€')),
                            Expanded(child: _PriceTier('51-200 employés', '30€')),
                            Expanded(child: _PriceTier('200+ employés', '15€')),
                          ],
                        )
                      : Column(
                          children: const [
                            _PriceTier('1-50 employés', '50€'),
                            SizedBox(height: 16),
                            _PriceTier('51-200 employés', '30€'),
                            SizedBox(height: 16),
                            _PriceTier('200+ employés', '15€'),
                          ],
                        ),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 20),

                  // Features
                  ...[
                    'Toutes les fonctionnalités Premium pour chaque employé',
                    'Tableau de bord RH avec statistiques anonymisées',
                    'Support dédié et formation des équipes',
                    'Rapports mensuels et analyse ROI',
                  ].map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(f,
                                style: const TextStyle(
                                    fontSize: 15, color: AppColors.darkText)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Facturation annuelle • Remises disponibles pour engagements pluriannuels',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTier extends StatelessWidget {
  final String label;
  final String price;

  const _PriceTier(this.label, this.price);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.grayText,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: price,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText),
              ),
              const TextSpan(
                text: '\n/employé/mois',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grayText,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
