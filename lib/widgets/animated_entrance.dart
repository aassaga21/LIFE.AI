import 'package:flutter/material.dart';

/// Fait apparaître son enfant avec un fade + glissement vers le haut.
/// Utiliser [delay] pour décaler l'animation (effet cascade).
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.slideDistance = 40.0,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideDistance;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slideY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideY = Tween<double>(begin: widget.slideDistance, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slideY.value),
          child: child,
        ),
      ),
    );
  }
}

/// Carte avec effet de survol (scale + ombre) — fonctionne sur web/desktop,
/// fallback transparent sur mobile.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.03,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withAlpha(25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
