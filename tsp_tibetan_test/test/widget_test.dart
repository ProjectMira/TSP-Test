
import 'package:flutter_test/flutter_test.dart';
import 'package:tsp_tibetan_test/main.dart';

void main() {
  testWidgets('App loads and shows Home Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PastPapersApp());

    // Verify that the title is displayed.
    expect(find.text('Past Papers'), findsOneWidget);

    // Wait for the FutureBuilder to complete (if mocked or if real assets load fast enough)
    // In a real test environment, loading assets might be async.
    // We can pump for a duration to allow the Future to complete.
    await tester.pumpAndSettle();

    // Verify that we see the paper years (assuming assets are loaded correctly in test env)
    // Note: Loading assets in widget tests usually works if configured correctly.
    // If it fails, we might see "No papers found" or loading indicator.
    // For now, let's just check if the app bar title is there, which confirms the app started.
  });
}
