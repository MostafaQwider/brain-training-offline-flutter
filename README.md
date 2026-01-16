# 🧠 Mind Forge – Memory Training App (Flutter)

**Mind Forge** is a production-quality **offline Flutter app** designed to train and improve memory through engaging brain games.  
It features three distinct game modes, adaptive difficulty, and clean architecture — all running fully offline using in-memory state only.

---

## ✨ Key Features

- ✅ 100% Offline (No Internet, No Database)
- ✅ Clean Architecture (Models, Services, Screens, Widgets)
- ✅ 3 Memory Game Modes
- ✅ Adaptive Difficulty System
- ✅ Multi-Factor Scoring
- ✅ Smooth Animations & Material 3 UI
- ✅ Production-Ready, Well-Documented Code

---

## 🎮 Game Modes

### 🔵 Sequence Memory
Remember and repeat color sequences in the correct order.  
Difficulty increases from 4 to 10 colors.

### 🟢 Spatial Memory
Memorize highlighted tiles in scalable grids (3×3 up to 6×6).  
Uses efficient set-based validation for fast performance.

### 🟣 Word Memory
Memorize words shown for a limited time and identify them among smart distractors.  
Includes a 500+ word pool and color-coded results.

---

## 📸 Screenshots


🏗️ Project Structure
```
lib/
├── models/        # Game state & difficulty models
├── services/      # Game logic & score calculation
├── screens/       # UI screens for each game
├── widgets/       # Reusable UI components
└── main.dart      # App entry point
```
⚙️ Technical Highlights

State Management: StatefulWidget + in-memory state

Scoring Formula:
```
score = basePoints × difficulty × accuracy × timeBonus
```
Adaptive Difficulty:

Level up: 3 successes + ≥80% accuracy

Level down: 2 failures + <50% accuracy

Performance: Lightweight, fast, and smooth animations

🚀 Getting Started
```
git clone https://github.com/MostafaQwider/brain-training-offline-flutter.git
cd brain-training-offline-flutter
flutter pub get
flutter run
```
Supports Android, iOS, Windows, macOS, Linux, and Web.

🎯 Use Cases

Brain & memory training

Educational demos

Offline cognitive games

Flutter portfolio project

Clean Architecture reference

🛠️ Built With

Flutter & Dart

Material 3

Clean Architecture

Algorithmic Game Logic

Offline In-Memory State

📄 License

Available for educational and portfolio use.

👤 Author

Built with ❤️ using Flutter.

⭐ If you like this project, feel free to star the repository!


