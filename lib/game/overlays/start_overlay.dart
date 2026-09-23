import 'package:flutter/material.dart';

import '../thea_jump_game.dart';

class StartOverlay extends StatelessWidget {
  const StartOverlay({super.key, required this.game});

  final TheaJumpGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TheaJump',
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(blurRadius: 12, color: Colors.black45)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Best: ${game.highScore}',
            style: const TextStyle(color: Colors.white70, fontSize: 20),
          ),
          const SizedBox(height: 32),
          const Text(
            'Drag left / right to move.\nBounce as high as you can!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: game.startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A59),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('JUMP!'),
          ),
        ],
      ),
    );
  }
}
