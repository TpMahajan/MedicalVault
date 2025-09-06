class Document {
  final String? id;       // backend _id
  final String title;
  final String category;
  final String date;
  final String? path;     // full URL for preview/download
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

  /// From API response
  factory Document.fromApi(Map<String, dynamic> json) {
    const baseUrl = "http://192.168.31.166:5000"; // 👈 tumhare PC ka IP

    String? fileUrl = json['url'];
    String? computedPath;

    if (fileUrl != null) {
      // agar backend sirf relative path bhejta hai (/uploads/xyz.pdf)
      if (!fileUrl.startsWith("http")) {
        computedPath = "$baseUrl$fileUrl";
      } else {
        computedPath = fileUrl;
      }
    }

    return Document(
      id: json['_id']?.toString(),
      title: json['title'] ?? json['fileName'] ?? "Untitled",
      category: json['category'] ?? "Other",
      date: json['date'] ?? "",
      path: computedPath,   // 👈 always usable URL
      url: fileUrl,         // 👈 raw backend url bhi save
      notes: json['notes'] ?? "",
    );
  }

  /// To API Map (agar future me update bhejna ho)
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
