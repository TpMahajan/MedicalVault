import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'MyVault.dart';
import 'document_model.dart';

class UploadDocument extends StatefulWidget {
  const UploadDocument({super.key});

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  File? _selectedFile;
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _saveDocument() {
    if (_selectedFile == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select file & category")),
      );
      return;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ),
          ],
        ),
      ),
    );
  }
}
