import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileName extends StatefulWidget {
  final Map<String, dynamic> userData; // Pass all fields here

  const ProfileName({super.key, required this.userData});

  @override
  State<ProfileName> createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/9203/9203764.png'),
              ),
              const SizedBox(height: 8),
              Text(
                user['name'] ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user['email'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 📱 Mobile
              _infoCard(Icons.phone, "Mobile Number", user['mobile'] ?? '',
                  bgColor: Colors.white, textColor: Colors.grey),

              const SizedBox(height: 16),

              // 🆔 Aadhaar
              _infoCard(Icons.security, "Aadhaar Card Number",
                  user['aadhaar'] ?? '',
                  bgColor: const Color(0xFF80CBC4), textColor: Colors.white),

              const SizedBox(height: 16),

              // 🎂 DOB
              _infoCard(Icons.calendar_today, "Date of Birth",
                  user['dateOfBirth'] ?? '',
                  bgColor: Colors.white, textColor: Colors.grey),

              const SizedBox(height: 16),

              // 🔹 Age, Gender, Blood Type
              _infoCard(Icons.person, "Age / Gender / Blood",
                  "${user['age'] ?? ''} / ${user['gender'] ?? ''} / ${user['bloodType'] ?? ''}",
                  bgColor: Colors.white, textColor: Colors.black),

              const SizedBox(height: 16),

              // 🔹 Height, Weight
              _infoCard(Icons.monitor_weight, "Height / Weight",
                  "${user['height'] ?? ''} / ${user['weight'] ?? ''}",
                  bgColor: Colors.white, textColor: Colors.black),

              const SizedBox(height: 16),

              // 🔹 Last Visit, Next Appointment
              _infoCard(Icons.calendar_month, "Visits",
                  "Last: ${user['lastVisit'] ?? ''}\nNext: ${user['nextAppointment'] ?? ''}",
                  bgColor: Colors.white, textColor: Colors.black),

              const SizedBox(height: 16),

              // 🔹 Emergency Contact
              _infoCard(Icons.contact_phone, "Emergency Contact",
                  "${user['emergencyContact']?['name'] ?? ''}\n"
                      "${user['emergencyContact']?['relationship'] ?? ''}\n"
                      "${user['emergencyContact']?['phone'] ?? ''}",
                  bgColor: Colors.red.shade200, textColor: Colors.black),

              const SizedBox(height: 16),

              // 🔹 Medical History
              _listCard("Medical History", user['medicalHistory'] ?? [],
                      (item) =>
                  "${item['condition']} (${item['status']}) - ${item['diagnosed']}"),

              const SizedBox(height: 16),

              // 🔹 Medications
              _listCard("Medications", user['medications'] ?? [],
                      (item) =>
                  "${item['name']} - ${item['dosage']} (${item['frequency']})"),

              const SizedBox(height: 16),

              // 🔹 Medical Records
              _listCard("Medical Records", user['medicalRecords'] ?? [],
                      (item) =>
                  "${item['title']} (${item['type']}) - ${item['date']} [${item['status']}]"),

              const SizedBox(height: 32),

              // ✏️ Edit Button
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
                      borderRadius: BorderRadius.circular(8),
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

  Widget _infoCard(IconData icon, String title, String value,
      {required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: textColor),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          Text(value, style: TextStyle(fontSize: 16, color: textColor)),
        ],
      ),
    );
  }

  Widget _listCard(String title, List items, String Function(dynamic) format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text("No data available",
                style: TextStyle(color: Colors.grey)),
          for (var item in items) Text(format(item)),
        ],
      ),
    );
  }
}

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
      _controllers[field] =
          TextEditingController(text: widget.userData[field]?.toString() ?? "");
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
                  onPressed: () {
                    final updatedUser = Map<String, dynamic>.from(widget.userData);
                    updatedUser.addAll({
                      "name": _controllers["name"]!.text,
                      "email": _controllers["email"]!.text,
                      "mobile": _controllers["mobile"]!.text,
                      "aadhaar": _controllers["aadhaar"]!.text,
                      "dateOfBirth": _controllers["dateOfBirth"]!.text,
                      "age": _controllers["age"]!.text,
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
                    });
                    Navigator.pop(context, updatedUser);
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
