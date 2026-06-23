import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/main.dart';
import 'package:speak_right/core/di/injection_container.dart' as di;

void main() {
  testWidgets('Smoke test - Verify SpeakRight launches', (WidgetTester tester) async {
    // Initialize dependencies for the test
    await di.initDependencies();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SpeakRightApp(),
      ),
    );

    // Verify that the title 'SpeakRight' is displayed
    expect(find.text('SpeakRight'), findsOneWidget);
  });
}
