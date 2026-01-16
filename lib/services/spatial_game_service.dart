import 'dart:math';
import '../models/difficulty_level.dart';

/// Represents a single tile position in the grid
class TilePosition {
  final int row;
  final int col;

  const TilePosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TilePosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'TilePosition($row, $col)';
}

/// Service for managing Spatial Memory game logic
/// Generates grid patterns and validates user selections
class SpatialGameService {
  final Random _random = Random();

  /// Get grid size based on difficulty level
  ///
  /// Returns: Grid dimension (e.g., 3 for 3×3, 4 for 4×4)
  int getGridSize(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 3; // 3×3 grid = 9 tiles
      case DifficultyLevel.intermediate:
        return 4; // 4×4 grid = 16 tiles
      case DifficultyLevel.advanced:
        return 5; // 5×5 grid = 25 tiles
      case DifficultyLevel.expert:
        return 6; // 6×6 grid = 36 tiles
    }
  }

  /// Get number of tiles to light up based on difficulty
  ///
  /// Algorithm:
  /// - Uses a percentage of total tiles
  /// - Ensures minimum variety and challenge
  int getPatternSize(DifficultyLevel difficulty) {
    final gridSize = getGridSize(difficulty);
    final totalTiles = gridSize * gridSize;

    switch (difficulty) {
      case DifficultyLevel.beginner:
        return (totalTiles * 0.33).round(); // ~33% of tiles (3 out of 9)
      case DifficultyLevel.intermediate:
        return (totalTiles * 0.35).round(); // ~35% of tiles (5-6 out of 16)
      case DifficultyLevel.advanced:
        return (totalTiles * 0.36).round(); // ~36% of tiles (9 out of 25)
      case DifficultyLevel.expert:
        return (totalTiles * 0.38).round(); // ~38% of tiles (13-14 out of 36)
    }
  }

  /// Generate a random pattern of tiles to light up
  ///
  /// Algorithm:
  /// 1. Get grid size and pattern size based on difficulty
  /// 2. Create list of all possible tile positions
  /// 3. Randomly shuffle and select N positions
  /// 4. Ensure no clustering (optional spacing constraint)
  ///
  /// Returns: Set of TilePosition objects representing the pattern
  Set<TilePosition> generatePattern(DifficultyLevel difficulty) {
    final gridSize = getGridSize(difficulty);
    final patternSize = getPatternSize(difficulty);

    // Create all possible positions
    final List<TilePosition> allPositions = [];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        allPositions.add(TilePosition(row, col));
      }
    }

    // Shuffle and select random positions
    allPositions.shuffle(_random);

    // Take first N positions from shuffled list
    final pattern = allPositions.take(patternSize).toSet();

    return pattern;
  }

  /// Validate user's selected tiles against the correct pattern
  ///
  /// Algorithm:
  /// 1. Calculate correctly selected tiles (in pattern and selected)
  /// 2. Calculate false positives (selected but not in pattern)
  /// 3. Calculate false negatives (in pattern but not selected)
  /// 4. Compute accuracy metrics
  ///
  /// Parameters:
  /// - correctPattern: The pattern to remember
  /// - userSelections: The tiles selected by the user
  ///
  /// Returns: Map containing validation results
  Map<String, dynamic> validatePattern({
    required Set<TilePosition> correctPattern,
    required Set<TilePosition> userSelections,
  }) {
    // Calculate hits (correct selections)
    final truePositives = correctPattern.intersection(userSelections).length;

    // Calculate false positives (selected but shouldn't be)
    final falsePositives = userSelections.difference(correctPattern).length;

    // Calculate false negatives (should be selected but weren't)
    final falseNegatives = correctPattern.difference(userSelections).length;

    // Calculate accuracy
    // Perfect score = all pattern tiles selected, no extra tiles
    final totalPatternSize = correctPattern.length;
    final accuracy =
        totalPatternSize > 0 ? truePositives / totalPatternSize : 0.0;

    // Check for perfect match
    final isPerfect = truePositives == totalPatternSize && falsePositives == 0;

    // Calculate precision (of selected tiles, how many were correct)
    final precision =
        userSelections.isNotEmpty ? truePositives / userSelections.length : 0.0;

    return {
      'correct': truePositives,
      'falsePositives': falsePositives,
      'falseNegatives': falseNegatives,
      'total': totalPatternSize,
      'accuracy': accuracy, // Recall: what % of pattern was found
      'precision': precision, // What % of selections were correct
      'isPerfect': isPerfect,
      'score': _calculatePatternScore(
        truePositives,
        falsePositives,
        totalPatternSize,
      ),
    };
  }

  /// Calculate a simple pattern matching score
  /// Rewards correct selections, penalizes wrong ones
  double _calculatePatternScore(
    int correct,
    int falsePositives,
    int total,
  ) {
    if (total == 0) return 0.0;

    // Base accuracy
    final baseScore = correct / total;

    // Penalty for false positives
    final penalty = falsePositives * 0.1; // 10% penalty per wrong tile

    // Final score (minimum 0.0)
    return (baseScore - penalty).clamp(0.0, 1.0);
  }

  /// Check if a tile is adjacent to any tile in the set
  /// Used for pattern analysis and validation
  bool isAdjacentTo(TilePosition tile, Set<TilePosition> tiles) {
    for (final other in tiles) {
      final rowDiff = (tile.row - other.row).abs();
      final colDiff = (tile.col - other.col).abs();

      // Adjacent if within 1 tile distance (including diagonals)
      if (rowDiff <= 1 && colDiff <= 1 && (rowDiff + colDiff > 0)) {
        return true;
      }
    }
    return false;
  }

  /// Get difficulty statistics for display
  Map<String, int> getDifficultyStats(DifficultyLevel difficulty) {
    return {
      'gridSize': getGridSize(difficulty),
      'patternSize': getPatternSize(difficulty),
      'totalTiles': getGridSize(difficulty) * getGridSize(difficulty),
    };
  }
}
