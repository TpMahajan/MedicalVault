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
  final String userId;

  const CategoryVaultPage({
    super.key,
    required this.category,
    required this.userId,
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
      final docs = await ApiService.fetchMyDocs(widget.userId);

      // ✅ Filter by normalizedType from model
      final filtered = docs.where((d) {
        switch (widget.category.toLowerCase()) {
          case "reports":
          case "report":
            return d.normalizedType == "report";
          case "prescriptions":
          case "prescription":
            return d.normalizedType == "prescription";
          case "bills":
          case "bill":
            return d.normalizedType == "bill";
          case "insurance":
          case "insurance details":
            return d.normalizedType == "insurance";
          default:
            return false;
        }
      }).toList();

      setState(() {
        files = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("⚠️ Error loading files: $e");
    }
  }

  // ---------------- OPEN FILE ----------------
  Future<void> _openFile(Document document) async {
    if (document.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid document")),
      );
      return;
    }

    final fileType = (document.fileType ?? "").toLowerCase();
    debugPrint("🔍 Opening file: ${document.fileName} ($fileType)");

    try {
      if (fileType.contains("pdf")) {
        final proxyUrl = "${ApiService.baseUrl}/files/${document.id}/proxy";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfPreviewPage(
              url: proxyUrl,
              title: document.title ?? document.fileName ?? 'PDF Preview',
            ),
          ),
        );
      } else if (fileType.startsWith("image/")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImagePreviewPage(
              url: document.url ?? "",
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

  // ---------------- DOWNLOAD & OPEN LOCALLY ----------------
  Future<void> _downloadAndOpenFile(Document document) async {
    if (document.id == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${document.fileName ?? "file"}';
      final url = '${ApiService.baseUrl}/files/${document.id}/download';

      // ✅ Add authentication headers
      final token = await ApiService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      await dio.download(url, filePath);
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint("❌ Download and open error: $e");
      rethrow;
    }
  }

  // ---------------- DOWNLOAD ONLY ----------------
  Future<void> _downloadFile(Document document) async {
    if (document.id == null) return;
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

      final downloadUrl = '${ApiService.baseUrl}/files/${document.id}/download';
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${document.fileName ?? "file"}';

      // ✅ Add authentication headers
      final token = await ApiService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

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

  // ---------------- DELETE ----------------
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

  // ---------------- THUMBNAIL ----------------
  Widget _buildThumbnail(Document document) {
    final fileType = (document.fileType ?? "").toLowerCase();
    if (fileType.startsWith("image/")) {
      return Image.network(
        document.url ?? "",
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey, size: 40),
      );
    } else if (fileType.contains("pdf")) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
    } else if (fileType.contains("word")) {
      return const Icon(Icons.description, color: Colors.blue, size: 40);
    }
    return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 40);
  }

  // ---------------- UI ----------------
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
