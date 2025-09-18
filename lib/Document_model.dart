class Document {
  final String? id;
  final String? patientId;
  final String? userId; // backward compatibility
  final String? title;
  final String? description;
  final String? notes;
  final String? date;
  final String? fileName;
  final String? fileType;
  final String? url; // ✅ Cloudinary or API URL
  final String? category; // ✅ Logical grouping
  final String? type; // ✅ Backend sometimes uses this
  final String? publicId; // ✅ For delete from Cloudinary

  Document({
    this.id,
    this.patientId,
    this.userId,
    this.title,
    this.description,
    this.notes,
    this.date,
    this.fileName,
    this.fileType,
    this.url,
    this.category,
    this.type,
    this.publicId,
  });

  /// ✅ Factory constructor for API response
  factory Document.fromApi(Map<String, dynamic> json) {
    // ✅ Improved URL resolution - prioritize 'url' field, fallback to 'cloudinaryUrl'
    final resolvedUrl = json['url'] ?? json['cloudinaryUrl'];

    // ✅ Normalize category/type to lowercase for consistent comparison
    final rawType = (json['type'] ?? json['category'] ?? "")
        .toString()
        .toLowerCase()
        .trim();

    // ✅ Normalize to only 4 values
    String normalized;
    if (rawType.contains("report")) {
      normalized = "report";
    } else if (rawType.contains("prescription")) {
      normalized = "prescription";
    } else if (rawType.contains("bill")) {
      normalized = "bill";
    } else if (rawType.contains("insurance")) {
      normalized = "insurance";
    } else {
      // ✅ Default to "report" if category is invalid
      normalized = "report";
    }

    return Document(
      id: json['id'] ?? json['_id'],
      patientId: json['patientId'] ??
          json['userId'], // ✅ Use userId as fallback for patientId
      userId: json['userId'],
      title: json['title'] ??
          json['fileName'] ??
          json['originalName'] ??
          'Untitled',
      description: json['description'],
      notes: json['notes'],
      date: json['date'] ?? json['uploadedAt'], // ✅ Use uploadedAt as fallback
      fileName: json['fileName'] ?? json['originalName'],
      fileType: json['fileType'] ?? json['mimeType'],
      url: resolvedUrl,
      category: normalized,
      type: normalized,
      publicId: json['publicId'] ?? json['cloudinaryPublicId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "patientId": patientId,
      "userId": userId,
      "title": title,
      "description": description,
      "notes": notes,
      "date": date,
      "fileName": fileName,
      "fileType": fileType,
      "url": url,
      "category": category,
      "type": type,
      "publicId": publicId,
    };
  }

  /// ✅ Always return one of the 4 allowed values
  String get normalizedType {
    return (type ?? category ?? "").toLowerCase();
  }
}
