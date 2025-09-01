import 'package:flutter/material.dart';
import 'package:hello/dashboard1.dart';
import 'package:hello/SignUp.dart';
import 'package:hello/dbHelper/mongodb.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController Email = TextEditingController();
    TextEditingController Password = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true, // 👈 keyboard ke liye
      backgroundColor: Colors.white,
      body: SafeArea(
<<<<<<< HEAD
        child: SingleChildScrollView(
          // 👈 overflow fix
=======
        child: SingleChildScrollView( // 👈 overflow fix
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo and title
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
<<<<<<< HEAD
                      child: const Icon(Icons.shield,
                          color: Colors.blue, size: 40),
=======
                      child: const Icon(Icons.shield, color: Colors.blue, size: 40),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Health Vault',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Securely access your health data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Email field
              TextField(
                controller: Email,
                decoration: InputDecoration(
                  hintText: 'Email',
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: Password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Log In button with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    String email = Email.text.trim();
                    String password = Password.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
                        const SnackBar(
                            content: Text("⚠️ Please enter email & password")),
=======
                        const SnackBar(content: Text("⚠️ Please enter email & password")),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                      );
                      return;
                    }

                    Map<String, dynamic>? userData =
<<<<<<< HEAD
                        await MongoDataBase.loginUser(email, password);
=======
                    await MongoDataBase.loginUser(email, password);
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

                    if (userData != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Login successful")),
                      );
                      // ✅ Login successful → Dashboard pe user info bhejna
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard1(
<<<<<<< HEAD
                            userData: userData, // pura user data pass kar diya
=======
                            userEmail: userData["email"], // DB se aya email
                            userData: userData,           // pura user data pass kar diya
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
                        const SnackBar(
                            content: Text("❌ Invalid email or password")),
=======
                        const SnackBar(content: Text("❌ Invalid email or password")),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // 👈 Spacer ki jagah safe space
            ],
          ),
        ),
      ),
    );
  }
}
