import 'dart:math';
import '../models/difficulty_level.dart';

/// Service for managing Word Memory game logic
/// Maintains word pool, generates distractors, and validates selections
class WordGameService {
  final Random _random = Random();

  /// In-memory word pool - categorized by length for better distractor generation
  /// Using common, recognizable English words
  static const List<String> _wordPool = [
    // 4-letter words
    'book', 'tree', 'fish', 'door', 'hand', 'moon', 'star', 'rain', 'snow',
    'wind',
    'fire', 'lake', 'hill', 'road', 'park', 'bird', 'frog', 'bear', 'wolf',
    'duck',
    'boat', 'ship', 'wave', 'sand', 'rock', 'gold', 'coin', 'king', 'ring',
    'bell',
    'wall', 'roof', 'lamp', 'desk', 'sock', 'shoe', 'coat', 'mask', 'gift',
    'cake',
    'milk', 'rice', 'soup', 'meat', 'salt', 'bean', 'corn', 'leaf', 'root',
    'seed',

    // 5-letter words
    'apple', 'beach', 'chair', 'dance', 'eagle', 'flame', 'glass', 'heart',
    'juice',
    'knife', 'lemon', 'mouse', 'night', 'ocean', 'peace', 'queen', 'river',
    'smile',
    'table', 'umbra', 'video', 'water', 'youth', 'zebra', 'bread', 'crown',
    'dream',
    'earth', 'field', 'grass', 'horse', 'image', 'jewel', 'light', 'magic',
    'noise',
    'olive', 'plant', 'quick', 'round', 'sheep', 'tower', 'uncle', 'voice',
    'wheat',
    'world', 'young', 'amber', 'brain', 'cloud', 'daisy', 'eagle', 'fruit',
    'giant',

    // 6-letter words
    'garden', 'bridge', 'castle', 'dragon', 'engine', 'forest', 'guitar',
    'hammer',
    'island', 'jacket', 'kitten', 'ladder', 'market', 'nature', 'orange',
    'planet',
    'rabbit', 'shadow', 'temple', 'valley', 'window', 'yellow', 'anchor',
    'bottle',
    'candle', 'diamond', 'empire', 'flower', 'garden', 'hunter', 'insect',
    'jungle',
    'kernel', 'lizard', 'monkey', 'nation', 'office', 'pencil', 'rocket',
    'salmon',
    'thread', 'turtle', 'violet', 'weapon', 'winter', 'zombie', 'butter',
    'cheese',

    // 7-letter words
    'adventure', 'balloon', 'chicken', 'dolphin', 'elephant', 'freedom',
    'giraffe',
    'harmony', 'journey', 'kitchen', 'library', 'monster', 'network', 'octopus',
    'package', 'rainbow', 'sunrise', 'thunder', 'volcano', 'whisper', 'bedroom',
    'package', 'fiction', 'gallery', 'highway', 'inspire', 'justice', 'leopard',
    'message', 'nominee', 'outdoor', 'picture', 'quarter', 'respect', 'science',
    'teacher', 'uniform', 'victory', 'warrior', 'wrestle', 'classic', 'destiny',

    // 8+ letter words
    'beautiful', 'butterfly', 'chocolate', 'discovery', 'education',
    'fantastic',
    'happiness', 'important', 'landscape', 'mountain', 'navigate', 'paradise',
    'question', 'remember', 'sandwich', 'together', 'universe', 'vacation',
    'waterfall', 'yesterday', 'adventure', 'brilliant', 'celebrate',
    'dangerous',
    'excellent', 'furniture', 'golden', 'hospital', 'internet', 'jalapeno',
    'knowledge', 'lightning', 'midnight', 'notebook', 'opposite', 'peaceful',
    'quadrant', 'rainbow', 'skeleton', 'treasure', 'umbrella', 'vineyard',
    'wonderful', 'xylophone', 'yearbook', 'zeppelin', 'absolute', 'backbone',
    'carnival', 'daughter', 'eloquent', 'festival', 'graceful', 'handbook',
    'iceberg', 'joyfully', 'keyboard', 'landmark', 'mystical', 'northern',
    'original', 'passport', 'riverbed', 'sculptor', 'tropical', 'underdog',
    'valuable', 'woodland', 'abstract', 'backbone', 'creature', 'delicate',
    'enormous', 'flexible', 'grandeur', 'heritage', 'innovate', 'juncture',
    'kingship', 'lavender', 'momentum', 'newsroom', 'overseas', 'platform',
    'quixotic', 'romantic', 'starfish', 'timeless', 'unfold', 'variance',
    'wildfire', 'yeomanry', 'zodiacal', 'balanced', 'capacity', 'decisive',
    'energize', 'forecast', 'grateful', 'handbook', 'idealism', 'judgment',
  ];

  /// Get number of words to display based on difficulty
  int getWordCount(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 5; // Easy to remember
      case DifficultyLevel.intermediate:
        return 8; // Moderate challenge
      case DifficultyLevel.advanced:
        return 12; // Difficult
      case DifficultyLevel.expert:
        return 15; // Very challenging
    }
  }

  /// Get display time per word (in seconds)
  int getDisplayTimePerWord(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 3; // 3 seconds per word
      case DifficultyLevel.intermediate:
        return 2; // 2 seconds per word
      case DifficultyLevel.advanced:
        return 2; // 2 seconds per word
      case DifficultyLevel.expert:
        return 1; // 1 second per word
    }
  }

  /// Get number of distractor words to mix with target words
  int getDistractorCount(DifficultyLevel difficulty) {
    final wordCount = getWordCount(difficulty);
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return wordCount; // 1:1 ratio (easy to identify)
      case DifficultyLevel.intermediate:
        return (wordCount * 1.5).round(); // More distractors
      case DifficultyLevel.advanced:
        return wordCount * 2; // 2:1 ratio
      case DifficultyLevel.expert:
        return wordCount * 2; // 2:1 ratio with harder distractors
    }
  }

  /// Select random words for the memory phase
  ///
  /// Algorithm:
  /// 1. Get word count based on difficulty
  /// 2. Shuffle word pool
  /// 3. Select first N words
  ///
  /// Returns: List of words to display
  List<String> selectTargetWords(DifficultyLevel difficulty) {
    final count = getWordCount(difficulty);
    final shuffled = List<String>.from(_wordPool)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Generate distractor words (words NOT shown, for selection phase)
  ///
  /// Algorithm:
  /// 1. Calculate number of distractors needed
  /// 2. Filter out target words from pool
  /// 3. For harder difficulties, select similar-length words
  /// 4. Shuffle and select N distractors
  ///
  /// Returns: List of distractor words
  List<String> generateDistractors({
    required List<String> targetWords,
    required DifficultyLevel difficulty,
  }) {
    final count = getDistractorCount(difficulty);

    // Words that weren't shown
    final availableWords =
        _wordPool.where((w) => !targetWords.contains(w)).toList();

    // For harder difficulties, select distractors with similar lengths
    if (difficulty == DifficultyLevel.advanced ||
        difficulty == DifficultyLevel.expert) {
      // Get length distribution of target words
      final targetLengths = targetWords.map((w) => w.length).toSet();

      // Prefer distractors with similar lengths
      final similarLength = availableWords
          .where((w) => targetLengths.any((len) => (w.length - len).abs() <= 2))
          .toList();

      if (similarLength.length >= count) {
        similarLength.shuffle(_random);
        return similarLength.take(count).toList();
      }
    }

    // Default: random distractors
    availableWords.shuffle(_random);
    return availableWords.take(count).toList();
  }

  /// Create the selection pool (target words + distractors, shuffled)
  ///
  /// Returns: Shuffled list of all words to choose from
  List<String> createSelectionPool({
    required List<String> targetWords,
    required List<String> distractors,
  }) {
    final pool = [...targetWords, ...distractors];
    pool.shuffle(_random);
    return pool;
  }

  /// Validate user's word selections
  ///
  /// Algorithm:
  /// 1. Calculate true positives (correct selections)
  /// 2. Calculate false positives (wrong selections)
  /// 3. Calculate false negatives (missed words)
  /// 4. Compute accuracy metrics
  ///
  /// Returns: Map containing validation results
  Map<String, dynamic> validateSelections({
    required List<String> targetWords,
    required List<String> userSelections,
  }) {
    final targetSet = targetWords.toSet();
    final userSet = userSelections.toSet();

    // Calculate metrics
    final truePositives = targetSet.intersection(userSet).length;
    final falsePositives = userSet.difference(targetSet).length;
    final falseNegatives = targetSet.difference(userSet).length;

    final totalTarget = targetWords.length;
    final accuracy = totalTarget > 0 ? truePositives / totalTarget : 0.0;
    final precision =
        userSelections.isNotEmpty ? truePositives / userSelections.length : 0.0;

    final isPerfect = truePositives == totalTarget && falsePositives == 0;

    return {
      'correct': truePositives,
      'falsePositives': falsePositives,
      'falseNegatives': falseNegatives,
      'total': totalTarget,
      'accuracy': accuracy, // Recall
      'precision': precision,
      'isPerfect': isPerfect,
    };
  }

  /// Get difficulty statistics for display
  Map<String, dynamic> getDifficultyStats(DifficultyLevel difficulty) {
    final wordCount = getWordCount(difficulty);
    final timePerWord = getDisplayTimePerWord(difficulty);
    final totalDisplayTime = wordCount * timePerWord;

    return {
      'wordCount': wordCount,
      'displayTime': totalDisplayTime,
      'timePerWord': timePerWord,
      'distractorCount': getDistractorCount(difficulty),
      'totalChoices': wordCount + getDistractorCount(difficulty),
    };
  }

  /// Get total word pool size
  static int get wordPoolSize => _wordPool.length;
}
