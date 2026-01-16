import 'difficulty_level.dart';

/// Represents the current state of a game session
class GameState {
  final DifficultyLevel currentDifficulty;
  final int currentScore;
  final int consecutiveSuccesses;
  final int consecutiveFailures;
  final List<int> recentScores;

  GameState({
    this.currentDifficulty = DifficultyLevel.beginner,
    this.currentScore = 0,
    this.consecutiveSuccesses = 0,
    this.consecutiveFailures = 0,
    List<int>? recentScores,
  }) : recentScores = recentScores ?? [];

  /// Create a new state with updated values
  GameState copyWith({
    DifficultyLevel? currentDifficulty,
    int? currentScore,
    int? consecutiveSuccesses,
    int? consecutiveFailures,
    List<int>? recentScores,
  }) {
    return GameState(
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      currentScore: currentScore ?? this.currentScore,
      consecutiveSuccesses: consecutiveSuccesses ?? this.consecutiveSuccesses,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      recentScores: recentScores ?? this.recentScores,
    );
  }

  /// Update difficulty based on performance
  /// 3 consecutive successes -> level up
  /// 2 consecutive failures -> level down
  DifficultyLevel getNextDifficulty(bool success) {
    if (success) {
      final newSuccesses = consecutiveSuccesses + 1;
      if (newSuccesses >= 3 && currentDifficulty != DifficultyLevel.expert) {
        // Level up
        return DifficultyLevel.values[currentDifficulty.index + 1];
      }
    } else {
      final newFailures = consecutiveFailures + 1;
      if (newFailures >= 2 && currentDifficulty != DifficultyLevel.beginner) {
        // Level down
        return DifficultyLevel.values[currentDifficulty.index - 1];
      }
    }
    return currentDifficulty;
  }

  /// Record a game result and update state
  GameState recordResult({required int score, required bool success}) {
    final newScores = [...recentScores, score];
    // Keep only last 10 scores
    if (newScores.length > 10) {
      newScores.removeAt(0);
    }

    final newDifficulty = getNextDifficulty(success);

    return copyWith(
      currentScore: currentScore + score,
      currentDifficulty: newDifficulty,
      consecutiveSuccesses: success ? consecutiveSuccesses + 1 : 0,
      consecutiveFailures: success ? 0 : consecutiveFailures + 1,
      recentScores: newScores,
    );
  }

  /// Calculate average score from recent games
  double get averageScore {
    if (recentScores.isEmpty) return 0.0;
    return recentScores.reduce((a, b) => a + b) / recentScores.length;
  }
}
