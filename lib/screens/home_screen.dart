import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'profile_screen.dart';
import '../services/secure_storage.dart';
import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final LocaleController _localeController = LocaleController();

  // ERT Duty Ticker
  String _dutyText = 'Memuatkan maklumat bertugas...';
  String _dutyTeam = '';
  String _dutyDate = '';
  List<Map<String, String>> _dutyMembers = [];
  bool _showDutyOverlay = false;
  late AnimationController _tickerController;
  late Animation<double> _tickerAnimation;

  @override
  void initState() {
    super.initState();
    _localeController.addListener(() => setState(() {}));

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    _tickerAnimation = Tween<double>(begin: 1.0, end: -1.0)
        .animate(CurvedAnimation(parent: _tickerController, curve: Curves.linear));

    _fetchDutyInfo();
  }

  Future<void> _fetchDutyInfo() async {
    try {
      final response = await http.get(
        Uri.parse('https://apps2.mylunas.com.my/mylunas/hse_proxy.php'),
        headers: {'Accept': 'text/html'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final html = response.body;

        String teamCode = '';
        String date = '';
        List<Map<String, String>> members = [];

        final teamPattern = RegExp(r'team-code[^>]*>([A-Z])<', caseSensitive: false);
        final datePattern = RegExp(r'date-line[^>]*>([^<]+)<', caseSensitive: false);

        // Find current team (with "now")
        final teamMatches = teamPattern.allMatches(html);
        for (final match in teamMatches) {
          final surrounding = html.substring(
            (match.start - 200).clamp(0, html.length),
            (match.end + 200).clamp(0, html.length),
          );
          if (surrounding.toLowerCase().contains('now') ||
              surrounding.toLowerCase().contains('sekarang')) {
            teamCode = match.group(1) ?? '';
            break;
          }
        }

        // Fallback
        if (teamCode.isEmpty) {
          final statusPattern = RegExp(
            r'status-pill.*?team-code[^>]*>([A-Z])<',
            caseSensitive: false, dotAll: true,
          );
          final m = statusPattern.firstMatch(html);
          if (m != null) teamCode = m.group(1) ?? '';
        }

        // Get date
        final dateMatch = datePattern.firstMatch(html);
        if (dateMatch != null) date = dateMatch.group(1)?.trim() ?? '';

        // Extract staff members from table rows
        final rowPattern = RegExp(
          r'<tr[^>]*>(.*?)</tr>',
          caseSensitive: false, dotAll: true,
        );
        final cellPattern = RegExp(
          r'<td[^>]*>(.*?)</td>',
          caseSensitive: false, dotAll: true,
        );
        final tagPattern = RegExp(r'<[^>]+>');

        for (final rowMatch in rowPattern.allMatches(html)) {
          final cells = cellPattern.allMatches(rowMatch.group(1) ?? '').toList();
          if (cells.length >= 2) {
            final role = cells[0].group(1)?.replaceAll(tagPattern, '').trim() ?? '';
            final name = cells[1].group(1)?.replaceAll(tagPattern, '').trim() ?? '';
            if (role.isNotEmpty && name.isNotEmpty && role.length > 1) {
              members.add({'role': role, 'name': name,
                'dept': cells.length > 2 ? (cells[2].group(1)?.replaceAll(tagPattern, '').trim() ?? '') : ''});
            }
          }
        }

        setState(() {
          _dutyTeam = teamCode;
          _dutyDate = date;
          _dutyMembers = members;
          _dutyText = teamCode.isNotEmpty
              ? '⚓  PEGAWAI ERT BERTUGAS  •  Team $teamCode  ${date.isNotEmpty ? "• $date" : ""}'
              : '⚓  PEGAWAI ERT BERTUGAS  •  Maklumat tidak tersedia';
        });
      }
    } catch (e) {
      debugPrint('Duty fetch error: $e');
      setState(() {
        _dutyText = '⚓  PEGAWAI ERT BERTUGAS  •  Maklumat tidak tersedia';
      });
    }
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _localeController.removeListener(() => setState(() {}));
    super.dispose();
  }

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
      'title': 'MARS Mobile',
      'image': 'assets/images/mars_mobile.png',
      'url': 'https://apps2.mylunas.com.my/marsmobile/pages/home.php',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'People Movement',
      'image': 'assets/images/people.png',
      'url': 'https://apps2.mylunas.com.my/mylunas/dashboard/',
      'disabled': 'false',
      'autoLogin': 'true',
    },
    {
      'title': 'Visitor Scanner',
      'image': 'assets/images/visitor_scanner.png',
      'url': 'https://apps2.mylunas.com.my/lunasitor/history.php',
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppStrings.get('home_exit_title')),
                              content: Text(AppStrings.get('home_exit_content')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(AppStrings.get('home_cancel')),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (Platform.isAndroid) {
                                      SystemNavigator.pop();
                                    } else {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D3B6E),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(AppStrings.get('home_exit_confirm')),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D3B6E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.exit_to_app, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Image.asset(
                          'assets/images/Pi7_Tool_splash.png',
                          height: 45,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D3B6E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                // ERT Duty Ticker Bar — tap to open overlay
                GestureDetector(
                  onTap: () => setState(() => _showDutyOverlay = true),
                  child: Container(
                    height: 34,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D3B6E), Color(0xFF1565C0), Color(0xFF0D3B6E)],
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFFFD700), width: 2.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          color: const Color(0xFFFFD700),
                          child: const Text(
                            'ERT',
                            style: TextStyle(
                              color: Color(0xFF0D3B6E),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRect(
                            child: AnimatedBuilder(
                              animation: _tickerAnimation,
                              builder: (context, child) {
                                return FractionalTranslation(
                                  translation: Offset(_tickerAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: Text(
                                '   $_dutyText   •   $_dutyText   ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: const Row(
                            children: [
                              Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                              SizedBox(width: 2),
                              Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                  child: Text(
                    AppStrings.get('home_footer'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

          // ERT Duty Overlay
          if (_showDutyOverlay)
            GestureDetector(
              onTap: () => setState(() => _showDutyOverlay = false),
              child: Container(
                color: Colors.black54,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {}, // prevent dismiss when tapping panel
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Spacer to position below header + ticker
                        const SizedBox(height: 99 + 34),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Panel header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF0D3B6E), Color(0xFF1565C0)],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFFFFD700), width: 2.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shield, color: Color(0xFFFFD700), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'PEGAWAI ERT BERTUGAS',
                                            style: TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          if (_dutyTeam.isNotEmpty)
                                            Text(
                                              'Team $_dutyTeam  ${_dutyDate.isNotEmpty ? "• $_dutyDate" : ""}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Close button
                                    GestureDetector(
                                      onTap: () => setState(() => _showDutyOverlay = false),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Staff list
                              _dutyMembers.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 36),
                                          const SizedBox(height: 10),
                                          Text(
                                            _dutyTeam.isNotEmpty
                                                ? 'Team $_dutyTeam sedang bertugas'
                                                : 'Maklumat ahli pasukan tidak tersedia',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        itemCount: _dutyMembers.length,
                                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                                        itemBuilder: (context, i) {
                                          final member = _dutyMembers[i];
                                          return ListTile(
                                            dense: true,
                                            leading: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF0D3B6E),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.person, color: Colors.white, size: 18),
                                            ),
                                            title: Text(
                                              member['name'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Color(0xFF0D3B6E),
                                              ),
                                            ),
                                            subtitle: Text(
                                              member['role'] ?? '',
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                            ),
                                            trailing: member['dept']?.isNotEmpty == true
                                                ? Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFE3F2FD),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      member['dept']!,
                                                      style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0)),
                                                    ),
                                                  )
                                                : null,
                                          );
                                        },
                                      ),
                                    ),

                              // Refresh button
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextButton.icon(
                                  onPressed: () {
                                    _fetchDutyInfo();
                                    setState(() => _showDutyOverlay = false);
                                  },
                                  icon: const Icon(Icons.refresh, size: 14),
                                  label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, String> item) {
    bool isDisabled = item['disabled'] == 'true';

    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppStrings.get('home_unavailable')),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ));
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
                width: 65, height: 65,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Image.asset(item['image']!, fit: BoxFit.contain),
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
                      Text(
                        AppStrings.get('home_coming_soon'),
                        style: const TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic),
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

// WebView Screen — uses flutter_inappwebview for full camera/permission support
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
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String _currentUrl = '';

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    javaScriptCanOpenWindowsAutomatically: true,
    allowsBackForwardNavigationGestures: true,
    supportZoom: true,
    builtInZoomControls: false,
    cacheEnabled: true,
    cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
    hardwareAcceleration: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    useOnDownloadStart: true,
    userAgent: 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  );

  Future<void> _tryAutoLogin(String currentUrl) async {
    final email = await SecureStorage.getUsername();
    final password = await SecureStorage.getPassword();

    debugPrint('=== AUTO-LOGIN ===');
    debugPrint('URL: $currentUrl');
    debugPrint('Email stored: ${email ?? "NULL"}');
    debugPrint('Password stored: ${password != null ? "YES (${password.length} chars)" : "NULL"}');

    final emailClean = email?.trim() ?? '';
    final passwordClean = password?.trim() ?? '';

    debugPrint('Email clean: "$emailClean"');

    if (emailClean.isEmpty || passwordClean.isEmpty) {
      debugPrint('AUTO-LOGIN SKIP: credentials empty after trim');
      return;
    }

    if (currentUrl.contains('apps2.mylunas.com.my/mars') ||
        currentUrl.contains('apps2.mylunas.com.my/marsmobile')) {
      final marsUser = await SecureStorage.getMarsUsername();
      final marsPass = await SecureStorage.getMarsPassword();
      if (marsUser == null || marsUser.isEmpty) return;
      await _webViewController?.evaluateJavascript(source: '''
        (function() {
          var userField = document.querySelector('input[name="username"]') ||
                          document.querySelector('input[name="user_id"]') ||
                          document.querySelector('input[type="text"]');
          var passField = document.querySelector('input[name="password"]') ||
                          document.querySelector('input[type="password"]');
          var submitBtn = document.querySelector('button[type="submit"]') ||
                          document.querySelector('input[type="submit"]');
          if (userField && passField && !userField.value) {
            userField.value = "$marsUser";
            passField.value = "$marsPass";
            if (submitBtn) submitBtn.click();
          }
        })();
      ''');
      return;
    }

    await _webViewController?.evaluateJavascript(source: '''
      (function() {
        var emailField = document.querySelector('input[name="email"]') ||
                         document.querySelector('input[type="email"]') ||
                         document.querySelector('input[name="username"]');
        var passField = document.querySelector('input[name="password"]') ||
                        document.querySelector('input[type="password"]');
        var submitBtn = document.querySelector('input[name="SubmitButton"]') ||
                        document.querySelector('button[type="submit"]') ||
                        document.querySelector('input[type="submit"]');

        console.log("AUTOLOGIN: emailField=" + (emailField ? emailField.name : "NOT FOUND"));
        console.log("AUTOLOGIN: passField=" + (passField ? "FOUND" : "NOT FOUND"));
        console.log("AUTOLOGIN: submitBtn=" + (submitBtn ? "FOUND" : "NOT FOUND"));
        console.log("AUTOLOGIN: emailField.value=" + (emailField ? emailField.value : "N/A"));

        function triggerEvent(el, eventName) {
          var event = new Event(eventName, { bubbles: true });
          el.dispatchEvent(event);
        }

        if (emailField && passField && !emailField.value) {
          emailField.value = "${emailClean.replaceAll('"', '\\"')}";
          passField.value = "${passwordClean.replaceAll('"', '\\"')}";

          triggerEvent(emailField, 'input');
          triggerEvent(emailField, 'change');
          triggerEvent(passField, 'input');
          triggerEvent(passField, 'change');

          console.log("AUTOLOGIN: values set, submitting...");
          setTimeout(function() {
            if (submitBtn) submitBtn.click();
          }, 500);
        } else {
          console.log("AUTOLOGIN: skipped - emailField.value already=" + (emailField ? emailField.value : "N/A"));
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if WebView can go back — navigate within WebView first
        if (_webViewController != null) {
          bool canGoBack = await _webViewController!.canGoBack();
          if (canGoBack) {
            await _webViewController!.goBack();
            return false; // Don't pop the screen
          }
        }
        return true; // Pop the screen if no more history
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: const Color(0xFF0D3B6E),
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: _settings,
              onWebViewCreated: (controller) {
                _webViewController = controller;

                // Handle blob download
                controller.addJavaScriptHandler(
                  handlerName: 'blobDownload',
                  callback: (args) async {
                    if (args.isEmpty) return;
                    try {
                      final base64Data = args[0] as String;
                      final fileName = args.length > 1 ? args[1] as String : 'download.xlsx';

                      final bytes = base64Decode(base64Data);

                      // Save to app documents directory
                      final dir = await getApplicationDocumentsDirectory();
                      final file = File('${dir.path}/$fileName');
                      await file.writeAsBytes(bytes);

                      // Open file using OpenFile — handles content:// URI properly
                      final result = await OpenFile.open(file.path);
                      debugPrint('OpenFile result: ${result.message}');

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloaded: $fileName'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Blob download error: $e');
                    }
                  },
                );

                // Add JS handler for print button
                controller.addJavaScriptHandler(
                  handlerName: 'printHandler',
                  callback: (args) async {
                    final url = _currentUrl.isNotEmpty ? _currentUrl : widget.url;
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                );
              },
              onDownloadStartRequest: (controller, downloadStartRequest) async {
                final url = downloadStartRequest.url.toString();
                if (url.startsWith('blob:')) {
                  final fileName = downloadStartRequest.suggestedFilename ?? 'download.xlsx';
                  await controller.evaluateJavascript(source: '''
                    (function() {
                      fetch("$url")
                        .then(r => r.blob())
                        .then(blob => {
                          var reader = new FileReader();
                          reader.onloadend = function() {
                            var base64 = reader.result.split(",")[1];
                            window.flutter_inappwebview.callHandler("blobDownload", base64, "$fileName");
                          };
                          reader.readAsDataURL(blob);
                        });
                    })();
                  ''');
                } else {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              onLoadStart: (controller, url) {
                if (url != null) _currentUrl = url.toString();
                setState(() => _isLoading = true);
              },
              onLoadStop: (controller, url) async {
                if (url != null) _currentUrl = url.toString();
                setState(() => _isLoading = false);
                if (widget.autoLogin && url != null) {
                  await _tryAutoLogin(url.toString());
                }

                // Detect blank/white page and redirect to dashboard
                final urlStr = url?.toString() ?? '';
                if (urlStr == 'about:blank' || urlStr.isEmpty) {
                  final baseUri = Uri.parse(widget.url);
                  final dashboardUrl = '${baseUri.scheme}://${baseUri.host}${baseUri.path.substring(0, baseUri.path.lastIndexOf('/') + 1)}index.php';
                  await controller.loadUrl(urlRequest: URLRequest(url: WebUri(dashboardUrl)));
                  return;
                }

                // Check if page body is empty (white screen)
                final bodyContent = await controller.evaluateJavascript(
                  source: 'document.body ? document.body.innerHTML.trim().length : -1'
                );
                if (bodyContent != null && bodyContent.toString() == '0') {
                  final baseUri = Uri.parse(widget.url);
                  final dashboardUrl = '${baseUri.scheme}://${baseUri.host}${baseUri.path.substring(0, baseUri.path.lastIndexOf('/') + 1)}index.php';
                  await controller.loadUrl(urlRequest: URLRequest(url: WebUri(dashboardUrl)));
                }

                // Inject print handler — intercept window.print() and open in browser
                await controller.evaluateJavascript(source: '''
                  (function() {
                    // Override window.print
                    window.print = function() {
                      window.flutter_inappwebview.callHandler("printHandler");
                    };

                    // Intercept all print button clicks
                    document.addEventListener("click", function(e) {
                      var el = e.target;
                      while (el) {
                        var onclick = el.getAttribute ? el.getAttribute("onclick") : "";
                        var href = el.href || "";
                        if ((onclick && onclick.toLowerCase().includes("print")) ||
                            href.toLowerCase().includes("print") ||
                            href.toLowerCase().endsWith(".pdf")) {
                          e.preventDefault();
                          e.stopPropagation();
                          window.flutter_inappwebview.callHandler("printHandler");
                          break;
                        }
                        el = el.parentElement;
                      }
                    }, true);
                  })();
                ''');
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri == null) return NavigationActionPolicy.ALLOW;
              final urlStr = uri.toString();

              // Intercept print/view result pages — open in external browser
              if (urlStr.contains('view_insp_result') ||
                  urlStr.contains('print') ||
                  urlStr.toLowerCase().endsWith('.pdf')) {
                // Build full URL if relative
                String fullUrl = urlStr;
                if (!urlStr.startsWith('http')) {
                  final baseUrlStr = _currentUrl.startsWith('http')
                      ? _currentUrl : widget.url;
                  final baseUri = Uri.parse(baseUrlStr);
                  final basePath = baseUri.path.contains('/')
                      ? baseUri.path.substring(0, baseUri.path.lastIndexOf('/') + 1)
                      : '/';
                  fullUrl = '${baseUri.scheme}://${baseUri.host}$basePath$urlStr';
                }
                final launchUri = Uri.parse(fullUrl);
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                }
                return NavigationActionPolicy.CANCEL;
              }

              // Only intercept pure relative URLs like 'index.php'
              if (!urlStr.startsWith('http') &&
                  !urlStr.startsWith('about:') &&
                  !urlStr.startsWith('javascript:') &&
                  !urlStr.startsWith('data:') &&
                  !urlStr.startsWith('blob:') &&
                  _currentUrl.isNotEmpty) {
                final baseUrlStr = _currentUrl.startsWith('http')
                    ? _currentUrl : widget.url;
                final baseUri = Uri.parse(baseUrlStr);
                final basePath = baseUri.path.contains('/')
                    ? baseUri.path.substring(0, baseUri.path.lastIndexOf('/') + 1)
                    : '/';
                final fullUrl2 = '${baseUri.scheme}://${baseUri.host}$basePath$urlStr';
                controller.loadUrl(urlRequest: URLRequest(url: WebUri(fullUrl2)));
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
              onReceivedError: (controller, request, error) {
                setState(() => _isLoading = false);
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                return GeolocationPermissionShowPromptResponse(
                  origin: origin,
                  allow: true,
                  retain: true,
                );
              },
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdf(String url) async {
    try {
      // Open PDF URL in external browser/viewer
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback — load in WebView
        await _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      }
    } catch (e) {
      debugPrint('PDF open error: $e');
    }
  }
}
