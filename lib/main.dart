import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'l10n/locale_controller.dart';
import 'l10n/app_strings.dart';
import 'services/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS: Clear Keychain on fresh install
  // Android: Clear WebView cookies on fresh install
  if (Platform.isIOS) {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched') ?? false;
    if (!hasLaunched) {
      await SecureStorage.clearAll();
      await prefs.setBool('has_launched', true);
    }
  } else if (Platform.isAndroid) {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched') ?? false;
    if (!hasLaunched) {
      // On fresh install — clear only secure storage (credentials)
      // Do NOT clear WebView cookies — E-Leave needs session cookie to work
      await SecureStorage.clearAll();
      await prefs.setBool('has_launched', true);
    }
  }

  await LocaleController().loadSavedLocale();
  runApp(const MyLunasApp());
}

class MyLunasApp extends StatefulWidget {
  const MyLunasApp({super.key});

  @override
  State<MyLunasApp> createState() => _MyLunasAppState();
}

class _MyLunasAppState extends State<MyLunasApp> {
  final LocaleController _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _localeController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyLUNAS Mobile',
      home: const SplashScreen(),
    );
  }

  @override
  void dispose() {
    _localeController.removeListener(() => setState(() {}));
    super.dispose();
  }
}
