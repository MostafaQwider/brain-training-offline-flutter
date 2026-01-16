import '../models/difficulty_level.dart';

/// Service for calculating scores across all game modes
/// Provides consistent scoring logic based on difficulty, accuracy, and time
class ScoreService {
  /// Calculate score based on game performance
  ///
  /// Algorithm:
  /// score = basePoints × difficultyMultiplier × accuracyBonus × timeBonus
  ///
  /// Parameters:
  /// - difficulty: Current difficulty level
  /// - correctAnswers: Number of correct answers
  /// - totalQuestions: Total number of questions
  /// - timeTaken: Time taken in seconds
  /// - timeLimit: Maximum time allowed in seconds
  ///
  /// Returns: Calculated score as an integer
  static int calculateScore({
    required DifficultyLevel difficulty,
    required int correctAnswers,
    required int totalQuestions,
    required int timeTaken,
    required int timeLimit,
  }) {
    // Base points for completing a game
    const int basePoints = 100;

    // Get difficulty configuration
    final config = DifficultyConfig.getConfig(difficulty);
    final double difficultyMultiplier = config.multiplier;

    // Calculate accuracy bonus (0.0 to 1.0)
    final double accuracy =
        totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

    // Calculate time bonus
    // Faster completion = higher bonus (max 2.0x, min 0.5x)
    final double timeBonus = timeTaken > 0 && timeTaken <= timeLimit
        ? (2.0 - (timeTaken / timeLimit)).clamp(0.5, 2.0)
        : 0.5;

    // Final score calculation
    final double rawScore =
        basePoints * difficultyMultiplier * accuracy * timeBonus;

    return rawScore.round();
  }

  /// Calculate accuracy percentage
  static double calculateAccuracy({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// Determine if player should level up based on performance
  static bool shouldLevelUp({
    required double accuracy,
    required int consecutiveSuccesses,
  }) {
    // Need 80% accuracy and 3 consecutive successes to level up
    return accuracy >= 0.8 && consecutiveSuccesses >= 2;
  }

  /// Determine if player should level down
  static bool shouldLevelDown({
    required double accuracy,
    required int consecutiveFailures,
  }) {
    // Less than 50% accuracy and 2 consecutive failures
    return accuracy < 0.5 && consecutiveFailures >= 1;
  }

  /// Get a letter grade based on accuracy
  static String getGrade(double accuracy) {
    if (accuracy >= 0.95) return 'S'; // Perfect or near-perfect
    if (accuracy >= 0.9) return 'A';
    if (accuracy >= 0.8) return 'B';
    if (accuracy >= 0.7) return 'C';
    if (accuracy >= 0.6) return 'D';
    return 'F';
  }

  /// Get performance feedback message
  static String getPerformanceFeedback(double accuracy) {
    if (accuracy >= 0.95) return 'Outstanding! Perfect memory!';
    if (accuracy >= 0.9) return 'Excellent work!';
    if (accuracy >= 0.8) return 'Great job!';
    if (accuracy >= 0.7) return 'Good effort!';
    if (accuracy >= 0.6) return 'Keep practicing!';
    return 'Don\'t give up, try again!';
  }
}
