import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'Document_model.dart';

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
  List<Map<String, dynamic>> files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// ================= Load Documents by Category =================
  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);

    try {
      final docs = await ApiService.fetchDocuments(
        category: widget.category,
        userEmail: widget.userEmail,
      );

      setState(() {
        files = docs.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("⚠️ Error loading files: $e");
    }
  }

  /// ================= Open / Preview File =================
  Future<void> _openFile(Map<String, dynamic> file) async {
    try {
      final fileUrl = file['url'];
      if (fileUrl == null || fileUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ File URL is missing")),
        );
        return;
      }

      final fullUrl = fileUrl.startsWith("http")
          ? fileUrl
          : "http://192.168.31.166:5000$fileUrl"; // 👈 Server ka base URL lagao

      final uri = Uri.parse(fullUrl);
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final dir = await getTemporaryDirectory();
        final path = "${dir.path}/${file['fileName']}";
        final tempFile = File(path);
        await tempFile.writeAsBytes(bytes, flush: true);
        await OpenFile.open(tempFile.path);
      } else {
        print("❌ Failed to fetch file: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to fetch file: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("⚠️ Error opening file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error opening file: $e")),
      );
    }
  }




  /// ================= Delete Document =================
  Future<void> _deleteFile(Map<String, dynamic> file) async {
    try {
      // Use the correct "id" field sent from backend
      final docId = file["id"];
      if (docId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Document ID is missing")),
        );
        return;
      }

      print("Deleting document with id: $docId"); // debug

      final success = await ApiService.deleteDocument(docId.toString());
      if (success) {
        setState(() {
          files.removeWhere((f) => f["id"] == docId);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("✅ Document deleted")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("❌ Failed to delete document")));
      }
    } catch (e) {
      print("⚠️ Error deleting file: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error deleting file: $e")));
    }
  }

  /// ================= Thumbnail Builder =================
  Widget _buildThumbnail(Map<String, dynamic> file) {
    final type = file['fileType']?.toString().toLowerCase() ?? "";
    if (type.contains("image")) {
      try {
        List<int> fileBytes = List<int>.from(file["fileBytes"] ?? []);
        if (fileBytes.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              fileBytes as Uint8List,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (_) {
        return const Icon(Icons.image, color: Colors.green, size: 32);
      }
    } else if (type.contains("pdf")) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
    } else if (type.contains("doc")) {
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
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _buildThumbnail(file),
              title: Text(file['fileName']),
              subtitle: Text(
                'Uploaded: ${file['uploadedAt'] ?? ''}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                    onPressed: () => _openFile(file),
                    tooltip: "Preview",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
