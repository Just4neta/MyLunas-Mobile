import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/secure_storage.dart';

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

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    javaScriptCanOpenWindowsAutomatically: true,
    allowsBackForwardNavigationGestures: true,
    supportZoom: true,
    builtInZoomControls: false,
    userAgent: 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  );

  Future<void> _tryAutoLogin(String currentUrl) async {
    final email = await SecureStorage.getUsername();
    final password = await SecureStorage.getPassword();
    if (email == null || password == null) return;

    if (currentUrl.contains('apps2.mylunas.com.my/mars')) {
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
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: _settings,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              if (widget.autoLogin && url != null) {
                await _tryAutoLogin(url.toString());
              }
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
    );
  }
}
