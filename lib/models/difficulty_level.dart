/// Enumeration for difficulty levels in memory games
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Configuration for difficulty levels
class DifficultyConfig {
  final DifficultyLevel level;
  final int elementCount; // Number of elements to remember
  final int timeLimit; // Time limit in seconds
  final String displayName;

  const DifficultyConfig({
    required this.level,
    required this.elementCount,
    required this.timeLimit,
    required this.displayName,
  });

  /// Get configuration for a specific difficulty level
  static DifficultyConfig getConfig(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return const DifficultyConfig(
          level: DifficultyLevel.beginner,
          elementCount: 4,
          timeLimit: 30,
          displayName: 'Beginner',
        );
      case DifficultyLevel.intermediate:
        return const DifficultyConfig(
          level: DifficultyLevel.intermediate,
          elementCount: 6,
          timeLimit: 25,
          displayName: 'Intermediate',
        );
      case DifficultyLevel.advanced:
        return const DifficultyConfig(
          level: DifficultyLevel.advanced,
          elementCount: 8,
          timeLimit: 20,
          displayName: 'Advanced',
        );
      case DifficultyLevel.expert:
        return const DifficultyConfig(
          level: DifficultyLevel.expert,
          elementCount: 10,
          timeLimit: 15,
          displayName: 'Expert',
        );
    }
  }

  /// Calculate difficulty multiplier for scoring
  double get multiplier {
    switch (level) {
      case DifficultyLevel.beginner:
        return 1.0;
      case DifficultyLevel.intermediate:
        return 1.5;
      case DifficultyLevel.advanced:
        return 2.0;
      case DifficultyLevel.expert:
        return 2.5;
    }
  }
}
