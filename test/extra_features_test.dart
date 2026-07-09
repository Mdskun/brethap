import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';
import 'test_utils.dart';
import 'home_widget_test.dart' as original_home;

void main() {
  late HiveData hiveData;
  setUpAll((() async {
    hiveData = await setupHive();
  }));

  testWidgets('New Features: Navigation Drawer and Custom Tones', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeWidget(
          appName: APP_NAME,
          version: "1.0.0",
          preferences: hiveData.preferences,
          sessions: hiveData.sessions,
          customSounds: hiveData.customSounds,
        ),
      ),
    );

    // Open drawer
    await original_home.openDrawer(tester);
    await tester.pumpAndSettle();

    // Verify Custom Tones section exists in NavigationDrawer
    Finder customTonesFinder = find.textContaining("Custom Tones");
    // Ensure we can see it
    await tester.dragUntilVisible(
      customTonesFinder,
      find.byType(NavigationDrawer),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    
    expect(customTonesFinder, findsWidgets);
    expect(find.textContaining("Add Custom Sound"), findsOneWidget);

    // Verify Appearance section and color picker
    expect(find.textContaining("Appearance"), findsWidgets);
    expect(find.byType(GestureDetector), findsWidgets); // Color circles

    // Close drawer
    await original_home.closeDrawer(tester);
    await tester.pumpAndSettle();
  });

  testWidgets('New Features: Preferences UI Updates', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PreferencesWidget(
          preferences: hiveData.preferences,
          customSounds: hiveData.customSounds,
          callback: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify new UI elements: SwitchListTile
    expect(find.byType(SwitchListTile), findsWidgets);

    // Verify DropdownButton for audio
    // We scroll to find one of the audio dropdowns by key
    Finder audioDropdown = find.byKey(const Key(INHALE_AUDIO_TEXT));
    await tester.dragUntilVisible(
      audioDropdown,
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(audioDropdown, findsOneWidget);

    // Scroll down further to see GridView (Saved Preferences)
    await tester.dragUntilVisible(
      find.byType(GridView),
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    // Verify GridView for saved preferences
    expect(find.byType(GridView), findsOneWidget);
    // Verify at least one slot is there (Slot 1)
    expect(find.textContaining("1"), findsWidgets);
  });
}
