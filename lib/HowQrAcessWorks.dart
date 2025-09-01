import 'package:flutter/material.dart';

class QrAccessWorks extends StatelessWidget {
  const QrAccessWorks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How QR Access Works"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📌 How QR Access Works",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "QR access allows you to securely share or retrieve your documents "
                  "without manually entering details. Here’s how it works:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Step 1
            const Text("1. Generate a QR Code",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              "• When you upload a document, the app can generate a unique QR code "
                  "linked to that file.\n• This QR code acts like a digital key.",
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Step 2
            const Text("2. Scan the QR Code",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              "• Another user (or you, on a different device) can scan the QR code "
                  "using the app’s built-in scanner.\n• Scanning instantly retrieves the "
                  "file details from the secure server.",
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Step 3
            const Text("3. Access Control",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              "• The QR code is tied to your account/document, so only people with "
                  "the code can access it.\n• Optionally, QR codes can be time-limited "
                  "or password-protected for extra security.",
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Step 4
            const Text("4. Use Cases",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              "• Quickly open your medical reports at a hospital.\n"
                  "• Share bills or prescriptions with family or doctors without "
                  "sending files manually.\n"
                  "• Access your own documents on a new device just by scanning your saved QR.",
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            const Text(
              "⚡ In short: QR = Quick + Secure + Hassle-free access to your digital vault.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // ✅ conflict resolved
              ),
            ),
          ],
        ),
      ),
    );
  }
}
