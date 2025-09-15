import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Document_model.dart';
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
  final Dio dio = Dio();

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
      setState(() {
        files = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("⚠️ Error loading files: $e");
    }
  }

  Future<void> _openFile(Document document) async {
    if (document.url == null || document.url!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL missing")),
      );
      return;
    }

    final ext = document.fileName?.split('.').last.toLowerCase() ?? '';
    debugPrint("🔍 Opening file: ${document.fileName} ($ext)");

    try {
      if (ext == 'pdf') {
        // ✅ Always use backend proxy for PDFs
        final proxyUrl = "${ApiService.baseUrl}/proxy/${document.id}";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfPreviewPage(
              url: proxyUrl,
              title: document.title ?? document.fileName ?? 'PDF Preview',
            ),
          ),
        );
      } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImagePreviewPage(
              url: document.url!,
              title: document.title ?? 'Image Preview',
            ),
          ),
        );
      } else {
        await _downloadAndOpenFile(document);
      }
    } catch (e) {
      debugPrint("❌ Preview error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open file: $e")),
      );
    }
  }

  Future<void> _downloadAndOpenFile(Document document) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${document.fileName}';
      await dio.download(document.url!, filePath);
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint("❌ Download and open error: $e");
      rethrow;
    }
  }

  Future<void> _downloadFile(Document document) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission required")),
          );
          return;
        }
      }

      // ✅ Always use backend download endpoint
      final downloadUrl = '${ApiService.baseUrl}/download/${document.id}';
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${document.fileName}';

      await dio.download(downloadUrl, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Downloaded to $filePath")),
      );
    } catch (e) {
      debugPrint("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  Future<void> _deleteFile(Document document) async {
    if (document.id == null) return;

    final success = await ApiService.deleteDocument(document.id!);
    if (success) {
      setState(() => files.remove(document));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Document deleted")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to delete document")),
      );
    }
  }

  Widget _buildThumbnail(Document document) {
    final ext = document.fileName?.split('.').last.toLowerCase() ?? '';
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Image.network(
        document.url!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.grey, size: 40),
      );
    } else if (ext == 'pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
    } else if (['doc', 'docx'].contains(ext)) {
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFiles),
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
              title: Text(file.title ?? "Untitled"),
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
                    icon: const Icon(Icons.download,
                        color: Colors.green),
                    onPressed: () => _downloadFile(file),
                    tooltip: "Download",
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

// ---------------- PDF Preview Page ----------------
class PdfPreviewPage extends StatelessWidget {
  final String url;
  final String title;

  const PdfPreviewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.network(
        url,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
      ),
    );
  }
}

// ---------------- Image Preview Page ----------------
class ImagePreviewPage extends StatelessWidget {
  final String url;
  final String title;

  const ImagePreviewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
