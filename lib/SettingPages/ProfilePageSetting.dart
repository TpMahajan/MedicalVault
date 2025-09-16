import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class ProfileName extends StatefulWidget {
  final Map<String, dynamic> userData; // Initial data from login

  const ProfileName({super.key, required this.userData});

  @override
  State<ProfileName> createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
  late Map<String, dynamic> user;
  bool _loading = true;
  Map<String, List<dynamic>> medicalRecords = {
    "reports": [],
    "prescriptions": [],
    "bills": [],
    "insurance": [],
  };

  @override
  void initState() {
    super.initState();
    user = widget.userData;
    _fetchProfile();
    _fetchMedicalRecords(); // fetch files separately
  }

  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("authToken");
      if (token == null) return;

      final response = await http.get(
        Uri.parse("https://healthvault-backend-c6xl.onrender.com/api/auth/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          user = body["data"]["user"];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print("❌ Fetch error: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchMedicalRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("authToken");
      if (token == null) return;

      final email = user['email']; // using email as userId
      final response = await http.get(
        Uri.parse("https://healthvault-backend-c6xl.onrender.com/api/files/$email"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          medicalRecords = {
            "reports": body["reports"] ?? [],
            "prescriptions": body["prescriptions"] ?? [],
            "bills": body["bills"] ?? [],
            "insurance": body["insurance"] ?? [],
          };
        });
      }
    } catch (e) {
      print("❌ Medical Records fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/LoadingClock.json',
            width: 80,
            height: 80,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/9203/9203764.png'),
                      ),
                      const SizedBox(height: 8),
                      Text(user['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(user['email'] ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              // Sections
              _sectionTitle("Personal Information"),
              _infoRow(Icons.phone, "Mobile", user['mobile'] ?? ''),
              _infoRow(Icons.security, "Aadhaar", user['aadhaar'] ?? ''),
              _infoRow(Icons.calendar_today, "DOB",
                  user['dateOfBirth']?.toString().split("T")[0] ?? ''),

              _sectionTitle("Health Information"),
              _infoRow(Icons.person, "Gender", user['gender'] ?? ''),
              _infoRow(Icons.water_drop, "Blood Type", user['bloodType'] ?? ''),
              _infoRow(Icons.height, "Height", user['height'] ?? ''),
              _infoRow(Icons.monitor_weight, "Weight", user['weight'] ?? ''),
              _infoRow(Icons.calendar_month, "Last Visit",
                  user['lastVisit']?.toString().split("T")[0] ?? ''),
              _infoRow(Icons.event, "Next Appointment",
                  user['nextAppointment']?.toString().split("T")[0] ?? ''),

              _sectionTitle("Emergency Contact"),
              _infoRow(Icons.person,
                  "Name", user['emergencyContact']?['name'] ?? ''),
              _infoRow(Icons.people, "Relationship",
                  user['emergencyContact']?['relationship'] ?? ''),
              _infoRow(Icons.phone,
                  "Phone", user['emergencyContact']?['phone'] ?? ''),

              _sectionTitle("Medical History"),
              _listSection(user['medicalHistory'] ?? [], (item) =>
              "${item['condition']} (${item['status']}) - ${item['diagnosed']}"),

              _sectionTitle("Medications"),
              _listSection(user['medications'] ?? [], (item) =>
              "${item['name']} - ${item['dosage']} (${item['frequency']})"),

              // ✅ Medical Records from `files` collection
              _medicalRecordsSection(),

              const SizedBox(height: 20),

              // Edit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userData: user),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        user = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isNotEmpty ? value : "N/A",
            style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  Widget _listSection(List items, String Function(dynamic) format) {
    return items.isEmpty
        ? const Text("No data available",
        style: TextStyle(color: Colors.grey))
        : Column(
      children: items
          .map<Widget>((item) => Card(
        child: ListTile(title: Text(format(item))),
      ))
          .toList(),
    );
  }

  // ✅ Medical Records grouped by category from backend
  Widget _medicalRecordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Medical Records"),
        _recordCategoryTile("Reports", medicalRecords["reports"] ?? []),
        _recordCategoryTile("Prescriptions", medicalRecords["prescriptions"] ?? []),
        _recordCategoryTile("Bills", medicalRecords["bills"] ?? []),
        _recordCategoryTile("Insurance", medicalRecords["insurance"] ?? []),
      ],
    );
  }

  Widget _recordCategoryTile(String title, List items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.isEmpty
            ? [const ListTile(title: Text("No records available"))]
            : items.map<Widget>((item) {
          return ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(item["title"] ?? "Untitled"),
            subtitle: Text("${item["date"] ?? ''} (${item["mimeType"] ?? ''})"),
            onTap: () {
              final url = item["url"];
              if (url != null) {
                // TODO: open with url_launcher
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

// ================= Edit Profile Page =================
class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var field in [
      "name",
      "email",
      "mobile",
      "aadhaar",
      "dateOfBirth",
      "age",
      "gender",
      "bloodType",
      "height",
      "weight",
      "lastVisit",
      "nextAppointment",
      "ecName",
      "ecRelationship",
      "ecPhone"
    ]) {
      String value = "";
      if (field.startsWith("ec")) {
        String ecField = field.substring(2).toLowerCase();
        value = widget.userData["emergencyContact"]?[ecField]?.toString() ?? "";
      } else {
        value = widget.userData[field]?.toString() ?? "";
      }
      _controllers[field] = TextEditingController(text: value);
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("authToken");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Not logged in")),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse("https://healthvault-backend-c6xl.onrender.com/api/auth/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updatedUser),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await prefs.setString('userData', jsonEncode(body["data"]));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile updated successfully")),
        );

        Navigator.pop(context, body["data"]);
      } else {
        final errorBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "❌ ${errorBody['message'] ?? 'Failed to update profile'}")),
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              for (var field in _controllers.keys)
                Column(
                  children: [
                    TextFormField(
                      controller: _controllers[field],
                      decoration: InputDecoration(
                        labelText: field,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedUser = {
                      "name": _controllers["name"]!.text,
                      "email": _controllers["email"]!.text,
                      "mobile": _controllers["mobile"]!.text,
                      "aadhaar": _controllers["aadhaar"]!.text,
                      "dateOfBirth": _controllers["dateOfBirth"]!.text,
                      "age": int.tryParse(_controllers["age"]!.text),
                      "gender": _controllers["gender"]!.text,
                      "bloodType": _controllers["bloodType"]!.text,
                      "height": _controllers["height"]!.text,
                      "weight": _controllers["weight"]!.text,
                      "lastVisit": _controllers["lastVisit"]!.text,
                      "nextAppointment": _controllers["nextAppointment"]!.text,
                      "emergencyContact": {
                        "name": _controllers["ecName"]!.text,
                        "relationship": _controllers["ecRelationship"]!.text,
                        "phone": _controllers["ecPhone"]!.text,
                      }
                    };
                    await _saveProfile(updatedUser);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
