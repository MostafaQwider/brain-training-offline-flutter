import 'difficulty_level.dart';

/// Represents the result of a completed game session
class GameResult {
  final String gameType; // 'sequence', 'spatial', or 'word'
  final int score;
  final double accuracy; // 0.0 to 1.0
  final int timeTaken; // in seconds
  final DifficultyLevel difficulty;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime completedAt;

  GameResult({
    required this.gameType,
    required this.score,
    required this.accuracy,
    required this.timeTaken,
    required this.difficulty,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completedAt,
  });

  /// Get a formatted accuracy percentage
  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(1)}%';

  /// Get a letter grade based on accuracy
  String get grade {
    if (accuracy >= 0.9) return 'A';
    if (accuracy >= 0.8) return 'B';
    if (accuracy >= 0.7) return 'C';
    if (accuracy >= 0.6) return 'D';
    return 'F';
  }

  /// Determine if the player performed well enough to level up
  bool get shouldLevelUp => accuracy >= 0.8;

  /// Determine if the player should level down
  bool get shouldLevelDown => accuracy < 0.5;
}
