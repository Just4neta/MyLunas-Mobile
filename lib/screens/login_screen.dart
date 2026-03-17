import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home_screen.dart';
import '../services/secure_storage.dart';

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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simpan credentials dulu
      await SecureStorage.saveCredentials(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Buka WebView untuk authenticate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _AuthWebView(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
      }

      setState(() => _isLoading = false);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 180,
                        height: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/Pi7_Tool_splash.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'MyLUNAS Mobile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3B6E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Log masuk untuk akses semua sistem',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sila masukkan email';
                          }
                          if (!value.contains('@')) {
                            return 'Format email tidak sah';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Laluan',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sila masukkan kata laluan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Remember me
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Colors.blue,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? true),
                          ),
                          const Text('Ingat Saya'),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sila hubungi admin IT'),
                                ),
                              );
                            },
                            child: const Text('Lupa Password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D3B6E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'LOG MASUK',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                      ),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// WebView untuk authenticate dengan E-Leave
class _AuthWebView extends StatefulWidget {
  final String email;
  final String password;

  const _AuthWebView({required this.email, required this.password});

  @override
  State<_AuthWebView> createState() => _AuthWebViewState();
}

class _AuthWebViewState extends State<_AuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (url) async {
            setState(() => _isLoading = false);

            // Auto inject credentials
            if (!url.contains('user/staff') &&
                !url.contains('dashboard')) {
              await _controller.runJavaScript('''
                (function() {
                  var emailField = document.querySelector('input[name="email"]');
                  var passField = document.querySelector('input[name="password"]');
                  var submitBtn = document.querySelector('button[type="submit"]') ||
                                  document.querySelector('input[type="submit"]');
                  if (emailField && passField) {
                    emailField.value = "${widget.email}";
                    passField.value = "${widget.password}";
                    if (submitBtn) submitBtn.click();
                  }
                })();
              ''');
            }

            // Login berjaya
            if (url.contains('user/staff')) {
              await SecureStorage.saveLoginStatus();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()),
                );
              }
            }
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://apps2.mylunas.com.my/eleave/index.php'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B6E),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Mengesahkan akaun...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
