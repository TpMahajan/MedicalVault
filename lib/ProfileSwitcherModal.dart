import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'dashboard1.dart';

class ProfileSwitcherModal extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final List<Map<String, dynamic>> linkedProfiles;

  const ProfileSwitcherModal({
    super.key,
    required this.currentUser,
    required this.linkedProfiles,
  });

  @override
  State<ProfileSwitcherModal> createState() => _ProfileSwitcherModalState();
}

class _ProfileSwitcherModalState extends State<ProfileSwitcherModal> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  "Switch Profile",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,
                      color: Theme.of(context).iconTheme.color),
                ),
              ],
            ),
          ),
          // Current profile
          _buildCurrentProfileSection(),
          Divider(color: Theme.of(context).dividerColor),
          // Linked profiles
          Expanded(
            child: widget.linkedProfiles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.linkedProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = widget.linkedProfiles[index];
                      return _buildProfileTile(profile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).primaryColor,
            child: widget.currentUser['profilePicture'] != null
                ? ClipOval(
                    child: Image.network(
                      widget.currentUser['profilePicture'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 25,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 25,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.currentUser['name'] ?? 'Current User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  widget.currentUser['email'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Current",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 64,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No linked profiles",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Add profiles to switch between them",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(Map<String, dynamic> profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Theme.of(context).cardColor,
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).primaryColor,
          child: profile['profilePicture'] != null
              ? ClipOval(
                  child: Image.network(
                    profile['profilePicture'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 25,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 25,
                ),
        ),
        title: Text(
          profile['name'] ?? 'Unknown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          profile['email'] ?? '',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.swap_horiz,
                color: Theme.of(context).iconTheme.color,
              ),
        onTap: isLoading ? null : () => _showSwitchDialog(profile),
      ),
    );
  }

  void _showSwitchDialog(Map<String, dynamic> profile) {
    final passwordController = TextEditingController();
    bool isPasswordLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text("Switch to ${profile['name']}",
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter password for ${profile['name']}:",
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter password",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !isPasswordLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isPasswordLoading ? null : () => Navigator.pop(context),
              child:
                  Text("Cancel", style: Theme.of(context).textTheme.bodyLarge),
            ),
            TextButton(
              onPressed: isPasswordLoading
                  ? null
                  : () async {
                      setState(() {
                        isPasswordLoading = true;
                      });
                      try {
                        await ApiService.switchProfile(
                          profile['_id'].toString(),
                          passwordController.text.trim(),
                        );

                        // Get updated user data
                        final prefs = await SharedPreferences.getInstance();
                        final userDataString = prefs.getString('userData');
                        final userData = userDataString != null
                            ? jsonDecode(userDataString)
                            : <String, dynamic>{};

                        Navigator.pop(context); // Close password dialog
                        Navigator.pop(context); // Close profile switcher

                        // Navigate to dashboard with new profile
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Dashboard1(userData: userData),
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Switched to ${profile['name']}"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          isPasswordLoading = false;
                        });
                      }
                    },
              child: isPasswordLoading
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
}
