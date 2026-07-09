import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:brethap/main.dart' as app;
import '../test/home_widget_test.dart' as original_home;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test: New Features', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    // 1. Test Color Picker in Drawer
    await original_home.openDrawer(tester);
    await tester.pumpAndSettle();

    // Specific finder for the color circles in the Wrap
    Finder colorCircles = find.byWidgetPredicate((widget) => 
      widget is GestureDetector && 
      widget.child is Container && 
      (widget.child as Container).decoration is BoxDecoration &&
      ((widget.child as Container).decoration as BoxDecoration).shape == BoxShape.circle
    );
    
    expect(colorCircles, findsWidgets);
    // Tap a different color. 
    // Note: This causes a full app rebuild because of the ValueKey on MaterialApp in main.dart
    await tester.tap(colorCircles.at(2), warnIfMissed: false);
    await tester.pumpAndSettle();
    
    // Because the app rebuilt completely, we must open the drawer again to see the items inside
    await original_home.openDrawer(tester);
    await tester.pumpAndSettle();

    // 2. Test Custom Tones Section exists
    Finder customTones = find.textContaining("Custom Tones");
    await tester.dragUntilVisible(
      customTones,
      find.byType(NavigationDrawer),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(customTones, findsOneWidget);
    
    // Close drawer
    await original_home.closeDrawer(tester);
    await tester.pumpAndSettle();

    // 3. Test Preferences UI with Dropdowns
    await original_home.openDrawer(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text(HomeWidget.keyPreferences));
    await tester.pumpAndSettle();

    // Find a dropdown (Audio dropdowns are in a ListView)
    Finder dropdown = find.byType(DropdownButton<String>).first;
    await tester.dragUntilVisible(
      dropdown,
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    
    // Select an item (Tone 1)
    await tester.tap(find.textContaining("Tone 1").last);
    await tester.pumpAndSettle();

    // Go back
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  });
}
