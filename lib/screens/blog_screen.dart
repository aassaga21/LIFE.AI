import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';
import '../widgets/sections/blog_hero_section.dart';
import '../widgets/sections/blog_posts_section.dart';
import '../widgets/sections/footer_section.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const Navbar(currentRoute: '/blog'),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      BlogHeroSection(),
                      BlogPostsSection(),
                      _NewsletterSection(),
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
                _FloatingBtn(
                  icon: Icons.phone_android_rounded,
                  label: 'App Mobile',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                _FloatingBtn(
                  icon: Icons.settings_rounded,
                  label: 'Admin',
                  color: AppColors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Newsletter ───────────────────────────────────────────────────────

class _NewsletterSection extends StatelessWidget {
  const _NewsletterSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: AppColors.primaryLight,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 64,
      ),
      child: Column(
        children: [
          const Text(
            'Restez Informé',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recevez nos meilleurs articles sur la santé préventive chaque semaine',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.grayText),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isWide ? 500 : double.infinity,
            child: Row(
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
                        hintText: 'Votre adresse email',
                        hintStyle: TextStyle(
                            color: AppColors.grayText, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
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
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'S\'abonner',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
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

  const _FloatingBtn({
    required this.icon,
    required this.label,
    required this.color,
  });

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
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
