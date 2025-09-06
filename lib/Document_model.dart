class Document {
  final String? id;       // backend _id
  final String title;
  final String category;
  final String date;
  final String? path;     // full usable URL for preview/download
  final String? url;      // raw URL from backend (/uploads/...)
  final String? notes;

  Document({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    this.path,
    this.url,
    this.notes,
  });

  /// ================= From API Response =================
  factory Document.fromApi(Map<String, dynamic> json) {
    const baseUrl = "http://192.168.31.166:5000"; // your PC / server IP

    String? fileUrl = json['url'];
    String? computedPath;

    if (fileUrl != null) {
      // if backend gives relative path (/uploads/xyz.pdf), prepend baseUrl
      if (!fileUrl.startsWith("http")) {
        computedPath = "$baseUrl$fileUrl";
      } else {
        computedPath = fileUrl;
      }
    }

    return Document(
      id: json['id']?.toString(),
      title: json['title'] ?? json['fileName'] ?? "Untitled",
      category: json['category'] ?? "Other",
      date: json['date'] ?? "",
      path: computedPath,   // ✅ full URL ready for preview/download
      url: fileUrl,         // ✅ raw backend url
      notes: json['notes'] ?? "",
    );
  }

  /// ================= To API Map (if needed for upload/update) =================
  Map<String, dynamic> toApiMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'path': path,
      'url': url,
      'notes': notes,
    };
  }
}
