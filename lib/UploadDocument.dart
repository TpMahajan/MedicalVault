import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'MyVault.dart';
import 'document_model.dart';
<<<<<<< HEAD
import 'dbHelper/mongodb.dart';

class UploadDocument extends StatefulWidget {
  final String userEmail;

  const UploadDocument({super.key, required this.userEmail});
=======

class UploadDocument extends StatefulWidget {
  const UploadDocument({super.key});
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  File? _selectedFile;
  String? _selectedCategory;
<<<<<<< HEAD
  DateTime? _selectedDate;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isUploading = false;
=======
  final TextEditingController _titleController = TextEditingController();
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

<<<<<<< HEAD
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

  Future<void> _saveDocument() async {
=======
  void _saveDocument() {
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
    if (_selectedFile == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select file & category")),
      );
      return;
    }

<<<<<<< HEAD
    setState(() {
      _isUploading = true;
    });

    try {
      final fileBytes = await _selectedFile!.readAsBytes();
      final fileName = _titleController.text.isNotEmpty
          ? _titleController.text
          : _selectedFile!.path.split('/').last;
      final fileType = _selectedFile!.path.split('.').last.toLowerCase();
      final category = _selectedCategory!;
      final date =
      _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : DateFormat('yyyy-MM-dd').format(DateTime.now());

      await MongoDataBase.uploadDocument(
        widget.userEmail,
        fileName,
        fileType,
        category,
        fileBytes,
      );

      final newDoc = Document(
        title: fileName,
        date: date,
        path: _selectedFile!.path,
        category: category,
        userEmail: widget.userEmail,
      );

      MyVault.addDocument(newDoc);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Document uploaded successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error uploading document: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
=======
    final newDoc = Document(
      type: _selectedCategory!,
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : _selectedFile!.path.split('/').last,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      path: _selectedFile!.path,
    );

    MyVault.addDocument(newDoc);
    Navigator.pop(context);
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text("Upload Document"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Title
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
            const SizedBox(height: 15),

            // Category
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category),
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedCategory,
              items: ["Reports", "Prescription", "Bills", "Insurance"]
=======
      appBar: AppBar(title: const Text("Upload Document")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Document Title"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Category"),
              value: _selectedCategory,
              items: ["Bills", "Prescription", "Reports"]
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
<<<<<<< HEAD
            const SizedBox(height: 15),

            // Date
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today),
                    labelText: "Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : "",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

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
            const SizedBox(height: 15),

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

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: _isUploading
                    ? const Text("Uploading...")
                    : const Text("Save Document"),
                onPressed: _isUploading ? null : _saveDocument,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
=======
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Pick File"),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Selected: ${_selectedFile!.path.split('/').last}"),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveDocument,
              child: const Text("Save"),
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
            ),
          ],
        ),
      ),
    );
  }
}
