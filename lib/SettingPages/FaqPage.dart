import 'package:flutter/material.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

  Widget _buildFAQ(String question, String answer, bool initiallyExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA), // Light teal background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(color: Colors.black87, fontSize: 16.0),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.blue, fontSize: 14.0),
            ),
          ),
        ],
        initiallyExpanded: initiallyExpanded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('FAQs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFAQ(
            'How to upload my medical documents?',
            'To upload your medical documents, navigate to the \'Documents\' section in the app. Tap the \'Upload\' button and select the files from your device. Ensure they are in the accepted format and within the size limit.',
            false,
          ),
          _buildFAQ(
            'What are the accepted file formats?',
            'We accept PDF, JPEG, PNG, and DOCX formats.',
            false,
          ),
          _buildFAQ(
            'Is there a size limit for uploads?',
            'Yes, each file must be under 10MB.',
            false,
          ),
          _buildFAQ(
            'Can I upload multiple documents at once?',
            'Yes, you can select multiple files in one upload session.',
            false,
          ),
          _buildFAQ(
            'How do I know if my documents were successfully uploaded?',
            'You will receive a confirmation notification, and the documents will appear in your \'Documents\' section.',
            false,
          ),
        ],
      ),
    );
  }
}