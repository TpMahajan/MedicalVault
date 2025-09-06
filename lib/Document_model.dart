class Document {
  final String? id;
  final String title;
  final String? path;
  final String? date;
  final String? url;
  final String? category;

  Document({
    this.id,
    required this.title,
    this.path,
    this.date,
    this.url,
    this.category,
  });

  factory Document.fromApi(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? json['_id'],
      title: json['title'] ?? json['fileName'] ?? 'Untitled',
      path: json['path'] ?? '',
      date: json['date'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "path": path,
      "date": date,
      "url": url,
      "category": category,
    };
  }
}
