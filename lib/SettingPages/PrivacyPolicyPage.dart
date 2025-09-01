import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'This Privacy Policy describes how we collect, use, and share your personal information when you use our healthcare app. We are committed to protecting your privacy and ensuring the security of your information. By using our app, you agree to the terms of this Privacy Policy. We collect information you provide directly, such as your name, contact details, and health information. We also collect information automatically, including your device information and app usage data. We use your information to provide and improve our services, personalize your experience, and communicate with you. We may share your information with healthcare providers, service providers, and as required by law. We implement security measures to protect your information, but no method of transmission over the Internet is completely secure. You have rights regarding your personal information, including the right to access, correct, and delete your information. We may update this Privacy Policy from time to time, and we will notify you of any significant changes. If you have any questions or concerns about this Privacy Policy, please contact us. Your privacy is important to us, and we are dedicated to maintaining the confidentiality and security of your personal information.',
                  style: const TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('I Understand'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}