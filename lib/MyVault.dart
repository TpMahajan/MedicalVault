import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'UploadDocument.dart';
import 'document_model.dart';
import 'dbHelper/mongodb.dart';

// Base URL for your API server (adjust if your actual endpoint structure is different)
const String baseUrl = 'http://localhost:5000';

// ================= DOCUMENT DETAIL PAGE =================
class DocumentDetailPage extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String? path;
  final String userEmail; // Added to allow deleting from DB

  const DocumentDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    this.path,
    required this.userEmail,
  });

  // ✅ Delete function (updated to delete from DB via MongoDataBase/API, no local file delete since files are on server)
  Future<void> _deleteFile(BuildContext context) async {
    if (path == null) return;

    try {
      // Delete from DB (assuming MongoDataBase.deleteDocument handles server-side deletion, including the file)
      final success = await MongoDataBase.deleteDocument(userEmail, title);

      if (success) {
        // Remove from local static list
        MyVault.removeDocument(path!);

        Navigator.pop(context, true); // Return to refresh vault
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File deleted")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete file from server")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting file: $e")));
    }
  }

  // ✅ Preview function (updated to handle remote URLs from server)
  Future<void> _previewFile(BuildContext context) async {
    if (path == null) return;

    final isRemote = path!.startsWith('http');

    File? file;
    String? localPath = path;

    if (!isRemote) {
      file = File(path!);
      if (!(await file.exists())) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File does not exist")));
        return;
      }
    }

    final ext = path!.split('.').last.toLowerCase();

    if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(ext)) {
      // Open fullscreen image (use network for remote, file for local)
      Widget imageWidget = isRemote ? Image.network(path!) : Image.file(file!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("Image Preview")),
            body: Center(child: imageWidget),
          ),
        ),
      );
    } else {
      // For non-images like PDF, download if remote, then open
      if (isRemote) {
        try {
          localPath = await _downloadFile(path!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error downloading file: $e")));
          return;
        }
      }

      final result = await OpenFile.open(localPath!);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot open file: ${result.message}")));
      }
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
              Text("File path: $path", style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

// ✅ Download helper for remote files
Future<String> _downloadFile(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final dir = await getTemporaryDirectory();
    final filename = url.split('/').last;
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } else {
    throw Exception('Failed to download file: ${response.statusCode}');
  }
}

// ✅ Thumbnail builder (updated to handle remote URLs)
Widget _buildFileThumbnail(String path) {
  final ext = path.split('.').last.toLowerCase();
  final isRemote = path.startsWith('http');

  if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(ext)) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isRemote
          ? Image.network(
        path,
        fit: BoxFit.cover,
        height: 100,
        width: 100,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 80),
      )
          : Image.file(
        File(path),
        fit: BoxFit.cover,
        height: 100,
        width: 100,
      ),
    );
  } else if (ext == "pdf") {
    return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80);
  } else {
    return const Icon(Icons.insert_drive_file, color: Colors.blue, size: 80);
  }
}

// ================= MY VAULT =================
class MyVault extends StatefulWidget {
  final String userEmail;

  const MyVault({super.key, required this.userEmail});

  // ✅ Static storage (unchanged)
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

  static void removeDocument(String path) {
    _bills.removeWhere((doc) => doc.path == path);
    _prescriptions.removeWhere((doc) => doc.path == path);
    _reports.removeWhere((doc) => doc.path == path);
    _insurance.removeWhere((doc) => doc.path == path);
  }

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

  // ✅ Load documents from MongoDB (updated to construct full URL for path BEFORE creating Document, assuming 'path' in DB is filename and server serves at /files/{filename})
  // If your server endpoint for files is different (e.g., /api/download/{id}), adjust the URL construction accordingly.
  Future<void> _loadDocumentsFromMongoDB() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Clear existing documents
      MyVault.clearAllDocuments();

      // Fetch all documents for the user (assuming MongoDataBase.getUserDocuments fetches from your API server)
      final documents = await MongoDataBase.getUserDocuments(widget.userEmail);

      // Add documents to appropriate categories, constructing full URL for path
      for (final docMap in documents) {
        // Make a copy of the map to modify
        final map = Map<String, dynamic>.from(docMap);

        if (map['path'] != null && !(map['path'] as String).startsWith('http')) {
          map['path'] = '$baseUrl/files/${map['path']}'; // Adjust '/files/' to match your server's file-serving route
        }

        final document = Document.fromMap(map);
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

  // ✅ Preview function for list (updated to handle remote URLs)
  Future<void> _previewFile(BuildContext context, String? path) async {
    if (path == null) return;

    final isRemote = path.startsWith('http');

    File? file;
    String? localPath = path;

    if (!isRemote) {
      file = File(path);
      if (!(await file.exists())) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File does not exist")));
        return;
      }
    }

    final ext = path.split('.').last.toLowerCase();

    if (["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(ext)) {
      Widget imageWidget = isRemote ? Image.network(path) : Image.file(file!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("Image Preview")),
            body: Center(child: imageWidget),
          ),
        ),
      );
    } else {
      if (isRemote) {
        try {
          localPath = await _downloadFile(path);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error downloading file: $e")));
          return;
        }
      }

      final result = await OpenFile.open(localPath!);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot open file: ${result.message}")));
      }
    }
  }

  // 🔹 Section Widget (updated to optionally navigate to detail page; currently keeps your buttons, but consider using onTap for detail)
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          ...filteredDocs.map((doc) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Optional: Navigate to detail page instead of inline buttons for better UX
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentDetailPage(
                          title: doc.title,
                          category: doc.category,
                          date: doc.date,
                          path: doc.path,
                          userEmail: widget.userEmail,
                        ),
                      ),
                    ).then((refresh) {
                      if (refresh == true) _loadDocumentsFromMongoDB();
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.category, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                            Text(doc.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Uploaded on ${doc.date}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                        child: doc.path?.isNotEmpty ?? false
                            ? _buildFileThumbnail(doc.path!)
                            : const Icon(Icons.description, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ Buttons under each doc (kept, but consider removing if using detail page onTap)
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _previewFile(context, doc.path),
                      icon: const Icon(Icons.preview, color: Colors.blue),
                      label: const Text("Preview"),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        // Delete from MongoDB/API
                        final success = await MongoDataBase.deleteDocument(
                          widget.userEmail,
                          doc.title,
                        );

                        if (success) {
                          setState(() {
                            MyVault.removeDocument(doc.path ?? '');
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("File deleted")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to delete file")),
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
                ? Center(
              child: Lottie.asset(
                'assets/LoadingClock.json',
                width: 100,
                height: 100,
              ),
            )
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF42A5F5), // Light Blue
                    Color(0xFF26C6DA), // Cyan
                    Color(0xFF80DEEA), // Light Teal
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadDocument(userEmail: widget.userEmail),
                    ),
                  );
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