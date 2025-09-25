import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class UploadDocument extends StatefulWidget {
  final String userId;

  const UploadDocument({
    super.key,
    required this.userId,
  });

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  File? _selectedFile;
  String? _selectedCategory;
  DateTime? _selectedDate;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isUploading = false;

  /// File picker
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  /// Camera capture
  Future<void> _pickFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedFile = File(photo.path);
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
    if (_selectedFile == null ||
        _titleController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Fill all fields and select a file")),
      );
      return;
    }

    setState(() => _isUploading = true);

    final doc = await ApiService.uploadDocument(
      file: _selectedFile!,
      title: _titleController.text,
      category:
          _selectedCategory == "Reports" ? "Lab Report" : _selectedCategory!,
      notes: _notesController.text,
      date: _selectedDate?.toIso8601String(),
    );

    setState(() => _isUploading = false);

    if (doc != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Upload failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Document")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.title, color: Colors.blue),
                  labelText: "Document Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category, color: Colors.blue),
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  "Report",
                  "Prescription",
                  "Bill",
                  "Insurance",
                ]
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 12),
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
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: Colors.blue),
                      labelText: "Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.notes, color: Colors.blue),
                  labelText: "Notes (optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.blue),
                      onPressed: _pickFile,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: _pickFromCamera,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : "No file selected / photo captured",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload, color: Colors.blue),
                  label: _isUploading
                      ? const Text(
                          "Uploading...",
                          style: TextStyle(color: Colors.blue),
                        )
                      : const Text(
                          "Upload Document",
                          style: TextStyle(color: Colors.blue),
                        ),
                  onPressed: _isUploading ? null : _uploadDocument,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
