import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/sections/pricing_section.dart';
import '../widgets/sections/b2b_pricing_section.dart';
import '../widgets/sections/cta_section.dart';
import '../widgets/sections/footer_section.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const Navbar(currentRoute: '/pricing'),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero
                      _PricingHero(),
                      // Plans individuels
                      const PricingSection(),
                      // Plans entreprise
                      const B2bPricingSection(),
                      // FAQ tarif
                      const _PricingFaq(),
                      const CtaSection(),
                      const FooterSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 600),
                  child: _FloatingBtn(
                      icon: Icons.phone_android_rounded,
                      label: 'App Mobile',
                      color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 700),
                  child: _FloatingBtn(
                      icon: Icons.settings_rounded,
                      label: 'Admin',
                      color: AppColors.purple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _PricingHero extends StatelessWidget {
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
          horizontal: isWide ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          AnimatedEntrance(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.euro_rounded,
                      color: AppColors.primary, size: 16),
                  SizedBox(width: 6),
                  Text('Tarification Transparente',
                      style: TextStyle(
                          color: AppColors.grayText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Tarification',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Des plans adaptés à chaque besoin, sans surprise',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, color: AppColors.grayText, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FAQ Tarification ─────────────────────────────────────────────────────────

class _PricingFaq extends StatelessWidget {
  const _PricingFaq();

  static const List<_FaqItem> _items = [
    _FaqItem('Puis-je changer de plan à tout moment ?',
        'Oui, vous pouvez upgrader ou downgrader votre plan à tout moment. Les changements prennent effet immédiatement et sont proratisés sur votre prochaine facture.'),
    _FaqItem('Y a-t-il une période d\'essai gratuite ?',
        'Oui ! Tous les plans payants bénéficient d\'un essai gratuit de 14 jours, sans carte bancaire requise.'),
    _FaqItem('Comment fonctionne la facturation ?',
        'La facturation est mensuelle ou annuelle (avec 20% de réduction). Vous recevez une facture par email chaque période.'),
    _FaqItem('Mes données sont-elles sécurisées ?',
        'Absolument. Toutes les données sont chiffrées de bout en bout et nous sommes conformes au RGPD. Vos données ne sont jamais vendues.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Questions Fréquentes',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText),
            ),
          ),
          const SizedBox(height: 40),
          ..._items.asMap().entries.map(
                (e) => AnimatedEntrance(
                  delay: Duration(milliseconds: 100 * e.key),
                  child: _FaqTile(e.value),
                ),
              ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile(this.item);

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.grayText),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      color: AppColors.background,
                      child: Text(
                        widget.item.answer,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grayText,
                            height: 1.6),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FloatingBtn(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
