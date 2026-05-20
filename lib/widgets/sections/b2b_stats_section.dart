import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animated_entrance.dart';

class B2bStatsSection extends StatelessWidget {
  const B2bStatsSection({super.key});

  static const List<_StatData> _stats = [
    _StatData(
      icon: Icons.trending_down_rounded,
      value: '-34%',
      title: 'Réduction de l\'Absentéisme',
      description: 'Diminution moyenne de l\'absentéisme grâce à la prévention précoce',
    ),
    _StatData(
      icon: Icons.monitor_heart_rounded,
      value: '89%',
      title: 'Prévention du Burnout',
      description: 'Taux de détection du burnout avant la phase critique',
    ),
    _StatData(
      icon: Icons.group_rounded,
      value: '+42%',
      title: 'Engagement des Équipes',
      description: 'Amélioration de l\'engagement et de la satisfaction des employés',
    ),
    _StatData(
      icon: Icons.bar_chart_rounded,
      value: '3.5x',
      title: 'ROI Mesurable',
      description: 'Retour sur investissement moyen sur 12 mois',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMedium = MediaQuery.of(context).size.width > 600;
    final padding = isWide ? 80.0 : 24.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
      child: Column(
        children: [
          AnimatedEntrance(
            child: const Text(
              'Des Résultats Mesurables',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedEntrance(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Les entreprises qui utilisent LIFE.AI constatent des améliorations significatives',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 48),
          if (isWide)
            Row(
              children: _stats.asMap().entries.map((e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: e.key < 3 ? 16 : 0),
                  child: AnimatedEntrance(
                    delay: Duration(milliseconds: 150 * e.key),
                    child: HoverCard(child: _StatCard(e.value)),
                  ),
                ),
              )).toList(),
            )
          else if (isMedium)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 100), child: HoverCard(child: _StatCard(_stats[0])))),
                    const SizedBox(width: 16),
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 200), child: HoverCard(child: _StatCard(_stats[1])))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 300), child: HoverCard(child: _StatCard(_stats[2])))),
                    const SizedBox(width: 16),
                    Expanded(child: AnimatedEntrance(delay: const Duration(milliseconds: 400), child: HoverCard(child: _StatCard(_stats[3])))),
                  ],
                ),
              ],
            )
          else
            Column(
              children: _stats.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedEntrance(
                  delay: Duration(milliseconds: 100 * e.key),
                  child: HoverCard(child: _StatCard(e.value)),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String title;
  final String description;

  const _StatData({
    required this.icon,
    required this.value,
    required this.title,
    required this.description,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grayText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
