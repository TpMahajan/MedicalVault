import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileName extends StatefulWidget {
  final String name;
  final String email;
  final String mobile;
  final String aadhaar;
  final String dob;

  const ProfileName({
    super.key,
    required this.name,
    required this.email,
    required this.mobile,
    required this.aadhaar,
    required this.dob,
  });

  @override
  State<ProfileName> createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
  late String name;
  late String email;
  late String mobile;
  late String aadhaar;
  late String dob;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    email = widget.email;
    mobile = widget.mobile;
    aadhaar = widget.aadhaar;
    dob = widget.dob;
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
                name,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 📱 Mobile
              _infoCard(Icons.phone, "Mobile Number", mobile,
                  bgColor: Colors.white, textColor: Colors.grey),

              const SizedBox(height: 16),

              // 🆔 Aadhaar
              _infoCard(Icons.security, "Aadhaar Card Number", aadhaar,
                  bgColor: const Color(0xFF80CBC4), textColor: Colors.white),

              const SizedBox(height: 16),

              // 🎂 DOB
              _infoCard(Icons.calendar_today, "Date of Birth", dob,
                  bgColor: Colors.white, textColor: Colors.grey),

              const SizedBox(height: 32),

              // ✏️ Edit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          initialName: name,
                          initialEmail: email,
                          initialMobile: mobile,
                          initialAadhaar: aadhaar,
                          initialDob: dob,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        name = result['name'];
                        email = result['email'];
                        mobile = result['mobile'];
                        aadhaar = result['aadhaar'];
                        dob = result['dob'];
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
}

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialMobile;
  final String initialAadhaar;
  final String initialDob;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAadhaar,
    required this.initialDob,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _aadhaarController;
  late TextEditingController _dobController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _mobileController = TextEditingController(text: widget.initialMobile);
    _aadhaarController = TextEditingController(text: widget.initialAadhaar);
    _dobController = TextEditingController(text: widget.initialDob);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Card Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      "name": _nameController.text,
                      "email": _emailController.text,
                      "mobile": _mobileController.text,
                      "aadhaar": _aadhaarController.text,
                      "dob": _dobController.text,
                    });
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
