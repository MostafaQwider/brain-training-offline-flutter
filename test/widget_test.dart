// Basic widget test for the Memory Training app

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_forge/main.dart';

void main() {
  testWidgets('Memory Training app launches with home screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MemoryTrainingApp());

    // Verify that our home screen displays
    expect(find.text('Memory Training'), findsOneWidget);
    expect(find.text('Train Your Brain'), findsOneWidget);

    // Verify all three game cards are present
    expect(find.text('Sequence Memory'), findsOneWidget);
    expect(find.text('Spatial Memory'), findsOneWidget);
    expect(find.text('Word Memory'), findsOneWidget);
  });
}
