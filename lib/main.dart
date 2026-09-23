import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/overlays/badge_overlay.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/hud_overlay.dart';
import 'game/overlays/start_overlay.dart';
import 'game/thea_jump_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const TheaJumpApp());
}

class TheaJumpApp extends StatelessWidget {
  const TheaJumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheaJump',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final TheaJumpGame _game = TheaJumpGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<TheaJumpGame>(
        game: _game,
        overlayBuilderMap: {
          'start': (context, game) => StartOverlay(game: game),
          'gameOver': (context, game) => GameOverOverlay(game: game),
          'hud': (context, game) => HudOverlay(game: game),
          'badge': (context, game) => BadgeOverlay(game: game),
        },
        initialActiveOverlays: const ['start', 'badge'],
      ),
    );
  }
}

