import 'dart:math';
import 'package:flutter/material.dart';
import '../models/difficulty_level.dart';

/// Service for managing Sequence Memory game logic
/// Generates random sequences of colors and validates user input
class SequenceGameService {
  final Random _random = Random();

  // Available colors for the sequence
  static const List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  // Color names for display
  static final Map<Color, String> colorNames = {
    Colors.red: 'Red',
    Colors.blue: 'Blue',
    Colors.green: 'Green',
    Colors.yellow: 'Yellow',
    Colors.purple: 'Purple',
    Colors.orange: 'Orange',
    Colors.pink: 'Pink',
    Colors.teal: 'Teal',
  };

  /// Generate a random sequence of colors based on difficulty
  ///
  /// Algorithm:
  /// 1. Get the element count from difficulty configuration
  /// 2. Randomly select colors from availableColors
  /// 3. Ensure variety by avoiding too many consecutive duplicates
  ///
  /// Returns: List of Color objects representing the sequence
  List<Color> generateSequence(DifficultyLevel difficulty) {
    final config = DifficultyConfig.getConfig(difficulty);
    final int length = config.elementCount;
    final List<Color> sequence = [];

    // Generate random sequence
    for (int i = 0; i < length; i++) {
      Color newColor;

      // Avoid same color appearing more than twice in a row
      if (i >= 2 && sequence[i - 1] == sequence[i - 2]) {
        // Pick a different color
        do {
          newColor = availableColors[_random.nextInt(availableColors.length)];
        } while (newColor == sequence[i - 1]);
      } else {
        newColor = availableColors[_random.nextInt(availableColors.length)];
      }

      sequence.add(newColor);
    }

    return sequence;
  }

  /// Validate user's input sequence against the correct sequence
  ///
  /// Parameters:
  /// - correctSequence: The original sequence to remember
  /// - userSequence: The sequence entered by the user
  ///
  /// Returns: Map containing validation results
  Map<String, dynamic> validateSequence({
    required List<Color> correctSequence,
    required List<Color> userSequence,
  }) {
    int correctCount = 0;
    int incorrectCount = 0;
    final List<bool> positionResults = [];

    // Compare each position
    final int minLength = correctSequence.length < userSequence.length
        ? correctSequence.length
        : userSequence.length;

    for (int i = 0; i < minLength; i++) {
      if (correctSequence[i] == userSequence[i]) {
        correctCount++;
        positionResults.add(true);
      } else {
        incorrectCount++;
        positionResults.add(false);
      }
    }

    // Handle length mismatch
    if (userSequence.length < correctSequence.length) {
      // User didn't complete the sequence
      incorrectCount += correctSequence.length - userSequence.length;
      for (int i = minLength; i < correctSequence.length; i++) {
        positionResults.add(false);
      }
    }

    final double accuracy = correctSequence.isNotEmpty
        ? correctCount / correctSequence.length
        : 0.0;

    return {
      'correct': correctCount,
      'incorrect': incorrectCount,
      'total': correctSequence.length,
      'accuracy': accuracy,
      'positionResults': positionResults,
      'isPerfect': correctCount == correctSequence.length &&
          userSequence.length == correctSequence.length,
    };
  }

  /// Get color name for display
  static String getColorName(Color color) {
    return colorNames[color] ?? 'Unknown';
  }

  /// Check if two colors match (handles Material color comparison)
  static bool colorsMatch(Color color1, Color color2) {
    return color1.value == color2.value;
  }

  /// Get a random subset of colors for user selection
  /// Always includes all colors from the sequence plus some distractors
  List<Color> getColorChoices(List<Color> sequence) {
    final Set<Color> choices = sequence.toSet();

    // Add random distractors until we have 6-8 choices
    while (choices.length < 6) {
      choices.add(availableColors[_random.nextInt(availableColors.length)]);
    }

    // Convert to list and shuffle
    final List<Color> choiceList = choices.toList();
    choiceList.shuffle(_random);

    return choiceList;
  }
}
