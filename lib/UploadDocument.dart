import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dbHelper/mongodb.dart'; // ✅ use your MongoDB helper

class UploadDocument extends StatefulWidget {
  final String userEmail;
  const UploadDocument({super.key, required this.userEmail});

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  File? _selectedFile;
  Uint8List? _fileBytes;
  String? _selectedCategory;
  DateTime? _selectedDate;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileBytes =
            result.files.single.bytes ?? _selectedFile!.readAsBytesSync();
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select file & category")),
      );
      return;
    }

    setState(() => _isUploading = true);

    final fileName = _titleController.text.isNotEmpty
        ? _titleController.text
        : _selectedFile!.path.split('/').last;

    final category = _selectedCategory!;
    final date = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    final notes = _notesController.text;
    final fileType = _selectedFile!.path.split('.').last;

    try {
      // ✅ MongoDB save
      await MongoDataBase.uploadDocument(
        widget.userEmail,
        fileName,
        fileType,
        category,
        _fileBytes!,
        title: fileName,
        notes: notes,
        date: date,
      );

      // ✅ Document metadata banake MyVault me bhej do
      final newDoc = {
        "title": fileName,
        "category": category,
        "date": date,
        "notes": notes,
        "path": _selectedFile!.path, // local preview ke liye
        "fileType": fileType,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Document uploaded successfully!")),
      );

      Navigator.pop(context, newDoc); // 👈 return document data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error uploading document: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Document")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.title),
                labelText: "Document Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category),
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ["Reports", "Prescription", "Bills", "Insurance"]
                  .map((cat) =>
                  DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 12),

            // Date
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : "",
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today),
                    labelText: "Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.notes),
                labelText: "Notes (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // File picker
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.blue),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: Text(
                    _selectedFile != null
                        ? _selectedFile!.path.split('/').last
                        : "No file selected",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: _isUploading
                    ? const Text("Uploading...")
                    : const Text("Upload Document"),
                onPressed: _isUploading ? null : _uploadDocument,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
