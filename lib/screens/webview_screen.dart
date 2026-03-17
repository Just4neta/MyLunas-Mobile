import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final IconData icon;
  final Color color;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    required this.icon,
    required this.color,
  });

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Suntik JavaScript untuk pengalaman mobile lebih baik
            _controller.runJavaScript('''
              // Pastikan viewport sesuai untuk mobile
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              document.getElementsByTagName('head')[0].appendChild(meta);
              
              // Sembunyikan elemen yang mungkin mengganggu
              setTimeout(function() {
                // Cuba sembunyikan header/footer jika ada
                var elements = document.querySelectorAll('header, footer, .header, .footer, nav, .navbar');
                elements.forEach(function(el) {
                  if (el) el.style.display = 'none';
                });
              }, 1000);
            ''');
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ralat memuatkan: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Butang Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
          // Butang Buka dalam Browser
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {
              // Buka dalam browser luar
              _showExternalBrowserDialog();
            },
          ),
        ],
        bottom: _isLoading && _progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : null,
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  void _showExternalBrowserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka dalam Browser'),
        content: const Text('Anda pasti mahu buka pautan ini dalam browser luar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Di sini anda boleh guna url_launcher untuk buka browser
              // Tapi untuk sekarang, kita tunjuk mesej
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fungsi ini akan ditambah kemudian'),
                ),
              );
            },
            child: const Text('BUKA'),
          ),
        ],
      ),
    );
  }
}