import 'package:flutter/material.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

  Widget _buildFAQ(String question, String answer, bool initiallyExpanded,
      BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'FAQs',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFAQ(
            'How to upload my medical documents?',
            'To upload your medical documents, navigate to the \'Documents\' section in the app. Tap the \'Upload\' button and select the files from your device. Ensure they are in the accepted format and within the size limit.',
            false,
            context,
          ),
          _buildFAQ(
            'What are the accepted file formats?',
            'We accept PDF, JPEG, PNG, and DOCX formats.',
            false,
            context,
          ),
          _buildFAQ(
            'Is there a size limit for uploads?',
            'Yes, each file must be under 10MB.',
            false,
            context,
          ),
          _buildFAQ(
            'Can I upload multiple documents at once?',
            'Yes, you can select multiple files in one upload session.',
            false,
            context,
          ),
          _buildFAQ(
            'How do I know if my documents were successfully uploaded?',
            'You will receive a confirmation notification, and the documents will appear in your \'Documents\' section.',
            false,
            context,
          ),
        ],
      ),
    );
  }
}
