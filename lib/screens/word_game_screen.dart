import 'package:flutter/material.dart';
import 'dart:async';
import '../models/difficulty_level.dart';
import '../models/game_state.dart';
import '../services/word_game_service.dart';
import '../services/score_service.dart';
import '../widgets/score_display.dart';

/// Word Memory Game Screen
/// Players watch a list of words, then must identify which words were shown
class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  // Game services
  final WordGameService _gameService = WordGameService();

  // Game state management
  late GameState _gameState;
  late List<String> _targetWords;
  late List<String> _distractors;
  late List<String> _selectionPool;
  late Set<String> _userSelections;

  // Game phase tracking
  GamePhase _currentPhase = GamePhase.ready;

  // Animation/timer state
  Timer? _displayTimer;
  Timer? _gameTimer;
  int _displayTimeRemaining = 0;
  int _timeElapsed = 0;

  // Performance tracking
  int _currentScore = 0;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _initializeGame();
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  /// Initialize a new game round
  void _initializeGame() {
    setState(() {
      _targetWords =
          _gameService.selectTargetWords(_gameState.currentDifficulty);
      _distractors = _gameService.generateDistractors(
        targetWords: _targetWords,
        difficulty: _gameState.currentDifficulty,
      );
      _selectionPool = _gameService.createSelectionPool(
        targetWords: _targetWords,
        distractors: _distractors,
      );
      _userSelections = {};
      _timeElapsed = 0;
      _currentPhase = GamePhase.ready;

      // Calculate display time
      final stats =
          _gameService.getDifficultyStats(_gameState.currentDifficulty);
      _displayTimeRemaining = stats['displayTime'];
    });
  }

  /// Start the game by showing words
  void _startGame() {
    setState(() {
      _currentPhase = GamePhase.showing;
    });

    // Countdown timer for word display
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _displayTimeRemaining--;
      });

      if (_displayTimeRemaining <= 0) {
        timer.cancel();
        // Move to input phase
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _currentPhase = GamePhase.input;
          });
          _startGameTimer();
        });
      }
    });
  }

  /// Start the timer for user input
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
      });
    });
  }

  /// Handle word selection/deselection
  void _onWordSelected(String word) {
    if (_currentPhase != GamePhase.input) return;

    setState(() {
      if (_userSelections.contains(word)) {
        _userSelections.remove(word);
      } else {
        _userSelections.add(word);
      }
    });
  }

  /// Submit answer for validation
  void _submitAnswer() {
    if (_currentPhase != GamePhase.input) return;
    if (_userSelections.isEmpty) return;

    _gameTimer?.cancel();

    final validation = _gameService.validateSelections(
      targetWords: _targetWords,
      userSelections: _userSelections.toList(),
    );

    final config = DifficultyConfig.getConfig(_gameState.currentDifficulty);
    final score = ScoreService.calculateScore(
      difficulty: _gameState.currentDifficulty,
      correctAnswers: validation['correct'],
      totalQuestions: validation['total'],
      timeTaken: _timeElapsed,
      timeLimit: config.timeLimit,
    );

    setState(() {
      _currentScore = score;
      _currentPhase = GamePhase.result;
    });

    // Update game state for difficulty progression
    final bool success = validation['accuracy'] >= 0.8;
    _gameState = _gameState.recordResult(score: score, success: success);
  }

  /// Reset for next round
  void _playAgain() {
    _initializeGame();
  }

  /// Go back to home
  void _goHome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Memory'),
        actions: [
          if (_currentPhase == GamePhase.input)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_userSelections.length}/${_targetWords.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score display
              ScoreDisplay(
                score: _gameState.currentScore,
                difficulty: _gameState.currentDifficulty,
                timeRemaining: _currentPhase == GamePhase.input
                    ? DifficultyConfig.getConfig(_gameState.currentDifficulty)
                            .timeLimit -
                        _timeElapsed
                    : null,
              ),
              const SizedBox(height: 24),

              // Phase-specific content
              Expanded(
                child: _buildPhaseContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build content based on current game phase
  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case GamePhase.ready:
        return _buildReadyPhase();
      case GamePhase.showing:
        return _buildShowingPhase();
      case GamePhase.input:
        return _buildInputPhase();
      case GamePhase.result:
        return _buildResultPhase();
    }
  }

  /// Ready phase - instructions and start button
  Widget _buildReadyPhase() {
    final stats = _gameService.getDifficultyStats(_gameState.currentDifficulty);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.text_fields,
              size: 80,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            Text(
              'Word Memory',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'How to Play:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Memorize the words shown\n'
                    '2. Words will display for ${stats['displayTime']} seconds\n'
                    '3. Select words you saw from the list\n'
                    '4. Avoid selecting words you didn\'t see\n\n'
                    'Words to remember: ${stats['wordCount']}\n'
                    'Total choices: ${stats['totalChoices']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Showing phase - display words to memorize
  Widget _buildShowingPhase() {
    return Column(
      children: [
        // Timer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                '$_displayTimeRemaining seconds',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        const Text(
          'Memorize These Words!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Word list
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: _targetWords.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _targetWords[index],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Input phase - select words from pool
  Widget _buildInputPhase() {
    return Column(
      children: [
        const Text(
          'Select the Words You Saw!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Word selection grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _selectionPool.length,
            itemBuilder: (context, index) {
              final word = _selectionPool[index];
              final isSelected = _userSelections.contains(word);

              return InkWell(
                onTap: () => _onWordSelected(word),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? Colors.purple[700]! : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Submit button
        ElevatedButton(
          onPressed: _userSelections.isNotEmpty ? _submitAnswer : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: const Text(
            'Submit Answer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Result phase - show score and feedback
  Widget _buildResultPhase() {
    final validation = _gameService.validateSelections(
      targetWords: _targetWords,
      userSelections: _userSelections.toList(),
    );

    final accuracy = validation['accuracy'] as double;
    final grade = ScoreService.getGrade(accuracy);
    final feedback = ScoreService.getPerformanceFeedback(accuracy);
    final isPerfect = validation['isPerfect'] as bool;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Performance icon
            Icon(
              isPerfect ? Icons.emoji_events : Icons.check_circle,
              size: 80,
              color: isPerfect ? Colors.amber : Colors.purple,
            ),
            const SizedBox(height: 16),

            // Grade
            Text(
              'Grade: $grade',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),

            // Feedback
            Text(
              feedback,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Show word breakdown
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Word Breakdown:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWordList(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Score Earned',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+$_currentScore',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                      'Accuracy', '${(accuracy * 100).toStringAsFixed(1)}%'),
                  _buildStatRow('Correct',
                      '${validation['correct']}/${validation['total']}'),
                  _buildStatRow(
                      'Wrong Picks', '${validation['falsePositives']}'),
                  _buildStatRow('Missed', '${validation['falseNegatives']}'),
                  _buildStatRow('Time', '${_timeElapsed}s'),
                  _buildStatRow('Total Score', '${_gameState.currentScore}'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _goHome,
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _playAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build color-coded word list for results
  Widget _buildWordList() {
    final targetSet = _targetWords.toSet();
    final userSet = _userSelections;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectionPool.map((word) {
        final isTarget = targetSet.contains(word);
        final isSelected = userSet.contains(word);

        Color backgroundColor;
        Color textColor;
        IconData? icon;

        if (isTarget && isSelected) {
          // Correct selection
          backgroundColor = Colors.green[100]!;
          textColor = Colors.green[900]!;
          icon = Icons.check_circle;
        } else if (isTarget && !isSelected) {
          // Missed word
          backgroundColor = Colors.orange[100]!;
          textColor = Colors.orange[900]!;
          icon = Icons.error;
        } else if (!isTarget && isSelected) {
          // Wrong selection
          backgroundColor = Colors.red[100]!;
          textColor = Colors.red[900]!;
          icon = Icons.cancel;
        } else {
          // Correctly not selected
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 4),
              Text(
                word,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum to track game phases
enum GamePhase {
  ready, // Initial state with instructions
  showing, // Showing words to memorize
  input, // User is selecting words
  result, // Showing results and score
}
