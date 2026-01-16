import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import 'sequence_game_screen.dart';
import 'spatial_game_screen.dart';
import 'word_game_screen.dart';

/// Home screen with game mode selection
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Training'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[50],
        surfaceTintColor: Colors.blue[50],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              const SizedBox(height: 20),
              Text(
                'Train Your Brain',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a game to start training',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Game Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.8,
                  children: [
                    // Sequence Memory Game
                    GameCard(
                      title: 'Sequence Memory',
                      description: 'Remember the order of colors',
                      icon: Icons.grid_4x4,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SequenceGameScreen(),
                          ),
                        );
                      },
                    ),

                    // Spatial Memory Game
                    GameCard(
                      title: 'Spatial Memory',
                      description: 'Remember tile positions',
                      icon: Icons.apps,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpatialGameScreen(),
                          ),
                        );
                      },
                    ),

                    // Word Memory Game
                    GameCard(
                      title: 'Word Memory',
                      description: 'Remember the words shown',
                      icon: Icons.text_fields,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WordGameScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Instructions
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Select a game mode to begin\n'
                      '• Complete exercises to earn points\n'
                      '• Difficulty increases with success\n'
                      '• All progress is stored in memory',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
