import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyMarsUsername = 'mars_username';
  static const String _keyMarsPassword = 'mars_password';
  static const String _keyLocale = 'app_locale';

  static Future<void> saveLoginStatus() async {
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
  }

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
  }

  // MARS credentials
  static Future<void> saveMarsCredentials(String username, String password) async {
    await _storage.write(key: _keyMarsUsername, value: username);
    await _storage.write(key: _keyMarsPassword, value: password);
  }

  static Future<String?> getMarsUsername() async {
    return await _storage.read(key: _keyMarsUsername);
  }

  static Future<String?> getMarsPassword() async {
    return await _storage.read(key: _keyMarsPassword);
  }

  static Future<void> clearMarsCredentials() async {
    await _storage.delete(key: _keyMarsUsername);
    await _storage.delete(key: _keyMarsPassword);
  }

  // Locale
  static Future<void> saveLocale(String locale) async {
    await _storage.write(key: _keyLocale, value: locale);
  }

  static Future<String?> getLocale() async {
    return await _storage.read(key: _keyLocale);
  }

  static Future<bool> isLoggedIn() async {
    String? value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
