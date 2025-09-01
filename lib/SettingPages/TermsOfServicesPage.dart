import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Terms of Service'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to our Health Vault App! By using our services, you agree to the following Terms and Conditions. Please read them carefully.\n\n'
                      '1. Acceptance of Terms\n'
                      'By accessing or using our app, you acknowledge that you have read, understood, and agree to be bound by these terms. If you do not agree, please do not use our services.\n\n'
                      '2. Description of Services\n'
                      'Our app provides a platform for managing your healthcare, including scheduling appointments, accessing medical records, and communicating with healthcare providers.\n\n'
                      '3. User Accounts\n'
                      'You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. Notify us immediately of any unauthorized use.\n\n'
                      '4. Privacy Policy\n'
                      'Your privacy is important to us. Our Privacy Policy, available on our website, explains how we collect, use, and protect your personal information.\n\n'
                      '5. Disclaimer of Warranties\n'
                      'Our app is provided "as is" without any warranties, express or implied. We do not guarantee the accuracy, completeness, or reliability of the information provided.\n\n'
                      '6. Limitation of Liability\n'
                      'We shall not be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of your use of our app.\n\n'
                      '7. Modifications to Terms\n'
                      'We reserve the right to modify these terms at any time. Your continued use of the app after any changes constitutes your acceptance of the new terms.\n\n'
                      '8. Governing Law\n'
                      'These terms shall be governed by and construed in accordance with the laws of the jurisdiction in which our company is registered.',
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
                child: const Text('Accept'),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: ElevatedButton(
          //           onPressed: () => Navigator.pop(context),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.blue,
          //             foregroundColor: Colors.white,
          //           ),
          //           child: const Text('Accept'),
          //         ),
          //       ),
          //       const SizedBox(width: 16.0),
          //       // Expanded(
          //       //   child: OutlinedButton(
          //       //     onPressed: () => Navigator.pop(context),
          //       //     style: OutlinedButton.styleFrom(
          //       //       foregroundColor: Colors.blue,
          //       //       side: const BorderSide(color: Colors.green),
          //       //     ),
          //       //     child: const Text('Decline'),
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}