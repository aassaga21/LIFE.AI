import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BlogPostsSection extends StatelessWidget {
  const BlogPostsSection({super.key});

  static const List<_ArticleData> _articles = [
    _ArticleData(
      gradientColors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
      category: 'IA & Santé',
      categoryColor: AppColors.primary,
      categoryBg: AppColors.primaryLight,
      title: 'Comment l\'IA détecte le burnout 3 semaines à l\'avance',
      excerpt:
          'Découvrez comment nos algorithmes analysent des centaines de signaux invisibles pour prédire les risques de burnout bien avant que vous ne les ressentiez.',
      author: 'Alexandra A.',
      date: '15 Mai 2026',
      readTime: '5 min',
      isFeatured: true,
    ),
    _ArticleData(
      gradientColors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
      category: 'Bien-être',
      categoryColor: AppColors.green,
      categoryBg: AppColors.greenLight,
      title: '5 habitudes pour améliorer votre sommeil dès cette semaine',
      excerpt:
          'Le sommeil est le pilier de la santé préventive. Voici 5 changements simples que vous pouvez mettre en place ce soir pour des résultats visibles rapidement.',
      author: 'Léa M.',
      date: '10 Mai 2026',
      readTime: '4 min',
    ),
    _ArticleData(
      gradientColors: [Color(0xFFF97316), Color(0xFFF59E0B)],
      category: 'Prévention',
      categoryColor: AppColors.orangeVibrant,
      categoryBg: AppColors.orangeLight,
      title: 'Le stress chronique : comprendre pour mieux prévenir',
      excerpt:
          'Le stress chronique touche 76% des actifs. Apprenez à reconnaître ses signaux précoces et les stratégies éprouvées pour y faire face.',
      author: 'Brayan W.',
      date: '5 Mai 2026',
      readTime: '6 min',
    ),
    _ArticleData(
      gradientColors: [Color(0xFF9333EA), Color(0xFFE11D48)],
      category: 'Entreprise',
      categoryColor: AppColors.purple,
      categoryBg: AppColors.purpleLight,
      title: 'LIFE.AI en entreprise : retour d\'expérience après 3 mois',
      excerpt:
          'Une PME de 80 salariés témoigne de son expérience avec LIFE.AI Entreprise : -34% d\'absentéisme et une équipe plus sereine.',
      author: 'Melvin M.',
      date: '28 Avr. 2026',
      readTime: '7 min',
    ),
    _ArticleData(
      gradientColors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
      category: 'IA & Santé',
      categoryColor: AppColors.primary,
      categoryBg: AppColors.primaryLight,
      title: 'Wearables et santé : quel appareil connecté choisir en 2026 ?',
      excerpt:
          'Apple Watch, Fitbit, Garmin, Whoop : on compare les meilleurs wearables compatibles LIFE.AI pour maximiser votre suivi de santé.',
      author: 'Alexandra A.',
      date: '20 Avr. 2026',
      readTime: '8 min',
    ),
    _ArticleData(
      gradientColors: [Color(0xFFEF4444), Color(0xFFF97316)],
      category: 'Prévention',
      categoryColor: AppColors.orangeVibrant,
      categoryBg: AppColors.orangeLight,
      title: 'Fatigue chronique : les signaux que vous ignorez probablement',
      excerpt:
          '1 personne sur 2 souffre de fatigue chronique non diagnostiquée. Nos experts décryptent les 7 signaux d\'alerte à ne surtout pas ignorer.',
      author: 'Brayan W.',
      date: '12 Avr. 2026',
      readTime: '5 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMedium = MediaQuery.of(context).size.width > 600;
    final padding = isWide ? 80.0 : 24.0;

    final featured = _articles.first;
    final rest = _articles.skip(1).toList();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article à la une
          _FeaturedCard(featured),
          const SizedBox(height: 48),

          // Titre grille
          const Text(
            'Derniers Articles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24),

          // Grille articles
          if (isWide)
            _buildGrid(rest, 3)
          else if (isMedium)
            _buildGrid(rest, 2)
          else
            Column(
              children: rest
                  .map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _ArticleCard(a),
                      ))
                  .toList(),
            ),

          const SizedBox(height: 48),

          // Bouton voir plus
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'Voir tous les articles',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_ArticleData> articles, int columns) {
    final rows = <Widget>[];
    for (var i = 0; i < articles.length; i += columns) {
      final rowItems = articles.skip(i).take(columns).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowItems.asMap().entries.map((e) {
            final isLast = e.key == rowItems.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 24),
                child: _ArticleCard(e.value),
              ),
            );
          }).toList(),
        ),
      );
      if (i + columns < articles.length) rows.add(const SizedBox(height: 24));
    }
    return Column(children: rows);
  }
}

// ─── Article à la une ────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final _ArticleData article;

  const _FeaturedCard(this.article);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 5, child: _GradientImage(article, height: 280)),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _ArticleContent(article, isFeatured: true),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _GradientImage(article, height: 200),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _ArticleContent(article, isFeatured: true),
                ),
              ],
            ),
    );
  }
}

// ─── Carte article standard ───────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final _ArticleData article;

  const _ArticleCard(this.article);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientImage(article, height: 160),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _ArticleContent(article),
          ),
        ],
      ),
    );
  }
}

// ─── Image dégradé placeholder ───────────────────────────────────────────────

class _GradientImage extends StatelessWidget {
  final _ArticleData article;
  final double height;

  const _GradientImage(this.article, {required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: article.gradientColors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          color: Colors.white.withAlpha(80),
          size: 64,
        ),
      ),
    );
  }
}

// ─── Contenu texte article ────────────────────────────────────────────────────

class _ArticleContent extends StatelessWidget {
  final _ArticleData article;
  final bool isFeatured;

  const _ArticleContent(this.article, {this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge catégorie
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: article.categoryBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            article.category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: article.categoryColor,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Titre
        Text(
          article.title,
          style: TextStyle(
            fontSize: isFeatured ? 22 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),

        // Extrait
        Text(
          article.excerpt,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grayText,
            height: 1.6,
          ),
          maxLines: isFeatured ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),

        // Auteur + date + temps de lecture
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                article.author[0],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              article.author,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(width: 8),
            const Text('·',
                style: TextStyle(color: AppColors.grayText)),
            const SizedBox(width: 8),
            Text(
              article.date,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.grayText),
            ),
            const SizedBox(width: 8),
            const Text('·',
                style: TextStyle(color: AppColors.grayText)),
            const SizedBox(width: 8),
            Text(
              article.readTime,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.grayText),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Modèle données article ───────────────────────────────────────────────────

class _ArticleData {
  final List<Color> gradientColors;
  final String category;
  final Color categoryColor;
  final Color categoryBg;
  final String title;
  final String excerpt;
  final String author;
  final String date;
  final String readTime;
  final bool isFeatured;

  const _ArticleData({
    required this.gradientColors,
    required this.category,
    required this.categoryColor,
    required this.categoryBg,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.date,
    required this.readTime,
    this.isFeatured = false,
  });
}
