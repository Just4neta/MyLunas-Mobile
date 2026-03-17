import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static Future<void> saveLoginStatus() async {
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
  }

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyIsLoggedIn, value: 'true');
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
