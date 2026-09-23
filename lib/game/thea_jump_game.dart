import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show ImageRepeat;
import 'package:share_plus/share_plus.dart';

import 'badges.dart';
import 'components/platform_component.dart';
import 'components/player_component.dart';
import '../services/badge_service.dart';
import '../services/high_score_service.dart';

enum GameState { intro, playing, gameOver }

/// TheaJump - an endless vertical jumper. Bounce off platforms, avoid
/// falling off the bottom of the screen, and climb as high as you can.
class TheaJumpGame extends FlameGame
    with HasCollisionDetection, DragCallbacks, TapCallbacks {
  TheaJumpGame() : super(world: World());

  static const double worldWidth = 400;
  static const double worldHeight = 800;
  static const double _platformGapMin = 70;
  static const double _platformGapMax = 130;

  final HighScoreService _highScoreService = HighScoreService();
  final BadgeService _badgeService = BadgeService();
  final Random _random = Random();

  late PlayerComponent player;
  GameState state = GameState.intro;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  int get score => scoreNotifier.value;
  int highScore = 0;
  double _highestPlayerY = 0;
  double _highestPlatformY = 0;
  double _dragDirection = 0;

  Set<int> _unlockedBadgeThresholds = {};
  final List<ScoreBadge> earnedThisRun = [];
  final ValueNotifier<ScoreBadge?> badgePopupNotifier = ValueNotifier<ScoreBadge?>(null);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera = CameraComponent.withFixedResolution(
      world: world,
      width: worldWidth,
      height: worldHeight,
    );
    camera.viewfinder.anchor = Anchor.center;
    add(camera);

    final parallax = await loadParallaxComponent(
      [ParallaxImageData('background.png')],
      baseVelocity: Vector2(0, -6),
      repeat: ImageRepeat.repeatY,
      fill: LayerFill.width,
    );
    camera.backdrop.add(parallax);

    highScore = await _highScoreService.load();
    _unlockedBadgeThresholds = await _badgeService.loadUnlocked();
    await FlameAudio.audioCache.loadAll(['jump.wav', 'spring.wav', 'badge.wav']);
    _resetWorld();
  }

  void _resetWorld() {
    world.removeAll(world.children.whereType<PlatformComponent>());
    world.removeAll(world.children.whereType<PlayerComponent>());

    scoreNotifier.value = 0;
    _highestPlayerY = 0;
    _highestPlatformY = 0;
    earnedThisRun.clear();
    badgePopupNotifier.value = null;
    camera.viewfinder.position = Vector2(worldWidth / 2, 0);

    // Starting platform right under the player.
    world.add(PlatformComponent(
      kind: PlatformKind.normal,
      position: Vector2(worldWidth / 2, 40),
    ));
    _highestPlatformY = 40;
    for (var i = 0; i < 12; i++) {
      _spawnNextPlatform();
    }

    player = PlayerComponent(position: Vector2(worldWidth / 2, -20));
    world.add(player);
  }

  void startGame() {
    _resetWorld();
    state = GameState.playing;
    overlays.remove('start');
    overlays.remove('gameOver');
    overlays.add('hud');
  }

  void _spawnNextPlatform() {
    final gap = _platformGapMin +
        _random.nextDouble() * (_platformGapMax - _platformGapMin);
    _highestPlatformY -= gap;
    final x = 40 + _random.nextDouble() * (worldWidth - 80);
    world.add(PlatformComponent(
      kind: PlatformComponent.randomKind(score: score),
      position: Vector2(x, _highestPlatformY),
    ));
  }

  /// Called by [PlayerComponent] every frame with its current y position.
  void onPlayerUpdated(double playerY, double velocityY) {
    if (state != GameState.playing) return;

    if (playerY < _highestPlayerY) {
      _highestPlayerY = playerY;
      scoreNotifier.value = max(score, (-_highestPlayerY / 10).floor());
      _checkBadges();
    }

    // Camera only ever moves up, ratcheting with the player's best height.
    final targetY = min(camera.viewfinder.position.y, playerY);
    camera.viewfinder.position = Vector2(worldWidth / 2, targetY);

    // Keep spawning platforms above the current highest one.
    final spawnThreshold = camera.viewfinder.position.y - worldHeight;
    while (_highestPlatformY > spawnThreshold) {
      _spawnNextPlatform();
    }

    // Recycle platforms that have scrolled well below the camera.
    final cullThreshold = camera.viewfinder.position.y + worldHeight;
    for (final platform in world.children.whereType<PlatformComponent>()) {
      if (platform.position.y > cullThreshold) {
        platform.removeFromParent();
      }
    }

    // Game over once the player has fallen below the visible viewport.
    if (playerY > camera.viewfinder.position.y + worldHeight / 2 + 60) {
      _endGame();
    }
  }

  void _checkBadges() {
    for (final badge in kBadges) {
      if (score >= badge.threshold &&
          !_unlockedBadgeThresholds.contains(badge.threshold)) {
        _unlockedBadgeThresholds = {..._unlockedBadgeThresholds, badge.threshold};
        earnedThisRun.add(badge);
        badgePopupNotifier.value = badge;
        _badgeService.saveUnlocked(_unlockedBadgeThresholds);
        FlameAudio.play('badge.wav');
      }
    }
  }

  void onBounce(PlatformKind kind) {
    FlameAudio.play(kind == PlatformKind.spring ? 'spring.wav' : 'jump.wav');
  }

  void onPlatformBroken() {}

  /// Shares the current score (and best badge earned this run) to whatever
  /// share sheet the platform offers, for bragging rights.
  void shareScore() {
    final best = earnedThisRun.isNotEmpty ? earnedThisRun.last : null;
    final text = best != null
        ? 'I just scored $score in TheaJump and unlocked the '
            '${best.emoji} ${best.label} badge! Can you beat me? 🚀'
        : 'I just scored $score in TheaJump! Can you beat me? 🚀';
    SharePlus.instance.share(ShareParams(text: text));
  }

  bool get isGameOver => state == GameState.gameOver;

  void _endGame() {
    if (state != GameState.playing) return;
    state = GameState.gameOver;
    overlays.remove('hud');
    overlays.add('gameOver');
    _highScoreService.save(score).then((_) async {
      highScore = await _highScoreService.load();
    });
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (state != GameState.playing) return;
    _dragDirection = event.localDelta.x.sign;
    player.setHorizontalInput(_dragDirection * 1.0);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    player.setHorizontalInput(0);
  }

  /// Continuous input from on-screen left/right buttons (used alongside drag).
  void setDirectionalInput(double direction) {
    if (state != GameState.playing) return;
    player.setHorizontalInput(direction);
  }
}
