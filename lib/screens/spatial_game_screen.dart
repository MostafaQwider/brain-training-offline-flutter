import 'package:flutter/material.dart';
import 'dart:async';
import '../models/difficulty_level.dart';
import '../models/game_state.dart';
import '../services/spatial_game_service.dart';
import '../services/score_service.dart';
import '../widgets/score_display.dart';

/// Spatial Memory Game Screen
/// Players watch tiles light up in a grid and must remember which tiles were highlighted
class SpatialGameScreen extends StatefulWidget {
  const SpatialGameScreen({super.key});

  @override
  State<SpatialGameScreen> createState() => _SpatialGameScreenState();
}

class _SpatialGameScreenState extends State<SpatialGameScreen> {
  // Game services
  final SpatialGameService _gameService = SpatialGameService();

  // Game state management
  late GameState _gameState;
  late Set<TilePosition> _correctPattern;
  late Set<TilePosition> _userSelections;
  late int _gridSize;

  // Game phase tracking
  GamePhase _currentPhase = GamePhase.ready;

  // Animation state
  int _displayIndex = 0;
  Timer? _patternTimer;
  Timer? _gameTimer;
  List<TilePosition> _patternSequence = [];

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
    _patternTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  /// Initialize a new game round
  void _initializeGame() {
    setState(() {
      _gridSize = _gameService.getGridSize(_gameState.currentDifficulty);
      _correctPattern =
          _gameService.generatePattern(_gameState.currentDifficulty);
      _userSelections = {};
      _displayIndex = 0;
      _timeElapsed = 0;
      _currentPhase = GamePhase.ready;
      _patternSequence = _correctPattern.toList()..shuffle();
    });
  }

  /// Start the game by showing the pattern
  void _startGame() {
    setState(() {
      _currentPhase = GamePhase.showing;
      _displayIndex = 0;
    });

    // Show pattern tiles one at a time
    _patternTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_displayIndex < _patternSequence.length) {
        setState(() {
          _displayIndex++;
        });
      } else {
        timer.cancel();
        // Move to input phase after showing complete pattern
        Future.delayed(const Duration(milliseconds: 800), () {
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

  /// Handle user tile selection/deselection
  void _onTileSelected(TilePosition position) {
    if (_currentPhase != GamePhase.input) return;

    setState(() {
      if (_userSelections.contains(position)) {
        // Deselect if already selected
        _userSelections.remove(position);
      } else {
        // Select tile
        _userSelections.add(position);
      }
    });
  }

  /// Submit user's answer for validation
  void _submitAnswer() {
    if (_currentPhase != GamePhase.input) return;
    if (_userSelections.isEmpty) return;

    _gameTimer?.cancel();

    final validation = _gameService.validatePattern(
      correctPattern: _correctPattern,
      userSelections: _userSelections,
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
        title: const Text('Spatial Memory'),
        actions: [
          if (_currentPhase == GamePhase.input)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_userSelections.length}/${_correctPattern.length}',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.grid_4x4,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'Spatial Memory',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green[50],
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
                  '1. Watch which tiles light up\n'
                  '2. Remember their positions\n'
                  '3. Tap the tiles that were lit\n'
                  '4. Press Submit when done\n\n'
                  'Grid: ${stats['gridSize']}×${stats['gridSize']} | '
                  'Pattern: ${stats['patternSize']} tiles',
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
              backgroundColor: Colors.green,
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

  /// Showing phase - display the pattern
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

        // Display grid with animated pattern
        _buildGrid(showPattern: true, interactive: false),
      ],
    );
  }

  /// Input phase - user selects tiles
  Widget _buildInputPhase() {
    return Column(
      children: [
        const Text(
          'Tap the Tiles!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Interactive grid
        Expanded(
          child: _buildGrid(showPattern: false, interactive: true),
        ),

        const SizedBox(height: 20),

        // Submit button
        ElevatedButton(
          onPressed: _userSelections.isNotEmpty ? _submitAnswer : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            backgroundColor: Colors.green,
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
    final validation = _gameService.validatePattern(
      correctPattern: _correctPattern,
      userSelections: _userSelections,
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
                color: Colors.green,
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

            // Show the correct pattern
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Correct Pattern:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: _buildGrid(
                      showPattern: true,
                      interactive: false,
                      showResults: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
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
                      color: Colors.green,
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
                      'Wrong Tiles', '${validation['falsePositives']}'),
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
                    backgroundColor: Colors.green,
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

  /// Build the grid of tiles
  Widget _buildGrid({
    required bool showPattern,
    required bool interactive,
    bool showResults = false,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridSize,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _gridSize * _gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ _gridSize;
          final col = index % _gridSize;
          final position = TilePosition(row, col);

          final isInPattern = _correctPattern.contains(position);
          final isSelected = _userSelections.contains(position);
          final isCurrentlyShowing = showPattern &&
              _patternSequence.take(_displayIndex).contains(position);

          // Determine tile color
          Color tileColor;
          if (showResults) {
            // In result phase, show correct pattern
            if (isInPattern && isSelected) {
              tileColor = Colors.green; // Correct selection
            } else if (isInPattern) {
              tileColor = Colors.orange; // Missed tile
            } else if (isSelected) {
              tileColor = Colors.red; // Wrong selection
            } else {
              tileColor = Colors.grey[300]!;
            }
          } else if (isCurrentlyShowing) {
            tileColor = Colors.green; // Showing pattern
          } else if (isSelected) {
            tileColor = Colors.blue; // User selected
          } else {
            tileColor = Colors.grey[300]!; // Default
          }

          return GestureDetector(
            onTap: interactive ? () => _onTileSelected(position) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isCurrentlyShowing || isSelected
                    ? [
                        BoxShadow(
                          color: tileColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
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
  showing, // Showing the pattern to remember
  input, // User is selecting tiles
  result, // Showing results and score
}
