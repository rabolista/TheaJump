import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../thea_jump_game.dart';
import 'platform_component.dart';

/// The bouncy hero. Falls under gravity, bounces off platforms and wraps
/// around the sides of the world.
class PlayerComponent extends SpriteComponent
    with HasGameReference<TheaJumpGame>, CollisionCallbacks {
  PlayerComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(56, 56),
          anchor: Anchor.center,
        );

  static const double gravity = 900;
  static const double bounceVelocity = -520;
  static const double springVelocity = -820;
  static const double horizontalSpeed = 260;

  Vector2 velocity = Vector2(0, bounceVelocity);
  double _facing = 1;

  late final Sprite _normalSprite;
  late final Sprite _scaredSprite;

  @override
  Future<void> onLoad() async {
    _normalSprite = await Sprite.load('player.png');
    _scaredSprite = await Sprite.load('player_scared.png');
    sprite = _normalSprite;
    add(RectangleHitbox(
      size: Vector2(size.x * 0.7, size.y * 0.7),
      position: Vector2(size.x * 0.15, size.y * 0.15),
    ));
  }

  /// Called every frame from the game with the desired horizontal direction
  /// in the range [-1, 1] (from drag/keyboard input).
  void setHorizontalInput(double direction) {
    velocity.x = direction * horizontalSpeed;
    if (direction.abs() > 0.05) {
      _facing = direction.sign;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver) return;

    velocity.y += gravity * dt;
    position += velocity * dt;

    // Wide-eyed "scared" face while launching upward, back to a smile
    // once she's falling again.
    sprite = velocity.y < 0 ? _scaredSprite : _normalSprite;

    // Wrap around the sides of the world for that classic jumper feel.
    final halfWidth = size.x / 2;
    if (position.x < -halfWidth) {
      position.x = TheaJumpGame.worldWidth + halfWidth;
    } else if (position.x > TheaJumpGame.worldWidth + halfWidth) {
      position.x = -halfWidth;
    }

    // Flip sprite to face the movement direction.
    scale.x = _facing < 0 ? -1 : 1;

    game.onPlayerUpdated(position.y, velocity.y);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlatformComponent &&
        velocity.y > 0 &&
        position.y < other.position.y) {
      _bounceOff(other);
    }
  }

  void _bounceOff(PlatformComponent platform) {
    switch (platform.kind) {
      case PlatformKind.normal:
        velocity.y = bounceVelocity;
        break;
      case PlatformKind.spring:
        velocity.y = springVelocity;
        break;
      case PlatformKind.breakable:
        velocity.y = bounceVelocity;
        if (!platform.consumed) {
          platform.consumed = true;
          platform.removeFromParent();
          game.onPlatformBroken();
        }
        break;
    }
    game.onBounce(platform.kind);
  }
}
