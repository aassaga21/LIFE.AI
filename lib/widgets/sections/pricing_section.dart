import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/payment_service.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _subscriptionStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _subscriptionStream(),
      builder: (context, snapshot) {
        final isPremium =
            snapshot.data?.data()?['subscription'] == 'PREMIUM';

        final premiumAction = isPremium
            ? const _PremiumActiveBadge()
            : const _PayButton();

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
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PricingCard(
                            plan: 'Gratuit',
                            price: '0€',
                            period: '/mois',
                            features: const [
                              'Suivi basique',
                              '1 alerte par semaine',
                              'Recommandations de base',
                            ],
                            isHighlighted: false,
                            buttonText: 'Commencer Gratuitement',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _PricingCard(
                            plan: 'Premium',
                            price: '9,99€',
                            period: '/mois',
                            features: const [
                              'IA complète',
                              'Alertes illimitées',
                              'Coaching personnalisé',
                              'Analyses approfondies',
                            ],
                            isHighlighted: true,
                            badge: 'Le plus populaire',
                            customAction: premiumAction,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _PricingCard(
                            plan: 'Entreprise',
                            price: 'Sur mesure',
                            period: '',
                            features: const [
                              'Prévention burnout',
                              'Tableaux de bord RH',
                              'ROI sur absentéisme',
                            ],
                            isHighlighted: false,
                            buttonText: 'Nous contacter',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _PricingCard(
                          plan: 'Gratuit',
                          price: '0€',
                          period: '/mois',
                          features: const [
                            'Suivi basique',
                            '1 alerte par semaine',
                            'Recommandations de base',
                          ],
                          isHighlighted: false,
                          buttonText: 'Commencer Gratuitement',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 24),
                        _PricingCard(
                          plan: 'Premium',
                          price: '9,99€',
                          period: '/mois',
                          features: const [
                            'IA complète',
                            'Alertes illimitées',
                            'Coaching personnalisé',
                            'Analyses approfondies',
                          ],
                          isHighlighted: true,
                          badge: 'Le plus populaire',
                          customAction: premiumAction,
                        ),
                        const SizedBox(height: 24),
                        _PricingCard(
                          plan: 'Entreprise',
                          price: 'Sur mesure',
                          period: '',
                          features: const [
                            'Prévention burnout',
                            'Tableaux de bord RH',
                            'ROI sur absentéisme',
                          ],
                          isHighlighted: false,
                          buttonText: 'Nous contacter',
                          onPressed: () {},
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Premium action widgets ───────────────────────────────────────────────────

class _PremiumActiveBadge extends StatelessWidget {
  const _PremiumActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.green),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
          SizedBox(width: 8),
          Text(
            'Plan Premium actif ✅',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Connectez-vous pour souscrire au plan Premium'),
              ),
            );
            return;
          }
          try {
            await PaymentService.startCheckout();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur : $e')),
              );
            }
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Passer en Premium',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Pricing card ─────────────────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  final String plan;
  final String price;
  final String period;
  final List<String> features;
  final bool isHighlighted;
  final String? badge;
  final String? buttonText;
  final VoidCallback? onPressed;
  final Widget? customAction;

  const _PricingCard({
    required this.plan,
    required this.price,
    required this.period,
    required this.features,
    required this.isHighlighted,
    this.badge,
    this.buttonText,
    this.onPressed,
    this.customAction,
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
                  color:
                      isHighlighted ? Colors.white : AppColors.darkText,
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
                      color: isHighlighted
                          ? Colors.white
                          : AppColors.darkText,
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
              customAction ??
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isHighlighted
                            ? AppColors.primary
                            : AppColors.darkText,
                        backgroundColor: isHighlighted
                            ? Colors.white
                            : Colors.transparent,
                        side: BorderSide(
                          color: isHighlighted
                              ? Colors.transparent
                              : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        buttonText ?? '',
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
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
