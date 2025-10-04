import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool _hasAcceptedPrivacy = false;
  bool _isLoading = true;
  String _lastUpdated = '';
  String _version = '1.0';
  List<Map<String, dynamic>> _privacyUpdates = [];
  bool _showUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacyStatus();
    _fetchPrivacyUpdates();
  }

  Future<void> _loadPrivacyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasAcceptedPrivacy = prefs.getBool('privacy_accepted') ?? false;
      _lastUpdated = prefs.getString('privacy_last_updated') ?? '2024-01-01';
      _version = prefs.getString('privacy_version') ?? '1.0';
      _isLoading = false;
    });
  }

  Future<void> _fetchPrivacyUpdates() async {
    try {
      // Simulate fetching privacy updates from server
      // In real implementation, this would be an API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _privacyUpdates = [
          {
            'date': '2024-01-15',
            'version': '1.1',
            'changes': [
              'Added biometric authentication support',
              'Enhanced data encryption protocols',
              'Updated third-party data sharing policies'
            ]
          },
          {
            'date': '2024-01-01',
            'version': '1.0',
            'changes': [
              'Initial privacy policy implementation',
              'Basic data collection and usage policies',
              'User consent mechanisms'
            ]
          }
        ];
      });
    } catch (e) {
      print('Error fetching privacy updates: $e');
    }
  }

  Future<void> _acceptPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_accepted', true);
    await prefs.setString(
        'privacy_accepted_date', DateTime.now().toIso8601String());
    await prefs.setString('privacy_version', _version);

    setState(() {
      _hasAcceptedPrivacy = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy accepted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privacy Policy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            onPressed: () {
              setState(() {
                _showUpdates = !_showUpdates;
              });
            },
            tooltip: 'Show Updates',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Privacy Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: _hasAcceptedPrivacy
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Row(
                    children: [
                      Icon(
                        _hasAcceptedPrivacy
                            ? Icons.check_circle
                            : Icons.warning,
                        color:
                            _hasAcceptedPrivacy ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _hasAcceptedPrivacy
                              ? 'Privacy Policy Accepted (v$_version)'
                              : 'Please review and accept our Privacy Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _hasAcceptedPrivacy
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Privacy Updates Section
                if (_showUpdates) _buildPrivacyUpdatesSection(),

                // Main Privacy Policy Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('1. Information We Collect'),
                          _buildBulletPoint(
                              'Personal Information: Name, email, phone number, date of birth'),
                          _buildBulletPoint(
                              'Health Information: Medical records, prescriptions, test results'),
                          _buildBulletPoint(
                              'Device Information: Device type, operating system, unique identifiers'),
                          _buildBulletPoint(
                              'Usage Data: App interactions, features used, time spent'),
                          _buildBulletPoint(
                              'Location Data: General location for emergency services (optional)'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('2. How We Use Your Information'),
                          _buildBulletPoint(
                              'Provide healthcare services and medical consultations'),
                          _buildBulletPoint(
                              'Maintain your medical records and health history'),
                          _buildBulletPoint(
                              'Send appointment reminders and health notifications'),
                          _buildBulletPoint(
                              'Improve app functionality and user experience'),
                          _buildBulletPoint(
                              'Comply with legal and regulatory requirements'),
                          _buildBulletPoint(
                              'Emergency medical situations and safety alerts'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('3. Information Sharing'),
                          _buildBulletPoint(
                              'Healthcare Providers: Share with your authorized doctors and specialists'),
                          _buildBulletPoint(
                              'Emergency Services: Share critical information in life-threatening situations'),
                          _buildBulletPoint(
                              'Service Providers: Trusted third parties who assist in app operations'),
                          _buildBulletPoint(
                              'Legal Requirements: When required by law or court order'),
                          _buildBulletPoint(
                              'Your Consent: Only with your explicit permission for other purposes'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('4. Data Security'),
                          _buildBulletPoint(
                              'End-to-end encryption for all health data transmission'),
                          _buildBulletPoint(
                              'Secure cloud storage with industry-standard security protocols'),
                          _buildBulletPoint(
                              'Regular security audits and vulnerability assessments'),
                          _buildBulletPoint(
                              'Access controls and authentication mechanisms'),
                          _buildBulletPoint(
                              'Data backup and disaster recovery procedures'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('5. Your Rights'),
                          _buildBulletPoint(
                              'Access: Request copies of your personal and health information'),
                          _buildBulletPoint(
                              'Correction: Update or correct inaccurate information'),
                          _buildBulletPoint(
                              'Deletion: Request deletion of your data (subject to legal requirements)'),
                          _buildBulletPoint(
                              'Portability: Export your data in a standard format'),
                          _buildBulletPoint(
                              'Restriction: Limit how we process your information'),
                          _buildBulletPoint(
                              'Objection: Object to certain types of data processing'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('6. Data Retention'),
                          _buildBulletPoint(
                              'Medical records: Retained as required by healthcare regulations'),
                          _buildBulletPoint(
                              'Account data: Retained while your account is active'),
                          _buildBulletPoint(
                              'Usage data: Retained for up to 2 years for analytics'),
                          _buildBulletPoint(
                              'Deleted data: Permanently removed from all systems'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('7. Children\'s Privacy'),
                          _buildBulletPoint(
                              'App is not intended for children under 13 years of age'),
                          _buildBulletPoint(
                              'We do not knowingly collect information from children under 13'),
                          _buildBulletPoint(
                              'Parents can manage their children\'s health information'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('8. International Transfers'),
                          _buildBulletPoint(
                              'Data may be transferred to countries with adequate protection'),
                          _buildBulletPoint(
                              'We ensure appropriate safeguards for international transfers'),
                          _buildBulletPoint(
                              'You will be notified of any significant changes to data location'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('9. Policy Updates'),
                          _buildBulletPoint(
                              'We may update this policy from time to time'),
                          _buildBulletPoint(
                              'Significant changes will be notified via app notification'),
                          _buildBulletPoint(
                              'Continued use of the app constitutes acceptance of updates'),
                          _buildBulletPoint(
                              'Previous versions are available upon request'),
                          const SizedBox(height: 20),
                          _buildSectionTitle('10. Contact Information'),
                          _buildBulletPoint(
                              'Privacy Officer: privacy@healthvault.com'),
                          _buildBulletPoint(
                              'Data Protection Officer: dpo@healthvault.com'),
                          _buildBulletPoint(
                              'General Inquiries: support@healthvault.com'),
                          _buildBulletPoint('Phone: +1-800-HEALTH-VAULT'),
                          _buildBulletPoint(
                              'Address: 123 Healthcare Street, Medical City, MC 12345'),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info,
                                        color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Updated: $_lastUpdated',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Version: $_version',
                                  style: TextStyle(color: Colors.blue.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (!_hasAcceptedPrivacy) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _acceptPrivacyPolicy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Accept Privacy Policy'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                              _hasAcceptedPrivacy ? 'Close' : 'I Understand'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Colors.grey)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyUpdatesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.update, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Recent Privacy Policy Updates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._privacyUpdates.map((update) => _buildUpdateItem(update)),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(Map<String, dynamic> update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Version ${update['version']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                update['date'],
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(update['changes'] as List).map((change) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(
                        change,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
