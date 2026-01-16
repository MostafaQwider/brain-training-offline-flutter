import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Entry point for the Memory Training application
/// This app is completely offline and uses in-memory data structures only
void main() {
  runApp(const MemoryTrainingApp());
}

/// Root application widget
class MemoryTrainingApp extends StatelessWidget {
  const MemoryTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Training',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern color scheme with blue as primary
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Card theme for consistent elevation
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // App bar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // Start with the home screen
      home: const HomeScreen(),
    );
  }
}
