import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart';

import 'QR.dart';
import 'SettingPages/ChangePassword.dart';
import 'SettingPages/ContactSupportPage.dart';
import 'SettingPages/FaqPage.dart';
import 'SettingPages/PrivacyPolicyPage.dart';
import 'SettingPages/ProfilePageSetting.dart';
import 'SettingPages/TermsOfServicesPage.dart';
import 'loginScreen.dart';
import 'api_service.dart';
import 'dashboard1.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userData; // 👈 full user data map

  const SettingsPage({super.key, required this.userData});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool approvals = false;
  bool reminders = false;
  bool systemNotifs = false;
  List<Map<String, dynamic>> linkedProfiles = [];
  bool isLoadingProfiles = false;

  @override
  void initState() {
    super.initState();
    _loadLinkedProfiles();
  }

  Future<void> _loadLinkedProfiles() async {
    setState(() {
      isLoadingProfiles = true;
    });
    try {
      final profiles = await ApiService.getLinkedProfiles();
      setState(() {
        linkedProfiles = profiles;
      });
    } catch (e) {
      print("Error loading profiles: $e");
    } finally {
      setState(() {
        isLoadingProfiles = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 safe values nikale
    final String name = widget.userData["name"]?.toString() ?? "Your Name";
    final String email =
        widget.userData["email"]?.toString() ?? "youremail@gmail.com";
    final String mobile = widget.userData["mobile"]?.toString() ?? "N/A";
    final String aadhaar = widget.userData["aadhaar"]?.toString() ?? "N/A";
    final String dob = widget.userData["dateOfBirth"]?.toString() ?? "N/A";

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SectionTitle("My Profile"),
          _buildTile(
            Icons.person,
            "Personal Details",
            "View and edit your personal details",
            ProfileName(
              userData: {
                "name": name,
                "email": email,
                "mobile": mobile,
                "aadhaar": aadhaar,
                "dateOfBirth": dob,
                "age": widget.userData["age"],
                "gender": widget.userData["gender"],
                "bloodType": widget.userData["bloodType"],
                "height": widget.userData["height"],
                "weight": widget.userData["weight"],
                "lastVisit": widget.userData["lastVisit"],
                "nextAppointment": widget.userData["nextAppointment"],
                "emergencyContact": widget.userData["emergencyContact"],
                "medicalHistory": widget.userData["medicalHistory"] ?? [],
                "medications": widget.userData["medications"] ?? [],
                "medicalRecords": widget.userData["medicalRecords"] ?? [],
              },
            ),
          ),
          const SectionTitle("Switch Profile"),
          _buildSwitchProfileSection(),
          const SectionTitle("Security"),
          _buildTile(Icons.lock, "Password", "", ChangePasswordScreen()),
          const SectionTitle("QR & Sharing"),
          _buildTile(Icons.qr_code, "Regenerate QR", "", QRPage()),
          _buildTile(Icons.share, "Sharing Controls", "", QRPage()),
          const SectionTitle("Switch Themes"),
          _buildDarkModeRow(context),
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
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
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

  Widget _buildDarkModeRow(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return ListTile(
      leading: Icon(Icons.dark_mode, color: Theme.of(context).iconTheme.color),
      title: const Text("Dark Mode"),
      trailing: Switch(
        value: isDark,
        onChanged: (_) => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildSwitchProfileSection() {
    return Column(
      children: [
        if (isLoadingProfiles)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )
        else if (linkedProfiles.isEmpty)
          ListTile(
            leading: Icon(Icons.person_add,
                color: Theme.of(context).iconTheme.color),
            title: Text("No linked profiles",
                style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text("Add profiles to switch between them",
                style: Theme.of(context).textTheme.bodyMedium),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).iconTheme.color),
            onTap: _showAddProfileDialog,
          )
        else
          ...linkedProfiles.map((profile) => _buildProfileTile(profile)),
        ListTile(
          leading: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
          title:
              Text("Add Profile", style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text("Link an existing or create new profile",
              style: Theme.of(context).textTheme.bodyMedium),
          trailing: Icon(Icons.arrow_forward_ios,
              color: Theme.of(context).iconTheme.color),
          onTap: _showAddProfileDialog,
        ),
      ],
    );
  }

  Widget _buildProfileTile(Map<String, dynamic> profile) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: profile['profilePicture'] != null
            ? ClipOval(
                child: Image.network(
                  profile['profilePicture'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      color: Colors.white,
                    );
                  },
                ),
              )
            : Icon(
                Icons.person,
                color: Colors.white,
              ),
      ),
      title: Text(profile['name'] ?? 'Unknown',
          style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(profile['email'] ?? '',
          style: Theme.of(context).textTheme.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.swap_horiz,
                color: Theme.of(context).iconTheme.color),
            onPressed: () => _showSwitchProfileDialog(profile),
            tooltip: "Switch to this profile",
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline,
                color: Theme.of(context).colorScheme.error),
            onPressed: () => _showRemoveProfileDialog(profile),
            tooltip: "Remove profile",
          ),
        ],
      ),
    );
  }

  void _showAddProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title:
            Text("Add Profile", style: Theme.of(context).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(Icons.person, color: Theme.of(context).iconTheme.color),
              title: Text("Link Existing Profile",
                  style: Theme.of(context).textTheme.bodyLarge),
              subtitle: Text("Link an existing user account",
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _showLinkExistingProfileDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add,
                  color: Theme.of(context).iconTheme.color),
              title: Text("Create New Profile",
                  style: Theme.of(context).textTheme.bodyLarge),
              subtitle: Text("Create a new profile and link it",
                  style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _showCreateNewProfileDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
        ],
      ),
    );
  }

  void _showLinkExistingProfileDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Link Existing Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Enter email of existing profile",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child:
                  Text("Cancel", style: Theme.of(context).textTheme.bodyLarge),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await ApiService.addSelfProfile(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        await _loadLinkedProfiles();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Profile linked successfully")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Link"),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNewProfileDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Create New Profile"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    hintText: "Enter full name",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Enter email address",
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: "Mobile",
                    hintText: "Enter mobile number",
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child:
                  Text("Cancel", style: Theme.of(context).textTheme.bodyLarge),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await ApiService.addOtherProfile(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          mobile: mobileController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        await _loadLinkedProfiles();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Profile created and linked successfully")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  void _showSwitchProfileDialog(Map<String, dynamic> profile) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Switch to ${profile['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter password for ${profile['name']}:"),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child:
                  Text("Cancel", style: Theme.of(context).textTheme.bodyLarge),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await ApiService.switchProfile(
                          profile['_id'].toString(),
                          passwordController.text.trim(),
                        );
                        Navigator.pop(context);
                        // Get updated user data and navigate to dashboard
                        final prefs = await SharedPreferences.getInstance();
                        final userDataString = prefs.getString('userData');
                        final userData = userDataString != null
                            ? jsonDecode(userDataString)
                            : <String, dynamic>{};

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Dashboard1(userData: userData),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Switched to ${profile['name']}")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Switch"),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveProfileDialog(Map<String, dynamic> profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Profile"),
        content: Text(
            "Are you sure you want to remove ${profile['name']} from your linked profiles?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: Theme.of(context).textTheme.bodyLarge),
          ),
          TextButton(
            onPressed: () async {
              try {
                final success = await ApiService.removeLinkedProfile(
                    profile['_id'].toString());
                if (success) {
                  await _loadLinkedProfiles();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("${profile['name']} removed successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to remove profile")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: const Text("Remove"),
          ),
        ],
      ),
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
