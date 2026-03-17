import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class AuthService {
  static Future<String?> getUserName() async {
    return await SecureStorage.getUsername();
  }

  static Future<Map<String, String>?> getUserProfile() async {
    String? username = await SecureStorage.getUsername();
    return {
      'name': username ?? 'Pengguna MyLUNAS',
      'email': username ?? '',
      'department': 'Jabatan Teknologi Maklumat',
      'employeeId': 'STD-12345',
      'phone': '03-1234 5678',
    };
  }

  static Future<bool> loginToSystem(String system, String email, String password) async {
    try {
      var client = http.Client();
      var request = http.Request(
        'POST',
        Uri.parse('https://apps2.mylunas.com.my/eleave/controller/LoginController.php'),
      );

      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.bodyFields = {
        'email': email,
        'password': password,
      };

      request.followRedirects = false;
      var response = await client.send(request);
      String location = response.headers['location'] ?? '';

      // Login berjaya = redirect ke user/staff
      // Login gagal = redirect balik ke index.php
      if (response.statusCode == 302 && location.contains('user/staff')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
