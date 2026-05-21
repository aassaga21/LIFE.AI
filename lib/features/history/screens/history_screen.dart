import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/checkin_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/health_calculator.dart';
import '../../../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _firestore = FirestoreService();
  final _scrollCtrl = ScrollController();

  List<CheckIn> _checkins = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  // Filtres
  int? _filterDays = 7; // null = tout
  String _filterMetric = 'tous';

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── CHARGEMENT ──────────────────────────────────────────────────────────────

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
      _checkins = [];
      _hasMore = true;
    });
    try {
      final list = await _firestore.getCheckinsBefore(
        uid: _uid,
        before: DateTime.now().add(const Duration(seconds: 1)),
        limit: _pageSize,
        filterDays: _filterDays,
      );
      setState(() {
        _checkins = list;
        _hasMore = list.length == _pageSize;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _checkins.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final oldest = _checkins.last.date;
      final list = await _firestore.getCheckinsBefore(
        uid: _uid,
        before: oldest,
        limit: _pageSize,
        filterDays: _filterDays,
      );
      setState(() {
        _checkins.addAll(list);
        _hasMore = list.length == _pageSize;
      });
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // ── FILTRES ─────────────────────────────────────────────────────────────────

  List<CheckIn> get _filtered {
    if (_filterMetric == 'tous') return _checkins;
    return _checkins; // le filtre métrique s'applique côté affichage
  }

  // ── STATS AGRÉGÉES ──────────────────────────────────────────────────────────

  double get _avgStress => _checkins.isEmpty
      ? 0
      : _checkins.map((c) => c.stress).reduce((a, b) => a + b) /
          _checkins.length;

  CheckIn? get _bestDay => _checkins.isEmpty
      ? null
      : _checkins
          .reduce((a, b) => a.scoreBienEtre > b.scoreBienEtre ? a : b);

  int get _streak {
    if (_checkins.isEmpty) return 0;
    final sorted = [..._checkins]..sort((a, b) => b.date.compareTo(a.date));
    int s = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = DateTime(
              sorted[i - 1].date.year,
              sorted[i - 1].date.month,
              sorted[i - 1].date.day)
          .difference(DateTime(sorted[i].date.year, sorted[i].date.month,
              sorted[i].date.day))
          .inDays;
      if (diff == 1) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  // ── EXPORT CSV ──────────────────────────────────────────────────────────────

  Future<void> _exportCsv() async {
    final buf = StringBuffer();
    buf.writeln(
        'date,humeur,energie,sommeil,stress,notes,scoreStress,scoreFatigue,scoreBienEtre');
    for (final c in _checkins) {
      buf.writeln(
        '${DateFormat('dd/MM/yyyy').format(c.date)},'
        '${c.humeur},'
        '${c.energie},'
        '${c.sommeil},'
        '${c.stress},'
        '"${(c.notes ?? '').replaceAll('"', "'")}",'
        '${c.scoreStress.toStringAsFixed(2)},'
        '${c.scoreFatigue.toStringAsFixed(2)},'
        '${c.scoreBienEtre.toStringAsFixed(2)}',
      );
    }
    final bytes = Uint8List.fromList(utf8.encode(buf.toString()));
    await Share.shareXFiles(
      [
        XFile.fromData(bytes,
            name: 'life_ai_history.csv', mimeType: 'text/csv')
      ],
      subject: 'Mon historique LIFE.AI',
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mon Historique',
          style: TextStyle(
              color: AppColors.darkText, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.download_outlined, color: AppColors.grayText),
            tooltip: 'Exporter CSV',
            onPressed: _checkins.isEmpty ? null : _exportCsv,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFirst,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildFilterBar(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.red))),
              )
            else if (_filtered.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Aucun check-in pour cette période.',
                      style: TextStyle(color: AppColors.grayText)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _filtered.length) {
                        return _loadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            : _hasMore
                                ? const SizedBox.shrink()
                                : const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Text('Tout est chargé !',
                                          style: TextStyle(
                                              color: AppColors.grayText,
                                              fontSize: 13)),
                                    ),
                                  );
                      }
                      return _CheckinCard(
                        checkin: _filtered[index],
                        index: index,
                        filterMetric: _filterMetric,
                        onTap: () => _showDetail(_filtered[index]),
                      );
                    },
                    childCount: _filtered.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS ──────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final best = _bestDay;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Stress moyen',
            value: _avgStress.toStringAsFixed(1),
            unit: '/10',
            color: _avgStress > 7
                ? AppColors.red
                : _avgStress > 5
                    ? AppColors.orange
                    : AppColors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Meilleur jour',
            value: best != null
                ? DateFormat('dd/MM').format(best.date)
                : '--',
            unit: best != null
                ? '(${best.scoreBienEtre.round()})'
                : '',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Streak',
            value: '$_streak',
            unit: 'jours',
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    const periods = [
      (label: '7 jours', days: 7),
      (label: '30 jours', days: 30),
      (label: '3 mois', days: 90),
      (label: 'Tout', days: -1),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtres période
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: periods.map((p) {
              final selected = p.days == -1
                  ? _filterDays == null
                  : _filterDays == p.days;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _filterDays = p.days == -1 ? null : p.days;
                    });
                    _loadFirst();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      p.label,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Filtre type de donnée
        DropdownButton<String>(
          value: _filterMetric,
          underline: const SizedBox.shrink(),
          style: const TextStyle(
              color: AppColors.darkText, fontSize: 13),
          onChanged: (v) => setState(() => _filterMetric = v ?? 'tous'),
          items: const [
            DropdownMenuItem(value: 'tous', child: Text('Tous les indicateurs')),
            DropdownMenuItem(value: 'stress', child: Text('Stress')),
            DropdownMenuItem(value: 'sommeil', child: Text('Sommeil')),
            DropdownMenuItem(value: 'energie', child: Text('Énergie')),
            DropdownMenuItem(value: 'humeur', child: Text('Humeur')),
          ],
        ),
      ],
    );
  }

  void _showDetail(CheckIn c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(checkin: c),
    );
  }
}

// ── CHECKIN CARD ─────────────────────────────────────────────────────────────

class _CheckinCard extends StatefulWidget {
  final CheckIn checkin;
  final int index;
  final String filterMetric;
  final VoidCallback onTap;

  const _CheckinCard({
    required this.checkin,
    required this.index,
    required this.filterMetric,
    required this.onTap,
  });

  @override
  State<_CheckinCard> createState() => _CheckinCardState();
}

class _CheckinCardState extends State<_CheckinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_fade);

    // Délai échelonné selon l'index
    Future.delayed(Duration(milliseconds: 50 * widget.index.clamp(0, 10)),
        () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _emojis = ['😔', '😐', '🙂', '😊', '😁'];

  @override
  Widget build(BuildContext context) {
    final c = widget.checkin;
    final score = c.scoreBienEtre;
    final Color scoreColor = score > 75
        ? AppColors.green
        : score > 50
            ? AppColors.orange
            : AppColors.red;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Emoji humeur
                Text(
                  _emojis[(c.humeur - 1).clamp(0, 4)],
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(c.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSparkline(c),
                      if (c.notes != null && c.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          c.notes!.length > 50
                              ? '${c.notes!.substring(0, 50)}…'
                              : c.notes!,
                          style: const TextStyle(
                              color: AppColors.grayText, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Score global
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${score.round()}',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final jours = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    final mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  Widget _buildSparkline(CheckIn c) {
    final metrics = [
      (label: 'S', value: c.sommeil, max: 10, color: AppColors.cyan),
      (label: 'St', value: c.stress, max: 10, color: AppColors.rose),
      (label: 'É', value: c.energie, max: 10, color: AppColors.green),
      (label: 'H', value: c.humeur * 2, max: 10, color: AppColors.yellow),
    ];

    return Row(
      children: metrics.map((m) {
        final ratio = (m.value / m.max).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Column(
            children: [
              Container(
                width: 12,
                height: 28,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 12,
                  height: 28 * ratio,
                  decoration: BoxDecoration(
                    color: m.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(m.label,
                  style: const TextStyle(
                      fontSize: 8, color: AppColors.grayText)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── BOTTOM SHEET DÉTAIL ──────────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  final CheckIn checkin;
  const _DetailSheet({required this.checkin});

  @override
  Widget build(BuildContext context) {
    final score = checkin.scoreBienEtre;
    final level = HealthCalculator.getStressLevel(score);
    final Color color = score > 75
        ? AppColors.green
        : score > 50
            ? AppColors.orange
            : AppColors.red;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMMM yyyy').format(checkin.date),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.darkText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Scores détaillés
          _DetailRow('Humeur', '${checkin.humeur}/5', AppColors.yellow),
          _DetailRow('Énergie', '${checkin.energie}/10', AppColors.green),
          _DetailRow('Sommeil', '${checkin.sommeil}/10', AppColors.cyan),
          _DetailRow('Stress', '${checkin.stress}/10', AppColors.rose),
          const Divider(height: 24),
          _DetailRow(
              'Score fatigue',
              '${(checkin.scoreFatigue * 10).round()}/100',
              AppColors.orange),
          _DetailRow(
              'Score stress',
              '${(checkin.scoreStress * 10).round()}/100',
              AppColors.red),
          _DetailRow(
              'Bien-être global',
              '${checkin.scoreBienEtre.round()}/100',
              color),
          if (checkin.notes != null && checkin.notes!.isNotEmpty) ...[
            const Divider(height: 24),
            const Text('Notes',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText)),
            const SizedBox(height: 8),
            Text(checkin.notes!,
                style: const TextStyle(color: AppColors.grayText)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.grayText, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

// ── STAT CARD ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.grayText)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.grayText)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
