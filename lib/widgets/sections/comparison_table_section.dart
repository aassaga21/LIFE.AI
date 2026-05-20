import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ComparisonTableSection extends StatelessWidget {
  const ComparisonTableSection({super.key});

  static const List<String> _competitors = [
    'MyFitnessPal',
    'Apple Health',
    'Doctolib',
  ];

  static const List<_CompRow> _rows = [
    _CompRow('IA Prédictive', [true, false, false, false]),
    _CompRow('Coaching IA 24/7', [true, false, false, false]),
    _CompRow('Santé Préventive', [true, false, false, false]),
    _CompRow('Détection Burnout', [true, false, false, false]),
    _CompRow('Prix', null,
        customValues: ['9,99€/mois', '9,99€/mois', 'Gratuit', 'Gratuit']),
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
          const Text(
            'Pourquoi Choisir LIFE.AI ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Comparaison avec les principales solutions du marché',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grayText),
          ),
          const SizedBox(height: 48),

          // Tableau
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // En-tête
                  Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'Fonctionnalité',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              'LIFE.AI',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        ..._competitors.map(
                          (c) => Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                c,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lignes
                  ..._rows.asMap().entries.map(
                        (entry) => _TableRow(
                          row: entry.value,
                          isLast: entry.key == _rows.length - 1,
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
}

class _CompRow {
  final String feature;
  final List<bool>? supported;
  final List<String>? customValues;

  const _CompRow(this.feature, this.supported, {this.customValues});
}

class _TableRow extends StatelessWidget {
  final _CompRow row;
  final bool isLast;

  const _TableRow({required this.row, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  row.feature,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              // LIFE.AI column
              Expanded(
                flex: 2,
                child: Center(
                  child: row.customValues != null
                      ? Text(
                          row.customValues![0],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Icon(
                          row.supported![0]
                              ? Icons.check
                              : Icons.close,
                          color: row.supported![0]
                              ? AppColors.green
                              : AppColors.border,
                          size: 20,
                        ),
                ),
              ),
              // Competitors columns
              ...List.generate(3, (i) {
                final colIndex = i + 1;
                return Expanded(
                  flex: 2,
                  child: Center(
                    child: row.customValues != null
                        ? Text(
                            row.customValues![colIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grayText,
                            ),
                          )
                        : Icon(
                            row.supported![colIndex]
                                ? Icons.check
                                : Icons.close,
                            color: row.supported![colIndex]
                                ? AppColors.green
                                : const Color(0xFFCBD5E1),
                            size: 20,
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
