import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'Document_model.dart';
import 'package:open_file/open_file.dart';
import 'api_service.dart';

class CategoryVaultPage extends StatefulWidget {
  final String category;
  final String userEmail;

  const CategoryVaultPage({
    super.key,
    required this.category,
    required this.userEmail,
  });

  @override
  State<CategoryVaultPage> createState() => _CategoryVaultPageState();
}

class _CategoryVaultPageState extends State<CategoryVaultPage> {
  List<Document> files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final docs = await ApiService.fetchDocuments(
        category: widget.category,
        userEmail: widget.userEmail,
      );

      // Convert List<Map<String,dynamic>> to List<Document>
      final docList = docs.map((docMap) => Document.fromApi(docMap)).toList();

      setState(() {
        files = docList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("⚠️ Error loading files: $e");
    }
  }

  Future<void> _openFile(Document document) async {
    if (document.path == null || document.path!.isEmpty) return;

    // ✅ Pass String file URL
    await ApiService.previewDocument(document.path!);
  }

  Future<void> _deleteFile(Document document) async {
    if (document.id == null) return;

    // ✅ Pass String docId
    final success = await ApiService.deleteDocument(document.id!);
    if (success) {
      setState(() => files.remove(document));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("✅ Document deleted")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ Failed to delete document")));
    }
  }

  Widget _buildThumbnail(Document document) {
    final title = document.title.toLowerCase();
    if (title.endsWith(".png") || title.endsWith(".jpg") || title.endsWith(".jpeg")) {
      return const Icon(Icons.image, color: Colors.green, size: 40);
    } else if (title.endsWith(".pdf")) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
    } else if (title.endsWith(".doc") || title.endsWith(".docx")) {
      return const Icon(Icons.description, color: Colors.blue, size: 40);
    }
    return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Lottie.asset(
          "assets/LoadingClock.json",
          width: 100,
          height: 100,
        ),
      )
          : files.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No documents uploaded yet",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text("Upload documents to see them here",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _buildThumbnail(file),
              title: Text(file.title),
              subtitle: Text(
                'Uploaded: ${file.date ?? ''}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye,
                        color: Colors.blue),
                    onPressed: () => _openFile(file),
                    tooltip: "Preview",
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFile(file),
                    tooltip: "Delete",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
