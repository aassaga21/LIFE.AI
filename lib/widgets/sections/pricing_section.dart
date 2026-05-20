import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

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
            'Tarification Simple et Transparente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Choisissez le plan qui vous convient le mieux',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText),
          ),
          const SizedBox(height: 48),
          isWide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PricingCard(
                        plan: 'Gratuit',
                        price: '0€',
                        period: '/mois',
                        features: [
                          'Suivi basique',
                          '1 alerte par semaine',
                          'Recommandations de base',
                        ],
                        buttonText: 'Commencer Gratuitement',
                        isHighlighted: false,
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _PricingCard(
                        plan: 'Premium',
                        price: '9,99€',
                        period: '/mois',
                        features: [
                          'IA complète',
                          'Alertes illimitées',
                          'Coaching personnalisé',
                          'Analyses approfondies',
                        ],
                        buttonText: 'Commencer l\'essai gratuit',
                        isHighlighted: true,
                        badge: 'Le plus populaire',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _PricingCard(
                        plan: 'Entreprise',
                        price: 'Sur mesure',
                        period: '',
                        features: [
                          'Prévention burnout',
                          'Tableaux de bord RH',
                          'ROI sur absentéisme',
                        ],
                        buttonText: 'Nous contacter',
                        isHighlighted: false,
                      ),
                    ),
                  ],
                )
              : const Column(
                  children: [
                    _PricingCard(
                      plan: 'Gratuit',
                      price: '0€',
                      period: '/mois',
                      features: [
                        'Suivi basique',
                        '1 alerte par semaine',
                        'Recommandations de base',
                      ],
                      buttonText: 'Commencer Gratuitement',
                      isHighlighted: false,
                    ),
                    SizedBox(height: 24),
                    _PricingCard(
                      plan: 'Premium',
                      price: '9,99€',
                      period: '/mois',
                      features: [
                        'IA complète',
                        'Alertes illimitées',
                        'Coaching personnalisé',
                        'Analyses approfondies',
                      ],
                      buttonText: 'Commencer l\'essai gratuit',
                      isHighlighted: true,
                      badge: 'Le plus populaire',
                    ),
                    SizedBox(height: 24),
                    _PricingCard(
                      plan: 'Entreprise',
                      price: 'Sur mesure',
                      period: '',
                      features: [
                        'Prévention burnout',
                        'Tableaux de bord RH',
                        'ROI sur absentéisme',
                      ],
                      buttonText: 'Nous contacter',
                      isHighlighted: false,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String plan;
  final String price;
  final String period;
  final List<String> features;
  final String buttonText;
  final bool isHighlighted;
  final String? badge;

  const _PricingCard({
    required this.plan,
    required this.price,
    required this.period,
    required this.features,
    required this.buttonText,
    required this.isHighlighted,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(24, badge != null ? 36 : 24, 24, 24),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: isHighlighted ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  if (period.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 16,
                          color: isHighlighted
                              ? Colors.white70
                              : AppColors.grayText,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: TextStyle(
                          fontSize: 14,
                          color: isHighlighted
                              ? Colors.white
                              : AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isHighlighted
                        ? AppColors.primary
                        : AppColors.darkText,
                    backgroundColor:
                        isHighlighted ? Colors.white : Colors.transparent,
                    side: BorderSide(
                      color: isHighlighted ? Colors.transparent : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
