import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/checkin_model.dart';
import '../../../theme/app_colors.dart';

class FatigueChart extends StatefulWidget {
  final List<CheckIn> checkins;
  const FatigueChart({super.key, required this.checkins});

  @override
  State<FatigueChart> createState() => _FatigueChartState();
}

class _FatigueChartState extends State<FatigueChart> {
  final _repaintKey = GlobalKey();
  bool _exporting = false;
  int? _touchedIndex;

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
    final seen = <double>{};
    return spots.reversed
        .where((s) => seen.add(s.x))
        .toList()
        .reversed
        .toList();
  }

  List<FlSpot> _buildAverageSpots(List<FlSpot> data) {
    return data.map((spot) {
      final window =
          data.where((s) => s.x >= spot.x - 6 && s.x <= spot.x).toList();
      final avg =
          window.map((s) => s.y).reduce((a, b) => a + b) / window.length;
      return FlSpot(spot.x, avg);
    }).toList();
  }

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

  Color _colorForValue(double y) {
    if (y > 70) return AppColors.red;
    if (y > 40) return AppColors.orange;
    return AppColors.green;
  }

  String _labelForValue(double y) {
    if (y > 70) return 'Élevé';
    if (y > 40) return 'Modéré';
    return 'Bon';
  }

  LineChartBarData _zoneLine(List<FlSpot> spots) => LineChartBarData(
        spots: spots,
        isCurved: false,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );

  List<FlSpot> _zone(double y) =>
      List.generate(30, (i) => FlSpot(i.toDouble(), y));

  @override
  Widget build(BuildContext context) {
    final dataSpots = _buildDataSpots();
    final isWide = MediaQuery.of(context).size.width > 800;
    final chartHeight = isWide ? 280.0 : 220.0;

    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(dataSpots),
            const SizedBox(height: 8),
            if (dataSpots.isNotEmpty) _buildLegend(),
            const SizedBox(height: 16),
            dataSpots.isEmpty
                ? _buildEmptyState(chartHeight)
                : _buildChart(dataSpots, chartHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<FlSpot> dataSpots) {
    final lastY = dataSpots.isNotEmpty ? dataSpots.last.y : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Courbe de fatigue',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.darkText),
            ),
            const Text(
              '30 derniers jours',
              style: TextStyle(fontSize: 12, color: AppColors.grayText),
            ),
          ],
        ),
        Row(
          children: [
            // Badge état actuel
            if (lastY != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorForValue(lastY).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _colorForValue(lastY).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _colorForValue(lastY),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _labelForValue(lastY),
                      style: TextStyle(
                        color: _colorForValue(lastY),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
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
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _LegendDot(color: AppColors.green, label: 'Faible'),
        const SizedBox(width: 16),
        _LegendDot(color: AppColors.orange, label: 'Modéré'),
        const SizedBox(width: 16),
        _LegendDot(color: AppColors.red, label: 'Élevé'),
        const SizedBox(width: 16),
        _LegendLine(label: 'Moy. 7j'),
      ],
    );
  }

  Widget _buildChart(List<FlSpot> dataSpots, double height) {
    final avgSpots = _buildAverageSpots(dataSpots);
    final lastY = dataSpots.last.y;
    final mainColor = _colorForValue(lastY);

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
            _zoneLine(_zone(0)),
            _zoneLine(_zone(40)),
            _zoneLine(_zone(70)),
            _zoneLine(_zone(100)),
            // Ligne principale
            LineChartBarData(
              spots: dataSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: mainColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isLast = index == dataSpots.length - 1;
                  return FlDotCirclePainter(
                    radius: isLast ? 5 : 3,
                    color: isLast ? mainColor : Colors.transparent,
                    strokeWidth: isLast ? 2 : 1,
                    strokeColor: isLast
                        ? Colors.white
                        : mainColor.withValues(alpha: 0.4),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    mainColor.withValues(alpha: 0.15),
                    mainColor.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
            // Moyenne glissante
            LineChartBarData(
              spots: avgSpots,
              isCurved: true,
              color: AppColors.grayText.withValues(alpha: 0.4),
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
              color: AppColors.green.withValues(alpha: 0.07),
            ),
            BetweenBarsData(
              fromIndex: 1,
              toIndex: 2,
              color: AppColors.orange.withValues(alpha: 0.07),
            ),
            BetweenBarsData(
              fromIndex: 2,
              toIndex: 3,
              color: AppColors.red.withValues(alpha: 0.07),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) {
                  if (v == 40) {
                    return Text('40',
                        style: TextStyle(
                            fontSize: 9,
                            color:
                                AppColors.orange.withValues(alpha: 0.7)));
                  }
                  if (v == 70) {
                    return Text('70',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.red.withValues(alpha: 0.7)));
                  }
                  if (v == 0 || v == 100) {
                    return Text('${v.toInt()}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.grayText));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 7,
                getTitlesWidget: (v, _) {
                  final date = DateTime.now()
                      .subtract(Duration(days: 29 - v.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.grayText),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (v) {
              if (v == 40 || v == 70) {
                return FlLine(
                  color: v == 40
                      ? AppColors.orange.withValues(alpha: 0.25)
                      : AppColors.red.withValues(alpha: 0.25),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              }
              return FlLine(
                color: AppColors.border.withValues(alpha: 0.3),
                strokeWidth: 0.5,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.darkText,
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.all(10),
              getTooltipItems: (spots) => spots.map((s) {
                if (s.barIndex != 4) return null;
                final date = DateTime.now()
                    .subtract(Duration(days: 29 - s.x.toInt()));
                return LineTooltipItem(
                  '${DateFormat('dd MMM', 'fr_FR').format(date)}\n'
                  'Fatigue : ${s.y.round()}/100\n'
                  '${_labelForValue(s.y)}',
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.5),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.show_chart,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune donnée disponible',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                  fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complétez votre premier check-in\npour voir votre courbe de fatigue',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.grayText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LÉGENDE ───────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.grayText)),
      ],
    );
  }
}

class _LegendLine extends StatelessWidget {
  final String label;
  const _LegendLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: CustomPaint(painter: _DashedLinePainter()),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.grayText)),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grayText.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}