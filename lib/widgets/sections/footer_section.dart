import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 48,
      ),
      child: Column(
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _LogoColumn()),
                const SizedBox(width: 40),
                const Expanded(
                  child: _FooterLinks(
                    title: 'Navigation',
                    items: [
                      'Accueil',
                      'Fonctionnalités',
                      'Tarification',
                      'Entreprises',
                      'Blog',
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: _FooterLinks(
                    title: 'Légal',
                    items: [
                      'Mentions légales',
                      'Politique de confidentialité',
                      'Conditions d\'utilisation',
                      'Politique de cookies',
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(child: _ContactColumn()),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LogoColumn(),
                const SizedBox(height: 32),
                const _FooterLinks(
                  title: 'Navigation',
                  items: [
                    'Accueil',
                    'Fonctionnalités',
                    'Tarification',
                    'Entreprises',
                    'Blog',
                  ],
                ),
                const SizedBox(height: 24),
                const _FooterLinks(
                  title: 'Légal',
                  items: [
                    'Mentions légales',
                    'Politique de confidentialité',
                    'Conditions d\'utilisation',
                    'Politique de cookies',
                  ],
                ),
                const SizedBox(height: 24),
                const _ContactColumn(),
              ],
            ),
          const SizedBox(height: 40),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          const Text(
            '© 2026 LIFE.AI. Tous droits réservés.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}

class _LogoColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'LIFE.AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Votre Santé en Avance - Prévenir Avant de Subir',
          style: TextStyle(fontSize: 14, color: AppColors.grayText),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _SocialIcon(Icons.facebook_rounded),
            const SizedBox(width: 8),
            _SocialIcon(Icons.alternate_email),
            const SizedBox(width: 8),
            _SocialIcon(Icons.work_outline),
            const SizedBox(width: 8),
            _SocialIcon(Icons.camera_alt_outlined),
          ],
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: AppColors.grayText),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterLinks({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: const TextStyle(fontSize: 14, color: AppColors.grayText),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 12),
        _ContactItem(Icons.email_outlined, 'contact@life-ai.app'),
        SizedBox(height: 8),
        _ContactItem(Icons.language, 'https://lifeai-app-82hxr.ondigitalocean.app/'),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grayText),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.grayText),
        ),
      ],
    );
  }
}
