import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationType { ALERTE_IA, ENCOURAGEMENT, RAPPEL, NOUVEAUTE }

/// Service centralisé de notifications — locales et in-app
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Clé navigator exposée — à assigner depuis main.dart
  static GlobalKey<NavigatorState>? navigatorKey;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyCheckinId = 1;
  static const String _channelId = 'lifeai_channel';
  static const String _channelName = 'LIFE.AI Notifications';
  static const String _prefHour = 'notif_hour';
  static const String _prefMinute = 'notif_minute';

  bool _initialized = false;

  // ── INITIALISATION ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Les notifications locales ne sont pas disponibles sur le web
    if (kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        onNotificationTap(details.payload);
      },
    );

    // Canal Android
    if (!kIsWeb && Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
        enableVibration: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  // ── PERMISSIONS ────────────────────────────────────────────────────────────

  Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return false;
  }

  // ── RAPPEL QUOTIDIEN ────────────────────────────────────────────────────────

  Future<void> scheduleDailyCheckin({
    TimeOfDay time = const TimeOfDay(hour: 20, minute: 0),
  }) async {
    if (kIsWeb || !_initialized) return;

    await _plugin.periodicallyShow(
      _dailyCheckinId,
      '⏰ Check-in LIFE.AI',
      'Comment vous sentez-vous aujourd\'hui ?',
      RepeatInterval.daily,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '/checkin',
    );

    // Persiste l'heure choisie
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, time.hour);
    await prefs.setInt(_prefMinute, time.minute);
  }

  // ── NOTIFICATION IMMÉDIATE ──────────────────────────────────────────────────

  Future<void> showAlertNotification({
    required String title,
    required String body,
    required NotificationType type,
    String payload = '/',
  }) async {
    if (kIsWeb || !_initialized) return;

    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: _importanceFor(type),
          priority: Priority.high,
          color: _colorFor(type),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );

    // Affiche aussi le banner in-app si l'app est ouverte
    _showInAppBanner(title: title, body: body, type: type, payload: payload);
  }

  // ── ANNULATION ──────────────────────────────────────────────────────────────

  Future<void> cancelDailyCheckin() async {
    if (kIsWeb) return;
    await _plugin.cancel(_dailyCheckinId);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  // ── NAVIGATION AU TAP ───────────────────────────────────────────────────────

  void onNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    navigatorKey?.currentState?.pushNamed(payload);
  }

  // ── PARAMÈTRES ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_prefHour) ?? 20,
      'minute': prefs.getInt(_prefMinute) ?? 0,
      'enabled': prefs.getBool('notif_enabled') ?? true,
    };
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    if (settings['hour'] != null) {
      await prefs.setInt(_prefHour, settings['hour'] as int);
    }
    if (settings['minute'] != null) {
      await prefs.setInt(_prefMinute, settings['minute'] as int);
    }
    if (settings['enabled'] != null) {
      await prefs.setBool('notif_enabled', settings['enabled'] as bool);
    }
  }

  // ── BANNER IN-APP ─────────────────────────────────────────────────────────

  void _showInAppBanner({
    required String title,
    required String body,
    required NotificationType type,
    required String payload,
  }) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _InAppBannerWidget(
        title: title,
        body: body,
        type: type,
        onTap: () {
          entry.remove();
          onNotificationTap(payload);
        },
        onDismiss: () => entry.remove(),
      ),
    );

    Overlay.of(context).insert(entry);
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Importance _importanceFor(NotificationType type) {
    switch (type) {
      case NotificationType.ALERTE_IA:
        return Importance.max;
      case NotificationType.ENCOURAGEMENT:
      case NotificationType.RAPPEL:
        return Importance.high;
      case NotificationType.NOUVEAUTE:
        return Importance.defaultImportance;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.ALERTE_IA:
        return const Color(0xFFEF4444);
      case NotificationType.ENCOURAGEMENT:
        return const Color(0xFF22C55E);
      case NotificationType.RAPPEL:
        return const Color(0xFF2563EB);
      case NotificationType.NOUVEAUTE:
        return const Color(0xFF9333EA);
    }
  }
}

// ── WIDGET BANNER IN-APP ──────────────────────────────────────────────────────

class _InAppBannerWidget extends StatefulWidget {
  final String title;
  final String body;
  final NotificationType type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppBannerWidget({
    required this.title,
    required this.body,
    required this.type,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppBannerWidget> createState() => _InAppBannerWidgetState();
}

class _InAppBannerWidgetState extends State<_InAppBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    // Auto-dismiss après 3 secondes
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  Color get _color {
    switch (widget.type) {
      case NotificationType.ALERTE_IA:
        return const Color(0xFFEF4444);
      case NotificationType.ENCOURAGEMENT:
        return const Color(0xFF22C55E);
      case NotificationType.RAPPEL:
        return const Color(0xFF2563EB);
      case NotificationType.NOUVEAUTE:
        return const Color(0xFF9333EA);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _color,
                                fontSize: 13)),
                        Text(widget.body,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Icon(Icons.close,
                        size: 18, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
