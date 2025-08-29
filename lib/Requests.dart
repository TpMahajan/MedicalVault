import 'package:flutter/material.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  final List<Map<String, String>> doctors = const [
    {
      "name": "Dr. Shakshant Patil",
      "clinic": "Clinic A",
      "city": "Nashik",
      "experience": "32 years",
      "speciality": "Cardiologist",
      "photoUrl": "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
    },
    {
      "name": "Dr. Rahul Pandey",
      "clinic": "Clinic B",
      "city": "Mumbai",
      "experience": "17 years",
      "speciality": "Dermatologist",
      "photoUrl": "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
    },
    {
      "name": "Dr. Sandesh Kulkarni",
      "clinic": "Clinic C",
      "city": "Nashik",
      "experience": "12 years",
      "speciality": "Orthopedic",
      "photoUrl": "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
    },
    {
      "name": "Dr. Jonathan Dsouza",
      "clinic": "Clinic D",
      "city": "Pune",
      "experience": "15 years",
      "speciality": "Eye_specialist",
      "photoUrl": "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Doctor Requests",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfilePage(doctor: doctor),
                ),
              );
            },
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(doctor["photoUrl"]!),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor["name"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor["clinic"]!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                doctor["city"]!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.circle,
                        color: Colors.green, size: 14), // Active indicator
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Doctor Profile Page
class DoctorProfilePage extends StatelessWidget {
  final Map<String, String> doctor;

  const DoctorProfilePage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor['name']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(doctor['photoUrl']!),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            Text(
              doctor['name']!,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              doctor['speciality']!,
              style: const TextStyle(
                  fontSize: 18, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading:
                    const Icon(Icons.location_on, color: Colors.blue),
                    title: const Text('City'),
                    subtitle: Text(doctor['city']!),
                  ),
                  const Divider(),
                  ListTile(
                    leading:
                    const Icon(Icons.local_hospital, color: Colors.red),
                    title: const Text('Clinic/Hospital'),
                    subtitle: Text(doctor['clinic']!),
                  ),
                  const Divider(),
                  ListTile(
                    leading:
                    const Icon(Icons.work, color: Colors.orange),
                    title: const Text('Experience'),
                    subtitle: Text(doctor['experience']!),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.medical_services,
                        color: Colors.green),
                    title: const Text('Speciality'),
                    subtitle: Text(doctor['speciality']!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Accept / Decline Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Accepted ${doctor['name']}")),
                    );
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Accept",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Declined ${doctor['name']}")),
                    );
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text("Decline",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
