import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/checkin_model.dart';
import '../../../theme/app_colors.dart';

/// Graphique du score de fatigue sur 30 jours avec fl_chart
class FatigueChart extends StatefulWidget {
  /// Check-ins des 30 derniers jours (tous ordres acceptés)
  final List<CheckIn> checkins;

  const FatigueChart({super.key, required this.checkins});

  @override
  State<FatigueChart> createState() => _FatigueChartState();
}

class _FatigueChartState extends State<FatigueChart> {
  final _repaintKey = GlobalKey();
  bool _exporting = false;

  // ── DONNÉES ─────────────────────────────────────────────────────────────────

  /// Convertit les check-ins en FlSpot (x = jour 0..29, y = fatigue 0..100)
  List<FlSpot> _buildDataSpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (final c in widget.checkins) {
      final daysAgo = now.difference(c.date).inDays;
      if (daysAgo > 29) continue;
      final x = (29 - daysAgo).toDouble();
      final y = (c.scoreFatigue * 10).clamp(0.0, 100.0);
      spots.add(FlSpot(x, y));
    }

    spots.sort((a, b) => a.x.compareTo(b.x));
    // Dédoublonne les x (garde le plus récent pour le même jour)
    final seen = <double>{};
    return spots.reversed
        .where((s) => seen.add(s.x))
        .toList()
        .reversed
        .toList();
  }

  /// Moyenne glissante sur 7 jours — ligne de comparaison pointillée
  List<FlSpot> _buildAverageSpots(List<FlSpot> data) {
    return data.map((spot) {
      final window =
          data.where((s) => s.x >= spot.x - 6 && s.x <= spot.x).toList();
      final avg =
          window.map((s) => s.y).reduce((a, b) => a + b) / window.length;
      return FlSpot(spot.x, avg);
    }).toList();
  }

  // ── EXPORT PNG ───────────────────────────────────────────────────────────────

  Future<void> _exportImage() async {
    setState(() => _exporting = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = Uint8List.view(byteData.buffer);
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'fatigue_chart.png', mimeType: 'image/png')],
        subject: 'Mon graphique fatigue LIFE.AI',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── HELPERS CHART ────────────────────────────────────────────────────────────

  /// Ligne invisible pour délimiter les zones colorées
  LineChartBarData _zoneLine(List<FlSpot> spots) => LineChartBarData(
        spots: spots,
        isCurved: false,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (v, _) {
            if (v != 0 && v != 40 && v != 70 && v != 100) {
              return const SizedBox.shrink();
            }
            return Text('${v.toInt()}',
                style: const TextStyle(
                    fontSize: 9, color: AppColors.grayText));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 7,
          getTitlesWidget: (v, _) {
            final date = DateTime.now()
                .subtract(Duration(days: 29 - v.toInt()));
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DateFormat('dd/MM').format(date),
                style: const TextStyle(
                    fontSize: 9, color: AppColors.grayText),
              ),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => AppColors.darkText,
        tooltipRoundedRadius: 8,
        getTooltipItems: (spots) => spots.map((s) {
          // Indice 4 = ligne de données principale
          if (s.barIndex != 4) return null;
          final date = DateTime.now()
              .subtract(Duration(days: 29 - s.x.toInt()));
          final label = s.y > 70
              ? 'Élevé'
              : s.y > 40
                  ? 'Modéré'
                  : 'Bon';
          return LineTooltipItem(
            '${DateFormat('dd MMM').format(date)}\n'
            'Fatigue : ${s.y.round()}/100\n$label',
            const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          );
        }).toList(),
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dataSpots = _buildDataSpots();
    final isWide = MediaQuery.of(context).size.width > 800;
    final chartHeight = isWide ? 280.0 : 200.0;

    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            dataSpots.isEmpty
                ? _buildEmptyState(chartHeight)
                : _buildChart(dataSpots, chartHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courbe de fatigue',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.darkText),
            ),
            Text(
              '30 derniers jours',
              style: TextStyle(fontSize: 12, color: AppColors.grayText),
            ),
          ],
        ),
        IconButton(
          onPressed: _exporting ? null : _exportImage,
          icon: _exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined,
                  color: AppColors.grayText),
          tooltip: 'Exporter le graphique',
        ),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> dataSpots, double height) {
    final avgSpots = _buildAverageSpots(dataSpots);
    final lastY = dataSpots.last.y;
    final mainColor = lastY > 70
        ? AppColors.red
        : lastY > 40
            ? AppColors.orange
            : AppColors.green;

    // Bornes des zones (invisibles — servent à betweenBarsData)
    List<FlSpot> zone(double y) =>
        List.generate(30, (i) => FlSpot(i.toDouble(), y));

    return SizedBox(
      height: height,
      child: LineChart(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        LineChartData(
          minX: 0,
          maxX: 29,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            _zoneLine(zone(0)),   // index 0 — borne basse
            _zoneLine(zone(40)),  // index 1 — vert/orange
            _zoneLine(zone(70)),  // index 2 — orange/rouge
            _zoneLine(zone(100)), // index 3 — borne haute
            // index 4 — données réelles
            LineChartBarData(
              spots: dataSpots,
              isCurved: true,
              color: mainColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: mainColor.withValues(alpha: 0.08),
              ),
            ),
            // index 5 — moyenne glissante (pointillée)
            LineChartBarData(
              spots: avgSpots,
              isCurved: true,
              color: AppColors.grayText.withValues(alpha: 0.5),
              barWidth: 1.5,
              dashArray: [6, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 0,
              toIndex: 1,
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
            ),
            BetweenBarsData(
              fromIndex: 1,
              toIndex: 2,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            ),
            BetweenBarsData(
              fromIndex: 2,
              toIndex: 3,
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
            ),
          ],
          titlesData: _buildTitles(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: _buildTouchData(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double height) {
    return SizedBox(
      height: height,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              'Complétez votre premier check-in\npour voir votre courbe',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grayText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
