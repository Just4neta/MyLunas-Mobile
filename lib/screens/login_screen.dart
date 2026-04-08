import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quote_screen.dart';
import '../services/secure_storage.dart';
import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  final LocaleController _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _localeController.addListener(() => setState(() {}));
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        bool success = await _verifyCredentials(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (success) {
          await SecureStorage.saveCredentials(
            _emailController.text.trim(),
            _passwordController.text,
          );
          await SecureStorage.saveLoginStatus();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const QuoteScreen(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppStrings.get('login_error')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.get('login_network_error')),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _verifyCredentials(String email, String password) async {
    try {
      final client = http.Client();
      final request = http.Request(
        'POST',
        Uri.parse('https://apps2.mylunas.com.my/eleave/controller/LoginController.php'),
      );
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.bodyFields = {'email': email, 'password': password};
      request.followRedirects = false;
      final response = await client.send(request).timeout(const Duration(seconds: 10));
      final location = response.headers['location'] ?? '';
      return response.statusCode == 302 &&
             location.isNotEmpty &&
             !location.contains('index.php') &&
             !location.contains('login');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 180, height: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset('assets/images/Pi7_Tool_splash.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 16),
                      Text(AppStrings.get('login_title'),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D3B6E))),
                      const SizedBox(height: 6),
                      Text(AppStrings.get('login_subtitle'),
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('login_email'),
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true, fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.get('login_email_empty');
                          if (!value.contains('@')) return AppStrings.get('login_email_invalid');
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('login_password'),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true, fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.get('login_password_empty');
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Colors.blue,
                            onChanged: (value) => setState(() => _rememberMe = value ?? true),
                          ),
                          Text(AppStrings.get('login_remember')),
                          const Spacer(),
                          TextButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.get('login_contact_admin'))),
                            ),
                            child: Text(AppStrings.get('login_forgot')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D3B6E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20, height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                    SizedBox(width: 12),
                                    Text('...', style: TextStyle(fontSize: 14)),
                                  ],
                                )
                              : Text(AppStrings.get('login_button'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(AppStrings.get('version'),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localeController.removeListener(() => setState(() {}));
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
