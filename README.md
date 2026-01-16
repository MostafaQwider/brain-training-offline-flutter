# Mind Forge - Memory Training App

A complete **offline Flutter application** for brain training through memory exercises. Features three distinct game modes designed to improve sequential, spatial, and verbal memory skills.

## 🎯 Overview

Mind Forge is a production-quality Flutter app built with clean architecture principles. It runs entirely offline with no external dependencies, using only in-memory data structures. The app provides an engaging way to train your brain through progressively challenging memory exercises.

**Key Highlights**:
- ✅ **100% Offline** - No internet, database, or external storage required
- ✅ **Clean Architecture** - Separation of models, services, screens, and widgets
- ✅ **Three Game Modes** - Sequence, Spatial, and Word memory exercises
- ✅ **Adaptive Difficulty** - Automatic progression based on performance
- ✅ **Comprehensive Scoring** - Multi-factor score calculation
- ✅ **Production Quality** - Well-commented, maintainable code

---

## 🎮 Game Modes

### 1. Sequence Memory (Blue)
Test your ability to remember **color patterns in order**.

**How to Play**:
1. Watch a sequence of colors appear one by one
2. Remember the order
3. Tap the colors in the same sequence

**Difficulty Progression**:
- Beginner: 4 colors
- Intermediate: 6 colors
- Advanced: 8 colors
- Expert: 10 colors

**Algorithm**: Random sequence generation with variety constraints to prevent more than 2 consecutive identical colors.

---

### 2. Spatial Memory (Green)
Train your **visual-spatial memory** by remembering tile positions.

**How to Play**:
1. Watch tiles light up in a grid
2. Remember which tiles were highlighted
3. Tap the tiles that lit up
4. Submit your answer

**Difficulty Progression**:
- Beginner: 3×3 grid (9 tiles, 3 to remember)
- Intermediate: 4×4 grid (16 tiles, 5-6 to remember)
- Advanced: 5×5 grid (25 tiles, 9 to remember)
- Expert: 6×6 grid (36 tiles, 13-14 to remember)

**Algorithm**: Random pattern generation with set-based validation for O(1) lookup performance.

---

### 3. Word Memory (Purple)
Improve **verbal memory** by recalling words from a timed display.

**How to Play**:
1. Memorize words shown on screen (timed display)
2. Select the words you saw from a larger list
3. Avoid selecting distractor words you didn't see

**Difficulty Progression**:
- Beginner: 5 words, 15s display, 1:1 distractor ratio
- Intermediate: 8 words, 16s display, 1:1.5 ratio
- Advanced: 12 words, 24s display, 1:2 ratio
- Expert: 15 words, 15s display, 1:2 ratio (harder distractors)

**Features**:
- 500+ word pool of common English words
- Smart distractor generation (similar-length words for higher difficulties)
- Color-coded results (green=correct, orange=missed, red=wrong)

---

## 🏗️ Architecture

The app follows **clean architecture** with clear separation of concerns:

```
lib/
├── main.dart                           # App entry point
├── models/                             # Data models
│   ├── difficulty_level.dart          # Difficulty enum & config
│   ├── game_result.dart                # Result tracking
│   └── game_state.dart                 # Session state management
├── services/                           # Business logic
│   ├── score_service.dart              # Score calculation
│   ├── sequence_game_service.dart      # Sequence game logic
│   ├── spatial_game_service.dart       # Spatial game logic
│   └── word_game_service.dart          # Word game logic
├── screens/                            # UI screens
│   ├── home_screen.dart                # Main menu
│   ├── sequence_game_screen.dart       # Sequence memory game
│   ├── spatial_game_screen.dart        # Spatial memory game
│   └── word_game_screen.dart           # Word memory game
└── widgets/                            # Reusable components
    ├── game_card.dart                  # Game mode cards
    └── score_display.dart              # Score & difficulty display
```

### Architecture Benefits

- **Testability**: Services can be unit tested independently
- **Maintainability**: Clear file organization and responsibilities
- **Scalability**: Easy to add new game modes or features
- **Reusability**: Shared services and widgets across screens

---

## 📱 Screens

### Home Screen
Main menu displaying three game mode cards with descriptions and navigation.

**Features**:
- Game mode selection cards with icons
- Instructions panel
- Clean, modern UI with gradient effects

### Sequence Game Screen
Four-phase gameplay: Ready → Showing → Input → Result

**Phases**:
1. **Ready**: Instructions and start button
2. **Showing**: Animated color sequence display (800ms per color)
3. **Input**: Grid of color buttons for user selection
4. **Result**: Score, grade, statistics, and replay options

### Spatial Game Screen
Grid-based tile memory with visual feedback.

**Features**:
- Scalable grid (3×3 to 6×6)
- Tile animation (600ms per tile)
- Toggle selection (tap to select/deselect)
- Color-coded results showing correct/missed/wrong tiles

### Word Game Screen
Timed word memorization with distractor handling.

**Features**:
- Countdown timer during memorization
- Scrollable word list display
- Grid-based word selection (2 columns)
- Word breakdown with icons (✓ ⚠ ✗)

---

## ⚙️ Technical Features

### State Management
Uses **StatefulWidget** with in-memory state:
- No database persistence (SQLite, Hive, Firebase)
- Game state stored in widget state
- Session statistics in memory variables
- State resets on app restart

### Score Calculation

```dart
score = basePoints × difficultyMultiplier × accuracy × timeBonus

Where:
- basePoints = 100
- difficultyMultiplier = 1.0 to 2.5 (based on level)
- accuracy = correctAnswers / totalQuestions
- timeBonus = 0.5 to 2.0 (based on speed)
```

### Difficulty Progression

**Level Up**:
- Need 3 consecutive successes
- Accuracy ≥ 80%
- Not already at maximum difficulty

**Level Down**:
- 2 consecutive failures
- Accuracy < 50%
- Not already at minimum difficulty

### Performance

- **Lightweight**: Minimal memory footprint
- **Fast**: All operations complete in milliseconds
- **Efficient**: Set-based operations for O(1) lookups
- **Smooth**: AnimatedContainer transitions and visual feedback

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mind_forge
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For desktop (Windows/macOS/Linux)
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux

   # For mobile
   flutter run -d android
   flutter run -d ios

   # For web
   flutter run -d chrome
   ```

### Testing

Run the widget tests:
```bash
flutter test
```

---

## 🎨 UI/UX Features

- **Material 3 Design**: Modern, clean interface
- **Color-Coded Themes**: Each game has a distinct color (Blue/Green/Purple)
- **Smooth Animations**: AnimatedContainer transitions
- **Visual Feedback**: Immediate response to user actions
- **Responsive Layouts**: Works on various screen sizes
- **Gradient Effects**: Modern card designs
- **Intuitive Navigation**: Clear flow between screens

---

## 📊 Game Statistics

Each game tracks:
- **Accuracy**: Percentage of correct answers
- **Time Taken**: Response time in seconds
- **Grade**: Letter grade (S, A, B, C, D, F)
- **Total Score**: Cumulative points
- **Difficulty Level**: Current challenge level
- **Consecutive Performance**: Success/failure streaks

---

## 🔧 Code Quality

- ✅ **Well-Commented**: Every function includes purpose and algorithm description
- ✅ **Type Safe**: Full null safety and type annotations
- ✅ **Lint-Free**: Passes all Dart analyzer checks
- ✅ **Clean Code**: Consistent naming conventions
- ✅ **DRY Principles**: Reusable services and widgets
- ✅ **Error Handling**: Proper resource cleanup and edge case handling

---

## 📚 Documentation

Comprehensive algorithm documentation available:
- **Sequence Game**: Pattern generation and validation logic
- **Spatial Game**: Grid-based position tracking
- **Word Game**: Word pool management and distractor generation
- **Score Service**: Multi-factor scoring formula
- **Difficulty System**: Adaptive progression rules

---

## 🎯 Use Cases

- **Brain Training**: Regular practice to improve memory
- **Cognitive Assessment**: Track memory performance over time
- **Educational Tool**: Teaching memory techniques
- **Portfolio Project**: Demonstrating Flutter development skills
- **Offline Gaming**: Play without internet connection

---

## 🤝 Contributing

This is a complete, production-ready application. Potential enhancements:

- Sound effects and haptic feedback
- Persistent high scores (optional database)
- Additional game modes (number memory, pattern matching)
- Multiplayer challenges
- Progress tracking and analytics
- Achievements and badges

---

## 📄 License

This project is available for educational and portfolio purposes.

---

## 👤 Author

Built with ❤️ using Flutter and clean architecture principles.

**Technologies**: Flutter • Dart • Material 3 • StatefulWidget

**Architecture**: Clean Architecture • Service Layer • State Management

**Game Algorithms**: Random Generation • Set-Based Validation • Multi-Factor Scoring

---

## ⭐ Features Summary

| Feature | Status |
|---------|--------|
| Sequence Memory Game | ✅ Complete |
| Spatial Memory Game | ✅ Complete |
| Word Memory Game | ✅ Complete |
| Adaptive Difficulty | ✅ Complete |
| Score Calculation | ✅ Complete |
| Clean Architecture | ✅ Complete |
| Offline Functionality | ✅ Complete |
| Production Quality | ✅ Complete |

**Total Lines of Code**: ~2,000+ lines of production-quality Dart code

---

**Ready to challenge your memory?** Run `flutter run` and start training! 🧠💪
#   b r a i n - t r a i n i n g - o f f l i n e - f l u t t e r  
 