import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileName extends StatefulWidget {
<<<<<<< HEAD
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
=======
  const ProfileName({super.key});
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

  @override
  State<ProfileName> createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
<<<<<<< HEAD
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
=======
  String name = 'Ramesh Solankhe';
  String email = 'rsolankhi@email.com';
  String mobile = '+91 9876543210';
  String aadhaar = 'XXXX-XXXX-7788';
  String dob = '1990-05-15';
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFE3F2FD),
=======
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
<<<<<<< HEAD
                      'https://cdn-icons-png.flaticon.com/512/9203/9203764.png'),
=======
                      'https://cdn-icons-png.flaticon.com/512/9203/9203764.png'), // Placeholder for profile image
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
<<<<<<< HEAD

                // Mobile
=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
<<<<<<< HEAD
                      const Icon(Icons.phone, size: 40, color: Colors.grey),
=======
                      const Icon(
                        Icons.phone,
                        size: 40,
                        color: Colors.grey,
                      ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                      const SizedBox(height: 8),
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
<<<<<<< HEAD
                      Text(mobile,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
=======
                      Text(
                        mobile,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                    ],
                  ),
                ),
                const SizedBox(height: 16),
<<<<<<< HEAD

                // Aadhaar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF80CBC4),
=======
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF80CBC4), // Teal green
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
<<<<<<< HEAD
                      const Icon(Icons.security,
                          size: 40, color: Colors.white),
=======
                      const Icon(
                        Icons.security,
                        size: 40,
                        color: Colors.white,
                      ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                      const SizedBox(height: 8),
                      const Text(
                        'Aadhaar Card Number',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
<<<<<<< HEAD
                      Text(aadhaar,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white70)),
=======
                      Text(
                        aadhaar,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                    ],
                  ),
                ),
                const SizedBox(height: 16),
<<<<<<< HEAD

                // DOB
=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
<<<<<<< HEAD
                      const Icon(Icons.calendar_today,
                          size: 40, color: Colors.grey),
=======
                      const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Colors.grey,
                      ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                      const SizedBox(height: 8),
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
<<<<<<< HEAD
                      Text(dob,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Edit button
=======
                      Text(
                        dob,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
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
      ),
    );
  }
}

<<<<<<< HEAD
/// 👇 Ye niche add karna zaroori hai
=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
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
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Edit Profile')),
=======
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
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
<<<<<<< HEAD
=======
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
<<<<<<< HEAD
=======
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
<<<<<<< HEAD
=======
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mobile number';
                  }
                  if (!RegExp(r'^\+?[1-9]\d{1,14}$')
                      .hasMatch(value.replaceAll(RegExp(r'[\s()-]'), ''))) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Card Number',
                  border: OutlineInputBorder(),
                ),
<<<<<<< HEAD
=======
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Aadhaar card number';
                  }
                  final cleanValue = value.replaceAll(RegExp(r'[-X ]'), '');
                  if (cleanValue.length != 12 ||
                      !RegExp(r'^\d{12}$').hasMatch(cleanValue)) {
                    return 'Please enter a valid 12-digit Aadhaar number';
                  }
                  return null;
                },
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
<<<<<<< HEAD
                readOnly: true,
=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
<<<<<<< HEAD
                onTap: () => _selectDate(context),
=======
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date of birth';
                  }
                  try {
                    DateFormat('yyyy-MM-dd').parseStrict(value);
                    return null;
                  } catch (e) {
                    return 'Please enter a valid date in YYYY-MM-DD format';
                  }
                },
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
<<<<<<< HEAD
                  onPressed: () {
                    Navigator.pop(context, {
                      "name": _nameController.text,
                      "email": _emailController.text,
                      "mobile": _mobileController.text,
                      "aadhaar": _aadhaarController.text,
                      "dob": _dobController.text,
                    });
=======
                  onPressed: () async {
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
<<<<<<< HEAD
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
=======
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
            ],
          ),
        ),
      ),
    );
  }
}
