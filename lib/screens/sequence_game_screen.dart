import 'package:flutter/material.dart';
import 'dart:async';
import '../models/difficulty_level.dart';
import '../models/game_state.dart';
import '../services/sequence_game_service.dart';
import '../services/score_service.dart';
import '../widgets/score_display.dart';

/// Sequence Memory Game Screen
/// Players watch a sequence of colors and must repeat it in the same order
class SequenceGameScreen extends StatefulWidget {
  const SequenceGameScreen({super.key});

  @override
  State<SequenceGameScreen> createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen> {
  // Game services
  final SequenceGameService _gameService = SequenceGameService();

  // Game state management
  late GameState _gameState;
  late List<Color> _currentSequence;
  late List<Color> _userSequence;
  late List<Color> _availableColors;

  // Game phase tracking
  GamePhase _currentPhase = GamePhase.ready;

  // Animation state
  int _displayIndex = 0;
  Timer? _sequenceTimer;
  Timer? _gameTimer;

  // Performance tracking
  int _timeElapsed = 0;
  int _currentScore = 0;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _initializeGame();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  /// Initialize a new game round
  void _initializeGame() {
    setState(() {
      _currentSequence =
          _gameService.generateSequence(_gameState.currentDifficulty);
      _userSequence = [];
      _availableColors = _gameService.getColorChoices(_currentSequence);
      _displayIndex = 0;
      _timeElapsed = 0;
      _currentPhase = GamePhase.ready;
    });
  }

  /// Start the game by showing the sequence
  void _startGame() {
    setState(() {
      _currentPhase = GamePhase.showing;
      _displayIndex = 0;
    });

    // Show sequence one color at a time
    _sequenceTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_displayIndex < _currentSequence.length) {
        setState(() {
          _displayIndex++;
        });
      } else {
        timer.cancel();
        // Move to input phase after showing complete sequence
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

  /// Handle user color selection
  void _onColorSelected(Color color) {
    if (_currentPhase != GamePhase.input) return;

    setState(() {
      _userSequence.add(color);
    });

    // Check if sequence is complete
    if (_userSequence.length >= _currentSequence.length) {
      _validateAndFinish();
    }
  }

  /// Validate user input and show results
  void _validateAndFinish() {
    _gameTimer?.cancel();

    final validation = _gameService.validateSequence(
      correctSequence: _currentSequence,
      userSequence: _userSequence,
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
        title: const Text('Sequence Memory'),
        actions: [
          if (_currentPhase == GamePhase.input)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_userSequence.length}/${_currentSequence.length}',
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
    final config = DifficultyConfig.getConfig(_gameState.currentDifficulty);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.psychology,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Sequence Memory',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
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
                  '1. Watch the sequence of colors\n'
                  '2. Remember the order\n'
                  '3. Repeat the sequence by tapping colors\n\n'
                  'Sequence length: ${config.elementCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Start Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Showing phase - display the sequence
  Widget _buildShowingPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Watch and Remember!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),

        // Display sequence
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_currentSequence.length, (index) {
            final isVisible = index < _displayIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isVisible ? _currentSequence[index] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: isVisible
                    ? [
                        BoxShadow(
                          color: _currentSequence[index].withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Input phase - user selects colors
  Widget _buildInputPhase() {
    return Column(
      children: [
        const Text(
          'Repeat the Sequence!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // User's sequence so far
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._userSequence.map((color) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  )),
              // Placeholder for remaining spots
              ...List.generate(
                _currentSequence.length - _userSequence.length,
                (index) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Color selection buttons
        const Text(
          'Tap the colors:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              return InkWell(
                onTap: () => _onColorSelected(color),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      SequenceGameService.getColorName(color),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Result phase - show score and feedback
  Widget _buildResultPhase() {
    final validation = _gameService.validateSequence(
      correctSequence: _currentSequence,
      userSequence: _userSequence,
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
              color: isPerfect ? Colors.amber : Colors.green,
            ),
            const SizedBox(height: 16),

            // Grade
            Text(
              'Grade: $grade',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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

            // Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
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
                      color: Colors.blue,
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
                    backgroundColor: Colors.blue,
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
  showing, // Showing the sequence to remember
  input, // User is inputting their answer
  result, // Showing results and score
}
