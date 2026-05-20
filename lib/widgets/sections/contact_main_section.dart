import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ContactMainSection extends StatelessWidget {
  const ContactMainSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _ContactInfo()),
                const SizedBox(width: 48),
                const Expanded(flex: 7, child: _ContactForm()),
              ],
            )
          : Column(
              children: [
                _ContactInfo(),
                const SizedBox(height: 40),
                const _ContactForm(),
              ],
            ),
    );
  }
}

// ─── Colonne gauche : infos + FAQ ────────────────────────────────────────────

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Restons en Contact',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Nous sommes à votre écoute pour répondre à toutes vos questions sur LIFE.AI, nos fonctionnalités ou nos offres.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.grayText,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        const _ContactItem(
          icon: Icons.email_outlined,
          title: 'Email',
          linkText: 'contact@life-ai.app',
          subtitle: 'Réponse sous 24-48h',
        ),
        const SizedBox(height: 20),
        const _ContactItem(
          icon: Icons.language,
          title: 'Site Web',
          linkText: 'www.life-ai.app',
        ),
        const SizedBox(height: 20),
        const _ContactItem(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Support',
          subtitle: 'Besoin d\'aide technique ? Consultez notre ',
          linkText: 'centre d\'aide',
          subtitleFirst: true,
        ),
        const SizedBox(height: 32),

        // FAQ box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Questions Fréquentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              ...[
                'Comment fonctionne l\'IA prédictive ?',
                'Mes données sont-elles sécurisées ?',
                'Comment annuler mon abonnement ?',
                'Quels appareils sont compatibles ?',
              ].map(
                (q) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      q,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? linkText;
  final bool subtitleFirst;

  const _ContactItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.linkText,
    this.subtitleFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              if (subtitleFirst && subtitle != null)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.grayText),
                    children: [
                      TextSpan(text: subtitle),
                      TextSpan(
                        text: linkText,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                )
              else ...[
                if (linkText != null)
                  Text(
                    linkText!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grayText,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Colonne droite : formulaire ─────────────────────────────────────────────

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  String? _selectedSubject;

  static const List<String> _subjects = [
    'Question générale',
    'Support technique',
    'Partenariat entreprise',
    'Demande de presse',
    'Bug ou problème',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Envoyez-nous un Message',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24),

          // Nom complet
          _fieldLabel('Nom complet *'),
          const SizedBox(height: 6),
          _textField(hintText: ''),
          const SizedBox(height: 16),

          // Email
          _fieldLabel('Email *'),
          const SizedBox(height: 6),
          _textField(hintText: ''),
          const SizedBox(height: 16),

          // Sujet (dropdown)
          _fieldLabel('Sujet *'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubject,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Sélectionnez un sujet',
                    style: TextStyle(
                        color: AppColors.grayText, fontSize: 14),
                  ),
                ),
                isExpanded: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: AppColors.grayText),
                ),
                onChanged: (value) =>
                    setState(() => _selectedSubject = value),
                items: _subjects
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkText)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Message
          _fieldLabel('Message *'),
          const SizedBox(height: 6),
          _textField(
            hintText: 'Décrivez votre demande en détail...',
            maxLines: 5,
          ),
          const SizedBox(height: 24),

          // Bouton envoyer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Envoyer le Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lien politique
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style:
                  TextStyle(fontSize: 13, color: AppColors.grayText),
              children: [
                TextSpan(
                    text:
                        'En soumettant ce formulaire, vous acceptez notre '),
                TextSpan(
                  text: 'politique de confidentialité',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
      );

  Widget _textField({required String hintText, int maxLines = 1}) =>
      TextField(
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              const TextStyle(color: AppColors.grayText, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      );
}
