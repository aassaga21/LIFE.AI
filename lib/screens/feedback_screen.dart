import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/sections/footer_section.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const Navbar(currentRoute: '/feedback'),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      _FeedbackHero(),
                      _RatingStats(),
                      _FeedbackForm(),
                      _ReviewsGrid(),
                      FooterSection(),
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

class _FeedbackHero extends StatelessWidget {
  const _FeedbackHero();

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
                  Icon(Icons.star_rounded,
                      color: AppColors.yellow, size: 16),
                  SizedBox(width: 6),
                  Text('Avis Utilisateurs',
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
              'Vos Avis & Témoignages',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Partagez votre expérience et aidez d\'autres personnes\nà prendre soin de leur santé en avance',
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

// ─── Stats de notation ────────────────────────────────────────────────────────

class _RatingStats extends StatelessWidget {
  const _RatingStats();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 48),
      child: AnimatedEntrance(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RatingStat('4.8', 'Note moyenne', Icons.star_rounded,
                AppColors.yellow),
            _divider(),
            _RatingStat('2 000+', 'Avis utilisateurs',
                Icons.people_rounded, AppColors.primary),
            _divider(),
            _RatingStat('98%', 'Recommandent\nLIFE.AI',
                Icons.thumb_up_rounded, AppColors.green),
            if (isWide) ...[
              _divider(),
              _RatingStat('24h', 'Délai moyen de\nréponse équipe',
                  Icons.support_agent_rounded, AppColors.purple),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        color: AppColors.border,
      );
}

class _RatingStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _RatingStat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 4),
        Text(value == '4.8'
                ? '★★★★★'
                : '',
            style: const TextStyle(
                fontSize: 14, color: AppColors.yellow)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: AppColors.grayText, height: 1.3)),
      ],
    );
  }
}

// ─── Formulaire d'avis ────────────────────────────────────────────────────────

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm();

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  int _rating = 0;
  String? _category;

  static const List<String> _categories = [
    'Suivi Santé',
    'IA Prédictive',
    'Coaching',
    'Interface',
    'Support',
    'Général',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Donnez Votre Avis',
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
              'Votre retour nous aide à améliorer LIFE.AI chaque jour',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: isWide ? 680 : double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Note en étoiles
                  const Text('Votre note *',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AnimatedScale(
                            scale: _rating > i ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              _rating > i
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: _rating > i
                                  ? AppColors.yellow
                                  : AppColors.border,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_rating > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      ['', 'Très insatisfait', 'Insatisfait',
                          'Neutre', 'Satisfait', 'Très satisfait'][_rating],
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.grayText),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Nom
                  _fLabel('Nom complet *'),
                  const SizedBox(height: 6),
                  _textField('Votre nom'),
                  const SizedBox(height: 16),

                  // Email
                  _fLabel('Email *'),
                  const SizedBox(height: 6),
                  _textField('votre@email.com'),
                  const SizedBox(height: 16),

                  // Catégorie
                  _fLabel('Catégorie'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories
                        .map(
                          (c) => GestureDetector(
                            onTap: () => setState(() => _category = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _category == c
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _category == c
                                        ? AppColors.primary
                                        : AppColors.border),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _category == c
                                        ? Colors.white
                                        : AppColors.grayText),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Témoignage
                  _fLabel('Votre témoignage *'),
                  const SizedBox(height: 6),
                  TextField(
                    maxLines: 5,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.darkText),
                    decoration: InputDecoration(
                      hintText:
                          'Partagez votre expérience avec LIFE.AI...',
                      hintStyle: const TextStyle(
                          color: AppColors.grayText, fontSize: 14),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Publier mon Avis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText));

  Widget _textField(String hint) => TextField(
        style:
            const TextStyle(fontSize: 14, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.grayText, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5)),
        ),
      );
}

// ─── Grille des avis existants ────────────────────────────────────────────────

class _ReviewsGrid extends StatelessWidget {
  const _ReviewsGrid();

  static const List<_Review> _reviews = [
    _Review('Marie L.', 'Directrice Marketing', 5, 'Santé', '"LIFE.AI m\'a alerté d\'un risque de burnout 3 semaines avant que je ne craque. J\'ai pu ajuster mon rythme à temps."', '15 Mai 2026'),
    _Review('Thomas B.', 'Entrepreneur', 5, 'Coaching', '"En tant que parent solo, je jongle constamment. LIFE.AI me donne des conseils simples et adaptés à ma réalité."', '10 Mai 2026'),
    _Review('Sophie M.', 'Infirmière', 5, 'IA Prédictive', '"L\'IA a détecté ma fatigue chronique bien avant que j\'y fasse attention. Les recommandations sont vraiment pertinentes."', '8 Mai 2026'),
    _Review('Antoine R.', 'Dev Senior', 4, 'Interface', '"Interface intuitive et les insights sont très utiles. Le suivi du sommeil a changé ma vie professionnelle."', '5 Mai 2026'),
    _Review('Clara V.', 'RH Manager', 5, 'Général', '"Nous avons déployé LIFE.AI pour 50 employés. La réduction de l\'absentéisme est visible dès le premier mois."', '1 Mai 2026'),
    _Review('Lucas D.', 'Consultant', 5, 'Support', '"Le support est réactif et l\'application s\'améliore constamment. Je recommande à 100%."', '28 Avr. 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMedium = MediaQuery.of(context).size.width > 600;
    final padding = isWide ? 80.0 : 24.0;
    final cols = isWide ? 3 : (isMedium ? 2 : 1);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Ce que Disent Nos Utilisateurs',
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
              'Des milliers de personnes font confiance à LIFE.AI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 48),
          _buildGrid(_reviews, cols),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_Review> items, int cols) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += cols) {
      final rowItems = items.skip(i).take(cols).toList();
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowItems.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: e.key < rowItems.length - 1 ? 16 : 0),
              child: AnimatedEntrance(
                delay: Duration(milliseconds: 100 * (i ~/ cols + e.key)),
                child: HoverCard(child: _ReviewCard(e.value)),
              ),
            ),
          );
        }).toList(),
      ));
      if (i + cols < items.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _Review {
  final String name;
  final String role;
  final int stars;
  final String category;
  final String text;
  final String date;
  const _Review(this.name, this.role, this.stars, this.category, this.text, this.date);
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard(this.review);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(review.stars,
                  (_) => const Icon(Icons.star_rounded, color: AppColors.yellow, size: 18)),
              ...List.generate(5 - review.stars,
                  (_) => const Icon(Icons.star_outline_rounded, color: AppColors.border, size: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(review.category,
                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.text,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.darkText, height: 1.6)),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(review.name[0],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                    Text('${review.role} • ${review.date}',
                        style: const TextStyle(fontSize: 12, color: AppColors.grayText)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FloatingBtn({required this.icon, required this.label, required this.color});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
