import 'package:flutter/material.dart';

class QrAccessWorks extends StatelessWidget {
  const QrAccessWorks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "How QR Access Works",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📌 How QR Access Works",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              "QR access allows you to securely share or retrieve your documents "
              "without manually entering details. Here's how it works:",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Step 1
            Text("1. Generate a QR Code",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 6),
            Text(
              "• When you upload a document, the app can generate a unique QR code "
              "linked to that file.\n• This QR code acts like a digital key.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Step 2
            Text("2. Scan the QR Code",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 6),
            Text(
              "• Another user (or you, on a different device) can scan the QR code "
              "using the app's built-in scanner.\n• Scanning instantly retrieves the "
              "file details from the secure server.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Step 3
            Text("3. Access Control",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 6),
            Text(
              "• The QR code is tied to your account/document, so only people with "
              "the code can access it.\n• Optionally, QR codes can be time-limited "
              "or password-protected for extra security.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Step 4
            Text("4. Use Cases",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 6),
            Text(
              "• Quickly open your medical reports at a hospital.\n"
              "• Share bills or prescriptions with family or doctors without "
              "sending files manually.\n"
              "• Access your own documents on a new device just by scanning your saved QR.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              "⚡ In short: QR = Quick + Secure + Hassle-free access to your digital vault.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
