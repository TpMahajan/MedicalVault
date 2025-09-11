import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'HowQrAcessWorks.dart';

/// 👉 Your deployed backend base URL (no trailing slash)
/// Make sure this matches your Render service
const String kApiBase = 'https://healthvault-backend-c6xl.onrender.com';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  String _qrData = '';
  final GlobalKey _repaintKey = GlobalKey();
  final Uuid _uuid = const Uuid();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _regenerateQR(); // on open, generate from backend
  }

  Future<void> _regenerateQR() async {
    setState(() => _loading = true);

    try {
      // 1) Read login token saved after /api/auth/login
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        // Fallback so UI doesn't break if not logged in
        setState(() {
          _qrData = 'DoctorAccess:${_uuid.v4()}';
          _loading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not logged in: showing placeholder QR')),
          );
        }
        return;
      }

      // 2) Call backend to get short-lived QR token (uid + email embedded)
      final uri = Uri.parse('$kApiBase/api/qr/generate');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final ok = body['ok'] == true || body['success'] == true;
        if (!ok) {
          throw Exception(body['msg'] ?? 'Failed to generate QR');
        }

        final qrUrl = (body['qrUrl'] ?? '').toString();
        final token = (body['token'] ?? '').toString();

        // 3) Choose what to embed in QR:
        //    Recommended = qrUrl (so scan opens your portal directly)
        setState(() {
          _qrData = qrUrl.isNotEmpty ? qrUrl : token;
          _loading = false;
        });

        // Optional local debug: print JWT payload
        // _debugLogJwt(token);
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      // Fallback to placeholder so UI stays functional
      setState(() {
        _qrData = 'DoctorAccess:${_uuid.v4()}';
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR generation failed: $e')),
        );
      }
    }
  }

  // Debug helper: decode JWT payload (optional)
  void _debugLogJwt(String token) {
    try {
      if (token.split('.').length == 3) {
        final payload = token.split('.')[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        // ignore: avoid_print
        print('QR JWT payload: $decoded'); // should include uid/email/exp
      }
    } catch (_) {}
  }

  Future<void> _shareQR() async {
    try {
      final boundary =
      _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final xfile =
      XFile.fromData(pngBytes, name: 'qr_code.png', mimeType: 'image/png');
      await Share.shareXFiles([xfile], text: 'Share this QR code');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)], // Light Blue Gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // QR Card with shadow (UI unchanged)
            GestureDetector(
              onTap: () {
                if (_qrData.isEmpty) return;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    transitionDuration: const Duration(milliseconds: 400),
                    reverseTransitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => QRZoomPage(qrData: _qrData),
                  ),
                );
              },
              child: Hero(
                tag: "qrHero",
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Doctor will scan this QR to request access",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            // Buttons (UI unchanged)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  // Share QR (Gradient)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _qrData.isEmpty ? null : _shareQR,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text("Share QR"),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Regenerate QR (Same Gradient)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _regenerateQR,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Regenerate QR"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // How QR works? (Gradient Text Button)
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QrAccessWorks()),
                        );
                      },
                      child: const Text(
                        "How QR access works?",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white, // masked by gradient
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Zoomed QR Page with Blurred Background (UI unchanged)
class QRZoomPage extends StatefulWidget {
  final String qrData;
  const QRZoomPage({super.key, required this.qrData});

  @override
  State<QRZoomPage> createState() => _QRZoomPageState();
}

class _QRZoomPageState extends State<QRZoomPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Light blur background
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.white.withOpacity(0.6)),
            ),

            // Centered QR
            Center(
              child: Hero(
                tag: "qrHero",
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: QrImageView(
                      data: widget.qrData,
                      version: QrVersions.auto,
                      size: 350.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
