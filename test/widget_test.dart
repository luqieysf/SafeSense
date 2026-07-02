import 'package:flutter_test/flutter_test.dart';
import 'package:safesense/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Changed MyApp() to SafeSenseApp() to match your main.dart
    await tester.pumpWidget(const SafeSenseApp());

    // Verify that the app widget is present.
    expect(find.byType(SafeSenseApp), findsOneWidget);
  });
}
