import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user_health_profile.dart';
import '../models/checkin_model.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../services/health_calculator.dart';
import '../services/ai/alert_engine.dart';
import '../services/ai/recommendation_engine.dart';
import '../features/dashboard/widgets/fatigue_chart.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();

  // Animation bannière d'alerte
  late AnimationController _alertController;
  late Animation<Offset> _alertAnimation;
  String? _lastAlert;

  // Données AI (calculées de façon asynchrone quand les streams émettent)
  List<AlertRule> _cachedAlerts = [];
  List<Recommendation> _cachedRecs = [];
  String _lastDataKey = '';

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _alertAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _alertController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  // ── IA ────────────────────────────────────────────────────────────────────

  /// Recalcule alertes + recommandations quand les données changent
  void _maybeUpdateAi(UserHealthProfile? profile, List<CheckIn> checkins) {
    if (profile == null) return;
    final key =
        '${checkins.length}_${checkins.isNotEmpty ? checkins.first.id : ""}';
    if (key == _lastDataKey) return;
    _lastDataKey = key;

    // Alertes — calcul synchrone
    final alerts = AlertEngine().analyzeCheckins(checkins, profile);

    // Recommandations — asynchrone, on met à jour l'état quand c'est prêt
    RecommendationEngine()
        .getRecommendations(
          profile: profile,
          recentCheckins: checkins,
          activeAlerts: alerts,
        )
        .then((recs) {
      if (!mounted) return;
      setState(() {
        _cachedAlerts = alerts;
        _cachedRecs = recs;
      });
      _triggerAlertAnimation(
          alerts.isNotEmpty ? alerts.first.message : null);
    });
  }

  void _triggerAlertAnimation(String? alert) {
    if (alert == _lastAlert) return;
    _lastAlert = alert;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (alert != null) {
        _alertController.forward(from: 0);
      } else {
        _alertController.reverse();
      }
    });
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  String _greeting(String firstName) {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 12) return 'Bonjour $firstName ☀️';
    if (h >= 12 && h < 18) return 'Bon après-midi $firstName 🌤️';
    if (h >= 18 && h < 22) return 'Bonsoir $firstName 🌙';
    return 'Bonne nuit $firstName ⭐';
  }

  Color _scoreColor(double score) {
    if (score > 75) return AppColors.green;
    if (score > 50) return AppColors.orange;
    return AppColors.red;
  }

  Future<void> _logout() async {
    context.read<UserProvider>().clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Non connecté')));
    }
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/checkin'),
        backgroundColor: AppColors.primary,
        tooltip: 'Check-in du jour',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<UserHealthProfile?>(
        stream: _firestoreService.userProfileStream(uid),
        builder: (context, profileSnap) {
          return StreamBuilder<List<CheckIn>>(
            stream: _firestoreService.checkinsStream(uid, days: 7),
            builder: (context, checkinSnap) {
              if (!profileSnap.hasData && !checkinSnap.hasData) {
                return _buildSkeleton();
              }
              final profile = profileSnap.data;
              final checkins = checkinSnap.data ?? [];
              final score = checkins.isNotEmpty
                  ? checkins.first.scoreBienEtre
                  : (profile?.globalScore.toDouble() ?? 50.0);

              // Déclenche le calcul IA en post-frame pour ne pas bloquer le build
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _maybeUpdateAi(profile, checkins));

              return RefreshIndicator(
                onRefresh: () async =>
                    Future.delayed(const Duration(milliseconds: 300)),
                child: isWide
                    ? _buildWideLayout(profile, checkins, score)
                    : _buildMobileLayout(profile, checkins, score),
              );
            },
          );
        },
      ),
    );
  }

  // ── LAYOUTS ───────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(
    UserHealthProfile? profile,
    List<CheckIn> checkins,
    double score,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          floating: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.grayText),
              onPressed: _logout,
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(profile),
              const SizedBox(height: 20),
              if (_cachedAlerts.isNotEmpty) ...[
                _buildAlertBanner(_cachedAlerts.first),
                const SizedBox(height: 16),
              ],
              _buildScoreCircle(score),
              const SizedBox(height: 20),
              _buildMetricGrid(profile, checkins),
              const SizedBox(height: 20),
              FatigueChart(checkins: checkins),
              const SizedBox(height: 20),
              _buildRecommendations(),
              const SizedBox(height: 12),
              _buildHistoryButton(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(
    UserHealthProfile? profile,
    List<CheckIn> checkins,
    double score,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(profile),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.grayText),
                onPressed: _logout,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_cachedAlerts.isNotEmpty) ...[
            _buildAlertBanner(_cachedAlerts.first),
            const SizedBox(height: 20),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildScoreCircle(score),
                    const SizedBox(height: 20),
                    _buildMetricGrid(profile, checkins),
                    const SizedBox(height: 20),
                    FatigueChart(checkins: checkins),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecommendations(),
                    const SizedBox(height: 12),
                    _buildHistoryButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── WIDGETS ───────────────────────────────────────────────────────────────

  Widget _buildHeader(UserHealthProfile? profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(profile?.firstName ?? 'vous'),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Votre tableau de bord santé',
          style: TextStyle(color: AppColors.grayText, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(double score) {
    final color = _scoreColor(score);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'Score global de bien-être',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.darkText),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            key: ValueKey(score),
            tween: Tween(begin: 0.0, end: score / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(value * 100).round()}',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      const Text('/100',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.grayText)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              HealthCalculator.getStressLevel(score),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
      UserHealthProfile? profile, List<CheckIn> checkins) {
    final last = checkins.isNotEmpty ? checkins.first : null;
    final prev = checkins.length > 1 ? checkins[1] : null;

    final metrics = [
      _MetricData(
        label: 'Sommeil',
        icon: Icons.bedtime,
        value: last?.sommeil.toDouble() ??
            profile?.sleepQuality.toDouble() ?? 5,
        prevValue: prev?.sommeil.toDouble(),
        color: AppColors.cyan,
        unit: '/10',
      ),
      _MetricData(
        label: 'Stress',
        icon: Icons.psychology,
        value:
            last?.stress.toDouble() ?? profile?.stressLevel.toDouble() ?? 5,
        prevValue: prev?.stress.toDouble(),
        color: AppColors.rose,
        unit: '/10',
        invertTrend: true,
      ),
      _MetricData(
        label: 'Activité',
        icon: Icons.directions_run,
        value: (profile?.activityScore ?? 50).toDouble(),
        prevValue: null,
        color: AppColors.green,
        unit: '/100',
      ),
      _MetricData(
        label: 'Humeur',
        icon: Icons.sentiment_satisfied,
        value: last?.humeur.toDouble() ?? 3,
        prevValue: prev?.humeur.toDouble(),
        color: AppColors.yellow,
        unit: '/5',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: metrics.map(_buildMetricCard).toList(),
    );
  }

  Widget _buildMetricCard(_MetricData m) {
    String? trend;
    Color? trendColor;
    if (m.prevValue != null) {
      final diff = m.value - m.prevValue!;
      if (diff.abs() > 0.4) {
        final better = m.invertTrend ? diff < 0 : diff > 0;
        trend = better ? '↑' : '↓';
        trendColor = better ? AppColors.green : AppColors.red;
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(m.icon, color: m.color, size: 16),
            const SizedBox(width: 6),
            Text(m.label,
                style: const TextStyle(
                    color: AppColors.grayText, fontSize: 12)),
          ]),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${m.value.round()}',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: m.color)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(m.unit,
                    style: const TextStyle(
                        color: AppColors.grayText, fontSize: 11)),
              ),
              if (trend != null) ...[
                const Spacer(),
                Text(trend,
                    style: TextStyle(
                        fontSize: 18,
                        color: trendColor,
                        fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(AlertRule alert) {
    final isCritical = alert.level == AlertLevel.CRITICAL;
    final color = isCritical ? AppColors.red : AppColors.orange;
    final bg = isCritical ? AppColors.roseLight : AppColors.orangeLight;

    return SlideTransition(
      position: _alertAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 2),
                  Text(alert.message,
                      style: TextStyle(color: color, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(alert.route),
              child: Text(alert.actionSuggested,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    if (_cachedRecs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommandations du jour',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText),
        ),
        const SizedBox(height: 12),
        ..._cachedRecs.map(_buildRecommendationCard),
      ],
    );
  }

  Widget _buildRecommendationCard(Recommendation rec) {
    final Color catColor;
    switch (rec.category) {
      case 'STRESS':
        catColor = AppColors.purple;
      case 'SOMMEIL':
        catColor = AppColors.cyan;
      case 'ACTIVITÉ':
        catColor = AppColors.green;
      case 'NUTRITION':
        catColor = AppColors.orange;
      default:
        catColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(rec.icon,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(rec.category,
                          style: TextStyle(
                              color: catColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Text(rec.duration,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.grayText)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(rec.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                        fontSize: 14)),
                Text(rec.description,
                    style: const TextStyle(
                        color: AppColors.grayText, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: catColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
            ),
            child: const Text('Commencer',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.history, size: 18),
        label: const Text('Voir l\'historique complet'),
        onPressed: () => Navigator.of(context).pushNamed('/history'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── SKELETON ─────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const _SkeletonBox(width: 220, height: 32, radius: 8),
          const SizedBox(height: 8),
          const _SkeletonBox(width: 160, height: 18, radius: 6),
          const SizedBox(height: 24),
          const _SkeletonBox(
              width: double.infinity, height: 200, radius: 20),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: const [
              _SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 16),
              _SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 16),
              _SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 16),
              _SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 16),
            ],
          ),
          const SizedBox(height: 20),
          const _SkeletonBox(
              width: double.infinity, height: 200, radius: 20),
          const SizedBox(height: 20),
          const _SkeletonBox(width: 200, height: 24, radius: 6),
          const SizedBox(height: 12),
          const _SkeletonBox(
              width: double.infinity, height: 80, radius: 16),
          const SizedBox(height: 12),
          const _SkeletonBox(
              width: double.infinity, height: 80, radius: 16),
        ],
      ),
    );
  }
}

// ── DATA CLASS ────────────────────────────────────────────────────────────────

class _MetricData {
  final String label;
  final IconData icon;
  final double value;
  final double? prevValue;
  final Color color;
  final String unit;
  final bool invertTrend;

  const _MetricData({
    required this.label,
    required this.icon,
    required this.value,
    required this.prevValue,
    required this.color,
    required this.unit,
    this.invertTrend = false,
  });
}

// ── SKELETON WIDGET ───────────────────────────────────────────────────────────

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _SkeletonBox(
      {required this.width, required this.height, required this.radius});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.35, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}
