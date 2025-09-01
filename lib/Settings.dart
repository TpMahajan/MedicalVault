import 'package:flutter/material.dart';

import 'QR.dart';
import 'SettingPages/ChangePassword.dart';
import 'SettingPages/ContactSupportPage.dart';
import 'SettingPages/FaqPage.dart';
import 'SettingPages/PrivacyPolicyPage.dart';
import 'SettingPages/ProfilePageSetting.dart';
import 'SettingPages/TermsOfServicesPage.dart';
import 'loginScreen.dart';

class SettingsPage extends StatefulWidget {
<<<<<<< HEAD
  final Map<String, dynamic> userData; // 👈 yaha rakha hai

  const SettingsPage({super.key, required this.userData}); // 👈 required parameter
=======
  const SettingsPage({super.key});
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool approvals = false;
  bool reminders = false;
  bool systemNotifs = false;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // 👇 yaha safe values nikale
    final String name = widget.userData["name"]?.toString() ?? "Your Name";
    final String email = widget.userData["email"]?.toString() ?? "youremail@gmail.com";
    final String mobile = widget.userData["mobile"]?.toString() ?? "N/A";
    final String aadhaar = widget.userData["aadhaar"]?.toString() ?? "N/A";
    final String dob = widget.userData["dob"]?.toString() ?? "N/A";

=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SectionTitle("My Profile"),
<<<<<<< HEAD
          _buildTile(
            Icons.person,
            "Personal Details",
            "View and edit your personal details",
            ProfileName(
              name: name,
              email: email,
              mobile: mobile,
              aadhaar: aadhaar,
              dob: dob,
            ),
          ),

=======
          _buildTile(Icons.person, "Personal Details",
              "View and edit your personal details", ProfileName()),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
          const SectionTitle("Security"),
          _buildTile(Icons.lock, "Password", "", ForgotPasswordScreen()),
          // _buildTile(Icons.fingerprint, "Biometrics", "", ProfileName()),
          const SectionTitle("QR & Sharing"),
          _buildTile(Icons.qr_code, "Regenerate QR", "", QRPage()),
          _buildTile(Icons.share, "Sharing Controls", "", QRPage()),
          const SectionTitle("Notifications"),
          _buildSwitchTile(
              "Approvals", "Receive notifications for approvals", approvals,
                  (val) {
                setState(() => approvals = val);
              }),
          _buildSwitchTile(
              "Reminders", "Receive notifications for reminders", reminders,
                  (val) {
                setState(() => reminders = val);
              }),
          _buildSwitchTile(
              "System", "Receive system notifications", systemNotifs, (val) {
            setState(() => systemNotifs = val);
          }),
          const SectionTitle("Privacy & Terms"),
          _buildTile(Icons.privacy_tip, "Privacy Policy", "", PrivacyPolicy()),
<<<<<<< HEAD
          _buildTile(Icons.description, "Terms of Service", "", TermsOfService()),
          const SectionTitle("Help & Support"),
          _buildTile(Icons.help_outline, "FAQs", "", FAQs()),
          _buildTile(Icons.support_agent, "Contact Support", "", ContactSupportScreen()),
=======
          _buildTile(
              Icons.description, "Terms of Service", "", TermsOfService()),
          const SectionTitle("Help & Support"),
          _buildTile(Icons.help_outline, "FAQs", "", FAQs()),
          _buildTile(Icons.support_agent, "Contact Support", "",
              ContactSupportScreen()),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
          const SectionTitle("Account"),
          _buildTile(Icons.logout, "Logout", "", LoginScreen()),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
<<<<<<< HEAD
=======

>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
