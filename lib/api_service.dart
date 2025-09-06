import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'Document_model.dart';

class ApiService {
  // 🔹 Render Hosted Backend URL
  static const String baseUrl = "https://healthvault-backend-c6xl.onrender.com/api";

  // ================= Preview Document =================
  static Future<void> previewDocument(String fileUrl) async {
    try {
      final fullUrl = fileUrl.startsWith("http")
          ? fileUrl
          : "https://healthvault-backend-c6xl.onrender.com$fileUrl";

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final fileName = Uri.parse(fullUrl).pathSegments.isNotEmpty
            ? Uri.parse(fullUrl).pathSegments.last
            : "temp_file";
        final tempFile = File("${dir.path}/$fileName");

        await tempFile.writeAsBytes(bytes, flush: true);
        await OpenFile.open(tempFile.path);
      } else {
        throw Exception("Failed to fetch file: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error previewing document: $e");
    }
  }

  // ================= Delete Document =================
  static Future<bool> deleteDocument(String docId) async {
    try {
      final url = Uri.parse("$baseUrl/files/$docId");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        debugPrint("✅ Document deleted successfully: $docId");
        return true;
      } else {
        debugPrint("❌ Failed to delete document: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Error deleting document: $e");
      return false;
    }
  }

  // ================= Fetch Documents =================
  static Future<List<Map<String, dynamic>>> fetchDocuments({
    String? category,
    required String userEmail,
  }) async {
    try {
      final uri = Uri.parse(
          "$baseUrl/files?category=${category ?? ''}&email=$userEmail");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("documents")) {
          final List docs = data["documents"];
          return docs.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        return [];
      } else {
        debugPrint("❌ Fetch failed: ${response.statusCode} ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching documents: $e");
      return [];
    }
  }

  // ================= Upload Document =================
  static Future<Map<String, dynamic>?> uploadDocument({
    required File file,
    required String userId,
    required String userEmail,
    required String title,
    required String category,
    required String date,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/files/upload");
      final request = http.MultipartRequest("POST", uri);

      request.fields["userId"] = userId;
      request.fields["email"] = userEmail;
      request.fields["title"] = title;
      request.fields["category"] = category;
      request.fields["date"] = date;
      if (notes != null) request.fields["notes"] = notes;

      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final jsonResponse = json.decode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Upload successful");
        return jsonResponse;
      } else {
        debugPrint("❌ Upload failed: ${response.statusCode} $respStr");
        return null;
      }
    } catch (e) {
      debugPrint("⚠️ Error uploading document: $e");
      return null;
    }
  }
}
