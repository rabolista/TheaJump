import 'dart:async';

import 'package:flutter/material.dart';

import '../badges.dart';
import '../thea_jump_game.dart';

/// A transient banner shown at the top of the screen whenever a new
/// score-badge is unlocked mid-run.
class BadgeOverlay extends StatefulWidget {
  const BadgeOverlay({super.key, required this.game});

  final TheaJumpGame game;

  @override
  State<BadgeOverlay> createState() => _BadgeOverlayState();
}

class _BadgeOverlayState extends State<BadgeOverlay> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    widget.game.badgePopupNotifier.addListener(_onBadgeChanged);
  }

  void _onBadgeChanged() {
    if (widget.game.badgePopupNotifier.value == null) return;
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      widget.game.badgePopupNotifier.value = null;
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    widget.game.badgePopupNotifier.removeListener(_onBadgeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 64),
            child: ValueListenableBuilder<ScoreBadge?>(
              valueListenable: widget.game.badgePopupNotifier,
              builder: (context, badge, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: badge == null
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : _BadgeChip(badge: badge, key: ValueKey(badge.threshold)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({super.key, required this.badge});

  final ScoreBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2650).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'BADGE UNLOCKED',
                style: TextStyle(
                  color: Color(0xFFFFD662),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                badge.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
