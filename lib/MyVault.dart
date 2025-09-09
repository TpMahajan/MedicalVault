import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Document_model.dart';
import 'UploadDocument.dart';
import 'api_service.dart';

// ================= DOCUMENT DETAIL PAGE =================
class DocumentDetailPage extends StatelessWidget {
  final Document document;

  const DocumentDetailPage({super.key, required this.document});

  /// 🔹 Preview = open Cloudinary URL in browser/PDF viewer
  Future<void> _previewFile(BuildContext context) async {
    final url = document.url;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL is missing")),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not preview file")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error previewing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  /// 🔹 Download Cloudinary file to device
  Future<void> _downloadFile(BuildContext context) async {
    try {
      final url = document.url;
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File URL missing")),
        );
        return;
      }

      // 📂 Request storage permission
      if (Platform.isAndroid) {
        if (!await Permission.storage.request().isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")),
          );
          return;
        }
      }

      // 📂 Save to downloads/documents directory
      final dir = Directory('/storage/emulated/0/Download');
      final fileName = "${document.title ?? "document"}.pdf";
      final savePath = "${dir.path}/$fileName";

      Dio dio = Dio();
      await dio.download(url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ File downloaded: $savePath")),
      );
    } catch (e) {
      debugPrint("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.title ?? "Untitled")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${document.category ?? 'Unknown'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Uploaded on: ${document.date ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (document.url != null && document.url!.isNotEmpty) ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _previewFile(context),
                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white),
                    label: const Text("Preview"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _downloadFile(context),
                    icon: const Icon(Icons.download, color: Colors.blue),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white),
                    label: const Text("Download"),
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

  static final List<Document> _allDocuments = [];

  static void addDocument(Document doc) => _allDocuments.add(doc);
  static void removeDocument(String docId) =>
      _allDocuments.removeWhere((doc) => doc.id == docId);

  @override
  State<MyVault> createState() => _MyVaultState();
}

class _MyVaultState extends State<MyVault> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final List<String> _categories = [
    "All",
    "Bills",
    "Prescription",
    "Reports",
    "Insurance"
  ];
  String _selectedCategory = "All";

  String _selectedSort = "Today"; // ✅ Default
  final List<String> _sortOptions = [
    "Today",
    "Last 2 days",
    "Last 7 days",
    "Last 30 days"
  ];

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
      for (var category in _categories.where((c) => c != "All")) {
        final docs = await ApiService.fetchDocuments(
          category: category,
          userEmail: widget.userEmail,
        );

        // ⚡ Yahan ab 'docs' is already List<Document>
        for (final doc in docs) {
          MyVault.addDocument(doc);
        }
      }
    } catch (e) {
      debugPrint("Error loading documents: $e");
    }

    setState(() => _isLoading = false);
  }


  List<Document> _filterAndSortDocuments() {
    final query = _searchController.text.toLowerCase();
    final now = DateTime.now();

    var docs = _selectedCategory == "All"
        ? MyVault._allDocuments
        : MyVault._allDocuments
        .where((doc) =>
    (doc.category ?? '').toLowerCase() ==
        _selectedCategory.toLowerCase())
        .toList();

    // 🔍 Apply search
    docs = docs
        .where((doc) => (doc.title ?? '').toLowerCase().contains(query))
        .toList();

    // ⏳ Day-based filter
    docs = docs.where((doc) {
      try {
        if (doc.date == null) return false;
        final docDate = DateTime.tryParse(doc.date!);
        if (docDate == null) return false;

        final difference = now.difference(docDate).inDays;

        switch (_selectedSort) {
          case "Today":
            return difference == 0;
          case "Last 2 days":
            return difference <= 1;
          case "Last 7 days":
            return difference <= 7;
          case "Last 30 days":
            return difference <= 30;
          default:
            return true;
        }
      } catch (e) {
        return false;
      }
    }).toList();

    // Always sort by latest date first
    docs.sort((a, b) {
      final dateA = DateTime.tryParse(a.date ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.date ?? '') ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    return docs;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open file")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = _filterAndSortDocuments();

    return Scaffold(
      body: Column(
        children: [
          // 🔍 Search Bar
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

          // 🏷️ Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // ⏳ Sort Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sort",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 160,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSort,
                    items: _sortOptions
                        .map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSort = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 📂 Documents List
          Expanded(
            child: _isLoading
                ? Center(
              child: Lottie.asset(
                'assets/LoadingClock.json',
                width: 100,
                height: 100,
              ),
            )
                : docs.isEmpty
                ? const Center(child: Text("No documents found"))
                : ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file,
                        color: Colors.blue),
                    title: Text(doc.title ?? "Untitled"),
                    subtitle:
                    Text("${doc.category} • ${doc.date}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye,
                              color: Colors.green),
                          onPressed: () async {
                            if (doc.url != null) {
                              await _openUrl(doc.url!);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () async {
                            final success =
                            await ApiService.deleteDocument(
                                doc.id!);
                            if (success) {
                              setState(() {
                                MyVault.removeDocument(doc.id!);
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                  content:
                                  Text("File deleted")));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 📤 Upload Button
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF42A5F5),
                    Color(0xFF26C6DA),
                    Color(0xFF80DEEA)
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
                      builder: (context) => UploadDocument(
                        userId: widget.userId,
                        userEmail: widget.userEmail,
                      ),
                    ),
                  );
                  _loadDocumentsFromAPI();
                },
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Upload Document',
                    style: TextStyle(color: Colors.white)),
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
