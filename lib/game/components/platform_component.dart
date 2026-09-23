import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum PlatformKind { normal, spring, breakable }

/// A platform the player bounces off while climbing.
class PlatformComponent extends SpriteComponent {
  PlatformComponent({required this.kind, required Vector2 position})
      : super(
          position: position,
          size: Vector2(76, 20),
          anchor: Anchor.center,
        );

  final PlatformKind kind;
  bool consumed = false;

  static final Random _random = Random();

  String get _assetName {
    switch (kind) {
      case PlatformKind.normal:
        return 'platform_normal.png';
      case PlatformKind.spring:
        return 'platform_spring.png';
      case PlatformKind.breakable:
        return 'platform_break.png';
    }
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(_assetName);
    add(RectangleHitbox(
      size: Vector2(size.x, size.y * 0.6),
      position: Vector2(0, 0),
    ));
  }

  /// Randomly picks a platform kind, weighted so normal platforms are common.
  static PlatformKind randomKind({required int score}) {
    final roll = _random.nextDouble();
    // Harder difficulty introduces more breakable/spring platforms over time.
    final breakableChance = min(0.12 + score / 4000, 0.28);
    final springChance = 0.12;
    if (roll < breakableChance) return PlatformKind.breakable;
    if (roll < breakableChance + springChance) return PlatformKind.spring;
    return PlatformKind.normal;
  }
}
