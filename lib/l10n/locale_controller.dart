// lib/l10n/locale_controller.dart
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/secure_storage.dart';

class LocaleController extends ChangeNotifier {
  static final LocaleController _instance = LocaleController._internal();
  factory LocaleController() => _instance;
  LocaleController._internal();

  String _currentLocale = 'ms';
  String get currentLocale => _currentLocale;
  bool get isEnglish => _currentLocale == 'en';

  Future<void> loadSavedLocale() async {
    String? saved = await SecureStorage.getLocale();
    if (saved != null) {
      _currentLocale = saved;
      AppStrings.locale = saved;
    }
  }

  Future<void> setLocale(String locale) async {
    _currentLocale = locale;
    AppStrings.locale = locale;
    await SecureStorage.saveLocale(locale);
    notifyListeners();
  }
}
