import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'l10n/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved locale before app starts
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyLUNAS Mobile',
      home: SplashScreen(),
    );
  }

  @override
  void dispose() {
    _localeController.removeListener(() => setState(() {}));
    super.dispose();
  }
}
