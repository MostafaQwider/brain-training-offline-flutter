import 'package:flutter/material.dart';
import '../models/difficulty_level.dart';

/// Widget to display current score and difficulty level during gameplay
class ScoreDisplay extends StatelessWidget {
  final int score;
  final DifficultyLevel difficulty;
  final int? timeRemaining; // Optional timer display

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.difficulty,
    this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final config = DifficultyConfig.getConfig(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score display
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                score.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Difficulty display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              config.displayName,
              style: TextStyle(
                color: _getDifficultyColor(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Timer display (if provided)
          if (timeRemaining != null)
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${timeRemaining}s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.blue;
      case DifficultyLevel.advanced:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }
}
