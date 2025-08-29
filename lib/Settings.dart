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
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool approvals = false;
  bool reminders = false;
  bool systemNotifs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SectionTitle("My Profile"),
          _buildTile(Icons.person, "Personal Details",
              "View and edit your personal details", ProfileName()),
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
          _buildTile(
              Icons.description, "Terms of Service", "", TermsOfService()),
          const SectionTitle("Help & Support"),
          _buildTile(Icons.help_outline, "FAQs", "", FAQs()),
          _buildTile(Icons.support_agent, "Contact Support", "",
              ContactSupportScreen()),
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

