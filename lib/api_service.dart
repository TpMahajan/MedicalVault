import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000/api"; // change if needed

  static Future<bool> uploadDocument({
    required File file,
    required String userEmail,
    required String title,
    required String category,
    required String date,
    required String notes,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/documents/upload");

      var request = http.MultipartRequest("POST", uri);

      // Add text fields
      request.fields["userEmail"] = userEmail;
      request.fields["title"] = title;
      request.fields["category"] = category;
      request.fields["date"] = date;
      request.fields["notes"] = notes;

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath("file", file.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Upload failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error uploading document: $e");
      return false;
    }
  }
}
