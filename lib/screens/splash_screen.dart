import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'quote_screen.dart';
import '../services/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkForUpdate();
      _checkLoginStatus();
    });
  }

  // Current app version — update this on every release
  static const String _currentVersion = '1.0.9';

  Future<void> _checkForUpdate() async {
    try {
      // Check Play Store public page for latest version
      final response = await http.get(
        Uri.parse('https://play.google.com/store/apps/details?id=com.mylunas.mobile&hl=en'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // Extract version from Play Store page
        final match = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"').firstMatch(response.body);
        final latestVersion = match?.group(1) ?? '';

        if (latestVersion.isNotEmpty && latestVersion != _currentVersion && mounted) {
          await _showUpdateDialog(latestVersion);
        }
      }
    } catch (_) {
      // Silent fail — no internet or rate limited
    }
  }

  Future<void> _showUpdateDialog(String newVersion) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
            child: const Icon(Icons.system_update, color: Color(0xFF0D3B6E), size: 30),
          ),
          const SizedBox(height: 12),
          const Text('Kemaskini Tersedia',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0D3B6E)),
          ),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.new_releases, color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Versi baru: v$newVersion\nVersi semasa: v$_currentVersion',
                style: const TextStyle(fontSize: 12, color: Color(0xFF0D3B6E), fontWeight: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 10),
          Text('Versi baru aplikasi MyLUNAS Mobile tersedia. Sila kemaskini untuk mendapat ciri dan pembaikan terbaru.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF444444)), textAlign: TextAlign.center),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kemudian', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Kemaskini Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B6E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await SecureStorage.isLoggedIn();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              isLoggedIn ? const QuoteScreen() : const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B6E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D3B6E),
              Color(0xFF1565C0),
              Color(0xFF0D3B6E),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/images/Pi7_Tool_splash.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'MyLUNAS Mobile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Lumut Naval Shipyard',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.7),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Versi 1.0.1',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
