import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'profile_screen.dart';
import '../services/secure_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, String>> menuItems = [
    {
      'title': 'MyDEX',
      'image': 'assets/images/Pi7_Tool_icon.png',
      'url': 'https://apps2.mylunas.com.my/mydex/dist/login.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'E-Leave',
      'image': 'assets/images/logoMock_eleave.png',
      'url': 'https://apps2.mylunas.com.my/eleave/',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'MyLunas SharePoint',
      'image': 'assets/images/logoMock_compass.png',
      'url': 'https://mylunas.sharepoint.com/',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'MARS Approval',
      'image': 'assets/images/logoMock_mars.png',
      'url': 'https://apps2.mylunas.com.my/mars/login.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'E-Registration',
      'image': 'assets/images/logoereg.png',
      'url': 'https://apps2.mylunas.com.my/eregistration/index.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'I-MARS',
      'image': 'assets/images/I-MARS.png',
      'url': 'https://imars.mylunas.com.my/pls/apex/f?p=107:LOGIN:1298764252950401:::::',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'WN Pass',
      'image': 'assets/images/logoMock_wn-.png',
      'url': 'https://apps2.mylunas.com.my/mylunas/WN%20Pass/wnButtonPage.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'Room Reservation',
      'image': 'assets/images/logoMock_Room.png',
      'url': 'https://apps2.mylunas.com.my/mylunas/Room%20Reservation/login.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'ESS',
      'image': 'assets/images/logoMock_ESS_5_.png',
      'url': 'https://mylunas.vdata.asia/ESS/UserLogin.aspx',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'TOMMS EAM Solution',
      'image': 'assets/images/logoMock_tomms1.png',
      'url': 'https://tomms.net.my/lunas_prod/multi_browser_index.htm',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'TOMMS Web Request',
      'image': 'assets/images/logoMock_tomms2.png',
      'url': 'https://tomms.net.my/LUNAS_Portal_prod/multi_browser_index.htm',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'DASS-21 Test',
      'image': 'assets/images/logoMock_dass.png',
      'url': 'https://apps2.mylunas.com.my/mylunas/dass/dass21.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'HSE U-See U-Act',
      'image': 'assets/images/logoMock_safety.png',
      'url': 'https://apps2.mylunas.com.my/mylunas/forms/ucua/index.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'E-Suggestion Box',
      'image': 'assets/images/logoMock_suggest.png',
      'url': 'https://forms.office.com/r/4QPVanVerA',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'Risk Management',
      'image': 'assets/images/lockmock_risk.png',
      'url': '',
      'disabled': 'true',
      'autoLogin': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  // Logo
                  Expanded(
                    child: Image.asset(
                      'assets/images/Pi7_Tool_splash.png',
                      height: 45,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  // Profile button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B6E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuCard(context, menuItems[index]);
                },
              ),
            ),

            // Footer
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: const Text(
                'Copyright © MyLUNAS 2026. Developed by LUNAS-ISD.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, String> item) {
    bool isDisabled = item['disabled'] == 'true';

    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sistem ini belum tersedia buat masa ini.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          : () {
              bool autoLogin = item['autoLogin'] == 'true';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                    title: item['title']!,
                    url: item['url']!,
                    autoLogin: autoLogin,
                  ),
                ),
              );
            },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  item['image']!,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey : const Color(0xFF0D3B6E),
                      ),
                    ),
                    if (isDisabled)
                      const Text(
                        'Akan datang',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              isDisabled
                  ? const Icon(Icons.lock, color: Colors.orange, size: 16)
                  : const Icon(Icons.arrow_forward_ios, color: Color(0xFF1565C0), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// WebView Screen
class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool autoLogin;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    this.autoLogin = false,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
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
            if (widget.autoLogin) {
              await _tryAutoLogin(url);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _tryAutoLogin(String currentUrl) async {
    final email = await SecureStorage.getUsername();
    final password = await SecureStorage.getPassword();
    if (email == null || password == null) return;

    // Auto-inject credentials ke mana-mana login form
    await _controller.runJavaScript('''
      (function() {
        var emailField = document.querySelector('input[name="email"]') ||
                         document.querySelector('input[type="email"]') ||
                         document.querySelector('input[name="username"]') ||
                         document.querySelector('input[name="user"]') ||
                         document.querySelector('input[name="login"]');
        var passField = document.querySelector('input[name="password"]') ||
                        document.querySelector('input[type="password"]');
        var submitBtn = document.querySelector('input[name="SubmitButton"]') ||
                        document.querySelector('button[type="submit"]') ||
                        document.querySelector('input[type="submit"]') ||
                        document.querySelector('button[id*="login"]') ||
                        document.querySelector('button[class*="login"]');
        if (emailField && passField && !emailField.value) {
          emailField.value = "$email";
          passField.value = "$password";
          if (submitBtn) submitBtn.click();
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF0D3B6E),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
