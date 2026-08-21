import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/secure_storage.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  String _staffNo = '';
  String _email = '';
  String? _qrBase64;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadStaffInfo();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadStaffInfo() async {
    final email = await SecureStorage.getUsername();
    final savedStaffNo = await SecureStorage.getStaffNo();
    final qrCode = await SecureStorage.getQrCode();
    final staffNo = savedStaffNo?.isNotEmpty == true
        ? savedStaffNo!
        : (email?.split('@').first ?? '');
    setState(() {
      _email = email ?? '';
      _staffNo = staffNo;
      _qrBase64 = qrCode;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B6E),
      appBar: AppBar(
        title: const Text('Kad Pekerja / Staff Card'),
        backgroundColor: const Color(0xFF0D3B6E),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header — LUNAS logo
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/Pi7_Tool_icon.png',
                                width: 50, height: 50,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50, height: 50,
                                  decoration: const BoxDecoration(color: Color(0xFF0D3B6E), shape: BoxShape.circle),
                                  child: const Center(child: Text('⚓', style: TextStyle(fontSize: 22))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LUMUT NAVAL SHIPYARD',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D3B6E), letterSpacing: 0.5)),
                                  Text('Sdn. Bhd. (LUNAS)',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 30, color: Color(0xFFE2E8F0)),

                        // Staff info
                        Container(
                          width: 80, height: 80,
                          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                          child: const Icon(Icons.person, size: 45, color: Color(0xFF0D3B6E)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _email,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                          child: Text('Staff No: $_staffNo', style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                        ),

                        const SizedBox(height: 24),

                        // QR Code — from MyDEX base64 or generated from staff no
                        const Text('QR Code Pekerja', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: _qrBase64 != null && _qrBase64!.isNotEmpty
                              ? Image.memory(
                                  base64Decode(_qrBase64!.contains(',')
                                      ? _qrBase64!.split(',').last
                                      : _qrBase64!),
                                  width: 200, height: 200,
                                  fit: BoxFit.contain,
                                )
                              : QrImageView(
                                  data: _staffNo.isNotEmpty ? _staffNo : _email,
                                  version: QrVersions.auto,
                                  size: 200,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                                ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _staffNo.isNotEmpty ? _staffNo : _email.split('@').first,
                          style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B6E), letterSpacing: 4,
                          ),
                        ),
                        if (_qrBase64 == null || _qrBase64!.isEmpty) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Buka MyDEX untuk sync QR code sebenar',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 20),
                        const Text('Tunjukkan kad ini kepada pengawal untuk imbasan',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Pegang kad pada jarak 10-15cm dari pengimbas.\nPastikan skrin cerah.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

// Barcode painter — renders a Code 39-style barcode
class _BarcodePainter extends CustomPainter {
  final String data;
  _BarcodePainter(this.data);

  // Code 39 encoding (simplified — 9 bars per char, 5 black 4 white alternating)
  static const _code39 = {
    '0': '101001101101', '1': '110100101011', '2': '101100101011',
    '3': '110110010101', '4': '101001101011', '5': '110100110101',
    '6': '101100110101', '7': '101001011011', '8': '110100101101',
    '9': '101100101101', 'A': '110101001011', 'B': '101101001011',
    'C': '110110100101', 'D': '101011001011', 'E': '110101100101',
    'F': '101101100101', 'G': '101010011011', 'H': '110101001101',
    'I': '101101001101', 'J': '101011001101', 'K': '110101010011',
    'L': '101101010011', 'M': '110110101001', 'N': '101011010011',
    'O': '110101101001', 'P': '101101101001', 'Q': '101010110011',
    'R': '110101011001', 'S': '101101011001', 'T': '101011011001',
    'U': '110010101011', 'V': '100110101011', 'W': '110011010101',
    'X': '100101101011', 'Y': '110010110101', 'Z': '100110110101',
    ' ': '100110101101', '-': '100101011011', '.': '110010101101',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Start/end with quiet zone
    String encoded = '*${data.toUpperCase()}*';
    List<int> bars = [];

    for (final char in encoded.characters) {
      final pattern = _code39[char] ?? _code39['0']!;
      for (int i = 0; i < pattern.length; i++) {
        bars.add(pattern[i] == '1' ? 2 : 1); // wide=2, narrow=1
      }
      bars.add(1); // inter-char gap
    }

    final totalUnits = bars.fold(0, (a, b) => a + b);
    if (totalUnits == 0) return;

    final unitW = size.width / totalUnits;
    double x = 0;

    for (int i = 0; i < bars.length; i++) {
      final w = bars[i] * unitW;
      if (i % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.data != data;
}
