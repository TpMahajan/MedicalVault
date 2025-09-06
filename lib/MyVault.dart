import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'UploadDocument.dart';
import 'Document_model.dart';
import 'api_service.dart';

// ================= DOCUMENT DETAIL PAGE =================
class DocumentDetailPage extends StatelessWidget {
  final Document document;

  const DocumentDetailPage({super.key, required this.document});

  Future<void> _deleteFile(BuildContext context) async {
    if (document.id == null) return;

    final success = await ApiService.deleteDocument(document.id!);
    if (success) {
      MyVault.removeDocument(document.id!); // remove locally
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("File deleted")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete file from server")));
    }
  }

  Future<void> _previewFile(BuildContext context) async {
    if (document.path == null) return;
    await ApiService.previewDocument(document);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${document.category}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Uploaded on: ${document.date}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (document.path != null) ...[
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
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

// ================= MY VAULT =================
class MyVault extends StatefulWidget {
  final String userEmail;
  final String userId;

  const MyVault({super.key, required this.userEmail, required this.userId});

  // ✅ Static lists and methods for global access
  static final List<Document> _allDocuments = [];

  static void addDocument(Document doc) {
    _allDocuments.add(doc);
  }

  static void removeDocument(String docId) {
    _allDocuments.removeWhere((doc) => doc.id == docId);
  }

  static List<Document> getDocumentsByCategory(String category) {
    return _allDocuments
        .where((doc) => doc.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  State<MyVault> createState() => _MyVaultState();
}

class _MyVaultState extends State<MyVault> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final List<String> _categories = ["Bills", "Prescription", "Reports", "Insurance"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadDocumentsFromAPI();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocumentsFromAPI() async {
    setState(() => _isLoading = true);
    MyVault._allDocuments.clear();

    try {
      for (var category in _categories) {
        final docs = await ApiService.fetchDocuments(
            category: category, userEmail: widget.userEmail);
        for (final doc in docs) {
          final document = Document.fromApi(doc);
          MyVault.addDocument(document);
        }
      }
    } catch (e) {
      print("Error loading documents: $e");
    }

    setState(() => _isLoading = false);
  }

  Widget _buildSection(String title) {
    final query = _searchController.text.toLowerCase();
    final docs = MyVault.getDocumentsByCategory(title)
        .where((doc) => doc.title.toLowerCase().contains(query))
        .toList();

    if (docs.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          ...docs.map((doc) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentDetailPage(document: doc),
                      ),
                    );
                    _loadDocumentsFromAPI();
                  },
                  child: Row(
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
                      const Icon(Icons.description,
                          color: Colors.grey, size: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => ApiService.previewDocument(doc),
                      icon: const Icon(Icons.preview, color: Colors.blue),
                      label: const Text("Preview"),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        if (doc.id == null) return;
                        final success = await ApiService.deleteDocument(doc.id!);
                        if (success) {
                          setState(() {
                            MyVault.removeDocument(doc.id!);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("File deleted")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Failed to delete file")));
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
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
              children: _categories.map((cat) => _buildSection(cat)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF26C6DA), Color(0xFF80DEEA)],
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
                      builder: (context) => UploadDocument(
                        userId: widget.userId,
                        userEmail: widget.userEmail,
                      ),
                    ),
                  );
                  _loadDocumentsFromAPI();
                },
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Upload Document', style: TextStyle(color: Colors.white)),
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
