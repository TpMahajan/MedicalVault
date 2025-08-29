import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class CategoryVaultPage extends StatefulWidget {
  final String category; // Reports, Prescriptions, Bills, Insurance

  const CategoryVaultPage({super.key, required this.category});

  @override
  State<CategoryVaultPage> createState() => _CategoryVaultPageState();
}

class _CategoryVaultPageState extends State<CategoryVaultPage> {
  List<Map<String, dynamic>> files = []; // 👈 load from DB or storage

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    // 🔥 Replace with MongoDB/Local DB fetch filtering by category
    // Example structure: { 'name': 'report1.pdf', 'path': '/storage/emulated/...', 'category': 'Reports' }

    // Dummy Example:
    setState(() {
      files = [
        {'name': 'Blood_Test_Report.pdf', 'path': '/storage/reports/blood.pdf', 'category': 'Reports'},
        {'name': 'Xray.png', 'path': '/storage/reports/xray.png', 'category': 'Reports'},
      ].where((file) => file['category'] == widget.category).toList();
    });
  }

  void _deleteFile(int index) {
    // Delete from DB/local storage also
    setState(() {
      files.removeAt(index);
    });
  }

  void _openFile(String path) {
    OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: files.isEmpty
          ? const Center(child: Text("No documents uploaded yet"))
          : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: Text(file['name']),
              onTap: () => _openFile(file['path']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteFile(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
