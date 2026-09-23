import 'package:flutter/material.dart';

import '../thea_jump_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final TheaJumpGame game;

  @override
  Widget build(BuildContext context) {
    final isNewBest = game.score >= game.highScore && game.score > 0;
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Score: ${game.score}',
            style: const TextStyle(color: Colors.white, fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            isNewBest ? 'New Best!' : 'Best: ${game.highScore}',
            style: TextStyle(
              color: isNewBest ? const Color(0xFFFFD662) : Colors.white70,
              fontSize: 18,
              fontWeight: isNewBest ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (game.earnedThisRun.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final badge in game.earnedThisRun)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(badge.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          badge.label,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
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
            child: const Text('PLAY AGAIN'),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: game.shareScore,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.share, size: 20),
            label: const Text(
              'SHARE SCORE',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
