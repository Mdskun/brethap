import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brethap/hive_storage.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';

Future<void> main() async {
  // Do not debugPrint in release
  bool isInRelease = true;
  assert(() {
    isInRelease = false;
    return true;
  }());
  if (isInRelease) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialize Hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PreferenceAdapter());
  Hive.registerAdapter(SessionAdapter());

  // Initialize package info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.appName;
  String version = "${packageInfo.version}+${packageInfo.buildNumber}";
  String major = packageInfo.version.split(".")[0];
  String minor = packageInfo.version.split(".")[1];

  // Initialize Hive boxes
  Box preferences;
  String preferencesBox = "preferences.$major.$minor";
  try {
    preferences = await Hive.openBox(preferencesBox);
  } catch (e) {
    // Corrupted or incompatible box
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk(preferencesBox);
    // Try again
    preferences = await Hive.openBox(preferencesBox);
  }

  Box sessions;
  const String SESSIONS_BOX = "sessions";
  try {
    sessions = await Hive.openBox(SESSIONS_BOX);
  } catch (e) {
    // Corrupted or incompatible box
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk(SESSIONS_BOX);
    // Try again
    sessions = await Hive.openBox(SESSIONS_BOX);
  }

  Box customSounds;
  try {
    customSounds = await Hive.openBox("custom_sounds");
  } catch (e) {
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk("custom_sounds");
    customSounds = await Hive.openBox("custom_sounds");
  }

  runApp(
    MainWidget(
      appName: appName,
      version: version,
      preferences: preferences,
      sessions: sessions,
      customSounds: customSounds,
    ),
  );
}

class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
    required this.appName,
    required this.version,
    required this.preferences,
    required this.sessions,
    required this.customSounds,
  });

  final String appName, version;
  final Box preferences, sessions, customSounds;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: preferences.listenable(),
      builder: (context, Box box, _) {
        MaterialColor primaryColor = COLORS_PRIMARY[0] as MaterialColor;
        if (box.isNotEmpty) {
          Preference preference = box.getAt(0);
          primaryColor = COLORS_PRIMARY[preference.colors[0]] as MaterialColor;
        }

        return MaterialApp(
          key: ValueKey(primaryColor.value),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeWidget(
            appName: appName,
            version: version,
            preferences: preferences,
            sessions: sessions,
            customSounds: customSounds,
          ),
        );
      },
    );
  }
}
