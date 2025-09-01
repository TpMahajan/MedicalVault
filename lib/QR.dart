import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:cross_file/cross_file.dart';

// Import the QR access info page
import 'HowQrAcessWorks.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  String _qrData = '';
  final GlobalKey _repaintKey = GlobalKey();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _regenerateQR();
  }

  void _regenerateQR() {
    setState(() {
      _qrData = 'DoctorAccess:${_uuid.v4()}';
    });
  }

  Future<void> _shareQR() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final xfile = XFile.fromData(pngBytes, name: 'qr_code.png', mimeType: 'image/png');
      await Share.shareXFiles([xfile], text: 'Share this QR code');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),

          // QR Image Container (Clickable with Hero Animation)
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false, // important → keeps background visible
                    transitionDuration: const Duration(milliseconds: 400),
                    reverseTransitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => QRZoomPage(qrData: _qrData),
                  ),
                );
              },
              child: Hero(
                tag: "qrHero",
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Doctor will scan to request access",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 20),

          // Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _shareQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Share QR", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _regenerateQR,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Regenerate QR", style: TextStyle(color: Colors.blue)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // "How QR access works?" Button
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrAccessWorks()),
              );
            },
            child: const Text(
              "How QR access works?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

/// Zoomed QR Page with Blurred Background
class QRZoomPage extends StatefulWidget {
  final String qrData;
  const QRZoomPage({super.key, required this.qrData});

  @override
  State<QRZoomPage> createState() => _QRZoomPageState();
}

class _QRZoomPageState extends State<QRZoomPage> with SingleTickerProviderStateMixin {
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

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

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
        backgroundColor: Colors.transparent, // keep original bg visible
        body: Stack(
          children: [
            // Blur the background
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.2)), // frosted effect
            ),

            // Centered QR with animation
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
