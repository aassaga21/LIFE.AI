import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animated_entrance.dart';

class B2bDemoSection extends StatefulWidget {
  const B2bDemoSection({super.key});

  @override
  State<B2bDemoSection> createState() => _B2bDemoSectionState();
}

class _B2bDemoSectionState extends State<B2bDemoSection> {
  String? _employees;
  static const List<String> _ranges = [
    '1-10 employés',
    '11-50 employés',
    '51-200 employés',
    '201-500 employés',
    '500+ employés',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Demander une Démonstration',
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
              'Nos experts vous contactent sous 24h pour vous présenter LIFE.AI Entreprise',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 48),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 200),
            child: SizedBox(
              width: isWide ? 800 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1 : entreprise + nom
                  isWide
                      ? Row(
                          children: [
                            Expanded(child: _field('Nom de l\'entreprise *')),
                            const SizedBox(width: 16),
                            Expanded(child: _field('Votre nom *')),
                          ],
                        )
                      : Column(
                          children: [
                            _field('Nom de l\'entreprise *'),
                            const SizedBox(height: 16),
                            _field('Votre nom *'),
                          ],
                        ),
                  const SizedBox(height: 16),

                  // Ligne 2 : email + téléphone
                  isWide
                      ? Row(
                          children: [
                            Expanded(child: _field('Email professionnel *')),
                            const SizedBox(width: 16),
                            Expanded(child: _field('Téléphone')),
                          ],
                        )
                      : Column(
                          children: [
                            _field('Email professionnel *'),
                            const SizedBox(height: 16),
                            _field('Téléphone'),
                          ],
                        ),
                  const SizedBox(height: 16),

                  // Nombre d'employés
                  _label('Nombre d\'employés *'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _employees,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Sélectionnez...',
                              style: TextStyle(
                                  color: AppColors.grayText, fontSize: 14)),
                        ),
                        isExpanded: true,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: AppColors.grayText),
                        ),
                        onChanged: (v) => setState(() => _employees = v),
                        items: _ranges
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(r,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.darkText)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message
                  _label('Message'),
                  const SizedBox(height: 6),
                  TextField(
                    maxLines: 5,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.darkText),
                    decoration: InputDecoration(
                      hintText: 'Parlez-nous de vos besoins...',
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

                  // Bouton
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
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
                      child: const Text('Demander une Démonstration'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'En soumettant ce formulaire, vous acceptez d\'être contacté par notre équipe commerciale.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: AppColors.grayText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText));

  Widget _field(String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextField(
            style:
                const TextStyle(fontSize: 14, color: AppColors.darkText),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
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
        ],
      );
}
