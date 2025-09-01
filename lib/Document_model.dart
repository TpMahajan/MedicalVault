class Document {
<<<<<<< HEAD
  final String title;
  final String date;
  final String path; // File path
  final String category; // Document category
  final String userEmail; // User's email for MongoDB storage

  Document({
    required this.title,
    required this.date,
    required this.path,
    required this.category,
    required this.userEmail,
  });

  // Convert to Map for MongoDB
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'path': path,
      'category': category,
      'userEmail': userEmail,
      'uploadedAt': DateTime.now().toUtc(),
    };
  }

  // Create from MongoDB document
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      path: map['path'] ?? '',
      category: map['category'] ?? '',
      userEmail: map['userEmail'] ?? '',
    );
  }
=======
  final String type;
  final String title;
  final String date;
  final String path; // File path

  Document({
    required this.type,
    required this.title,
    required this.date,
    required this.path,
  });
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
}
