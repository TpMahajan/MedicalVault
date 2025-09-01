import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dbHelper/mongodb.dart';

class CategoryVaultPage extends StatefulWidget {
  final String category; // Reports, Prescriptions, Bills, Insurance
  final String userEmail; // Add user email parameter

  const CategoryVaultPage(
      {super.key, required this.category, required this.userEmail});

  @override
  State<CategoryVaultPage> createState() => _CategoryVaultPageState();
}

class _CategoryVaultPageState extends State<CategoryVaultPage> {
  List<Map<String, dynamic>> files = []; // Documents from MongoDB
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch documents from MongoDB by category
      final documents = await MongoDataBase.getUserDocumentsByCategory(
        widget.userEmail,
        widget.category,
      );

      setState(() {
        files = documents;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading files: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFile(int index) async {
    try {
      final file = files[index];
      final fileName = file['fileName'];

      // Delete from MongoDB
      final success =
          await MongoDataBase.deleteDocument(widget.userEmail, fileName);

      if (success) {
        // Remove from local list
        setState(() {
          files.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Document deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete document")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting document: $e")),
      );
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No documents uploaded yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        "Upload documents to see them here",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: _buildFileIcon(file['fileType']),
                        title: Text(
                          file['fileName'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Uploaded: ${_formatDate(file['uploadedAt'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => _openFile(file['fileName']),
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

  Widget _buildFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.green, size: 32);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue, size: 32);
      default:
        return const Icon(Icons.insert_drive_file,
            color: Colors.grey, size: 32);
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
