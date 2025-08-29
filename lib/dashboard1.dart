import 'package:flutter/material.dart';

import 'AppFooter.dart';
import 'CategoryVaultPage.dart';
import 'MyVault.dart';
import 'QR.dart';
import 'Requests.dart';
import 'Settings.dart';

class Dashboard1 extends StatefulWidget {
  final Map<String, dynamic> userData; // 👈 MongoDB login/signup data

  const Dashboard1({super.key, required this.userData, required userEmail});

  @override
  State<Dashboard1> createState() => _Dashboard1State();
}

class _Dashboard1State extends State<Dashboard1> {
  String appbarTitle = "Dashboard";
  int _currentIndex = 0;
  final tabs = ["Dashboard", "My Vault", "QR", "Requests", "Settings"];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userData['name'] ?? "Patient";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(appbarTitle, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            appbarTitle = tabs[index];
            _currentIndex = index;
          });
        },
        children: [
          // 🏠 Dashboard tab
          ListView(
            padding: const EdgeInsets.all(30.0),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/9203/9203764.png'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hello, $userName 👋',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.qr_code, color: Colors.black),
                ),
                title: const Text('Generate / Share QR'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRPage()),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.list_alt, color: Colors.black),
                ),
                title: const Text('Access Requests'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestsPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'My Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 📂 Category Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard(
                    context,
                    title: "Reports",
                    imagePath: "assets/Reports.png",
                    category: "Reports",
                  ),
                  _buildCategoryCard(
                    context,
                    title: "Prescriptions",
                    imagePath: "assets/Prescription.png",
                    category: "Prescription",
                  ),
                  _buildCategoryCard(
                    context,
                    title: "Bills",
                    imagePath: "assets/2851468.png",
                    category: "Bills",
                  ),
                  _buildCategoryCard(
                    context,
                    title: "Insurance Details",
                    imagePath: "assets/Insurance12.png",
                    category: "Insurance",
                  ),
                ],
              ),
            ],
          ),

          // 🔐 Vault tab
          MyVault(),

          // QR tab
          QRPage(),

          // Requests tab
          RequestsPage(),

          // Settings tab
          SettingsPage(),
        ],
      ),

      // ⬇️ Bottom Navbar + Footer
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lock),
                label: 'Vault',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code),
                label: 'QR',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  /// 🔹 Reusable card builder
  Widget _buildCategoryCard(BuildContext context,
      {required String title,
        required String imagePath,
        required String category}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryVaultPage(category: category),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}
