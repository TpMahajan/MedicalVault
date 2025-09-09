class Document {
  final String? id;
  final String? userId;
  final String? title;
  final String? notes;
  final String? date;
  final String? fileName;
  final String? fileType;
  final String? url;       // ✅ Cloudinary permanent URL
  final String? category;
  final String? publicId;  // ✅ For delete from Cloudinary

  Document({
    this.id,
    this.userId,
    this.title,
    this.notes,
    this.date,
    this.fileName,
    this.fileType,
    this.url,
    this.category,
    this.publicId,
  });

  /// ✅ Factory constructor for API response
  factory Document.fromApi(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? json['_id'],
      userId: json['userId'],
      title: json['title'] ?? json['fileName'] ?? 'Untitled',
      notes: json['notes'],
      date: json['date'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      url: json['url'],         // 🔹 Cloudinary URL
      category: json['category'] ?? 'Other',
      publicId: json['publicId'], // 🔹 Needed for delete
    );
  }

  /// ✅ Convert back to JSON (if needed for upload/offline storage)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "notes": notes,
      "date": date,
      "fileName": fileName,
      "fileType": fileType,
      "url": url,
      "category": category,
      "publicId": publicId,
    };
  }
}
