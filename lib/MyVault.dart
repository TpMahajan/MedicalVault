import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'UploadDocument.dart';
import 'document_model.dart';
import 'dbHelper/mongodb.dart';

// ================= DOCUMENT DETAIL PAGE =================
class DocumentDetailPage extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String? path;

  const DocumentDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    this.path,
  });

  // ✅ Delete function
  Future<void> _deleteFile(BuildContext context) async {
    if (path == null) return;

    try {
      final file = File(path!);
      if (await file.exists()) {
        await file.delete();
      }

      // remove from MyVault
      MyVault.removeDocument(path!);

      Navigator.pop(context, true); // return to refresh vault
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("File deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting file: $e")),
      );
    }
  }

  // ✅ Preview function
  Future<void> _previewFile(BuildContext context) async {
    if (path == null) return;

    final file = File(path!);
    if (await file.exists()) {
      final ext = path!.split('.').last.toLowerCase();

      if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(ext)) {
        // Open fullscreen image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text("Image Preview")),
              body: Center(child: Image.file(file)),
            ),
          ),
        );
      } else {
        // Open PDFs & others externally
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cannot open file: ${result.message}")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File does not exist")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: $category", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Uploaded on: $date", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (path != null) ...[
              const Text("Preview:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              _buildFileThumbnail(path!),
              const SizedBox(height: 20),
              Text("File path: $path",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _previewFile(context),
                    icon: const Icon(Icons.preview),
                    label: const Text("Preview"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _deleteFile(context),
                    icon: const Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    label: const Text("Delete"),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ✅ Thumbnail builder
Widget _buildFileThumbnail(String path) {
  final ext = path.split('.').last.toLowerCase();

  if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(ext)) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(File(path), fit: BoxFit.cover, height: 100, width: 100),
    );
  } else if (ext == "pdf") {
    return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80);
  } else {
    return const Icon(Icons.insert_drive_file, color: Colors.blue, size: 80);
  }
}

// ================= MY VAULT =================
class MyVault extends StatefulWidget {
  final String userEmail; // Add user email parameter

  const MyVault({super.key, required this.userEmail});

  // ✅ Static storage
  static final List<Document> _bills = [];
  static final List<Document> _prescriptions = [];
  static final List<Document> _reports = [];
  static final List<Document> _insurance = [];

  static void addDocument(Document doc) {
    if (doc.category == "Bills") {
      _bills.add(doc);
    } else if (doc.category == "Prescription") {
      _prescriptions.add(doc);
    } else if (doc.category == "Reports") {
      _reports.add(doc);
    } else if (doc.category == "Insurance") {
      _insurance.add(doc);
    }
  }

  // ✅ Remove method
  static void removeDocument(String path) {
    _bills.removeWhere((doc) => doc.path == path);
    _prescriptions.removeWhere((doc) => doc.path == path);
    _reports.removeWhere((doc) => doc.path == path);
    _insurance.removeWhere((doc) => doc.path == path);
  }

  // ✅ Clear all documents
  static void clearAllDocuments() {
    _bills.clear();
    _prescriptions.clear();
    _reports.clear();
    _insurance.clear();
  }

  @override
  State<MyVault> createState() => _MyVaultState();
}

class _MyVaultState extends State<MyVault> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadDocumentsFromMongoDB();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Load documents from MongoDB
  Future<void> _loadDocumentsFromMongoDB() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Clear existing documents
      MyVault.clearAllDocuments();

      // Fetch all documents for the user
      final documents = await MongoDataBase.getUserDocuments(widget.userEmail);

      // Add documents to appropriate categories
      for (final doc in documents) {
        final document = Document.fromMap(doc);
        MyVault.addDocument(document);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading documents: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Preview function for list
  Future<void> _previewFile(BuildContext context, String? path) async {
    if (path == null) return;

    final file = File(path);
    if (await file.exists()) {
      final ext = path.split('.').last.toLowerCase();

      if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(ext)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text("Image Preview")),
              body: Center(child: Image.file(file)),
            ),
          ),
        );
      } else {
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Cannot open file: ${result.message}")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File does not exist")),
      );
    }
  }

  // 🔹 Section Widget
  Widget _buildSection(String title, List<Document> docs) {
    final query = _searchController.text.toLowerCase();
    final filteredDocs = docs.where((doc) {
      return doc.title.toLowerCase().contains(query) ||
          doc.category.toLowerCase().contains(query);
    }).toList();

    if (filteredDocs.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          ...filteredDocs.map((doc) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.category,
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 12)),
                          Text(doc.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Uploaded on ${doc.date}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: doc.path.isNotEmpty
                          ? _buildFileThumbnail(doc.path)
                          : const Icon(Icons.description, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ✅ Buttons under each doc
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _previewFile(context, doc.path),
                      icon: const Icon(Icons.preview, color: Colors.blue),
                      label: const Text("Preview"),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        // Delete from MongoDB
                        final success = await MongoDataBase.deleteDocument(
                          widget.userEmail,
                          doc.title,
                        );

                        if (success) {
                          setState(() {
                            MyVault.removeDocument(doc.path);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("File deleted")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Failed to delete file")),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Delete"),
                    ),
                  ],
                ),
                const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                fillColor: const Color(0xFFE8F0FE),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Document sections
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              children: [
                _buildSection("Bills", MyVault._bills),
                _buildSection("Prescription", MyVault._prescriptions),
                _buildSection("Reports", MyVault._reports),
                _buildSection("Insurance", MyVault._insurance),
              ],
            ),
          ),

          // Upload Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UploadDocument(userEmail: widget.userEmail),
                    ),
                  );
                  // Refresh documents after upload
                  _loadDocumentsFromMongoDB();
                },
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text(
                  'Upload Document',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
