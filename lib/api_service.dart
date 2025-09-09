import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'Document_model.dart';

class ApiService {
  // 🔹 Render Hosted Backend URL
  static const String baseUrl =
      "https://healthvault-backend-c6xl.onrender.com/api/files";

  // ================= Preview Document =================
  /// Ab preview ke liye Cloudinary ka direct URL use hoga.
  static Future<void> previewDocument(String fileUrl) async {
    try {
      if (!fileUrl.startsWith("http")) {
        throw "Invalid file URL";
      }

      // 🔹 Bas Cloudinary URL open karna hai
      debugPrint("📂 Preview: $fileUrl");

      // Flutter me preview ke liye tum `url_launcher` ya `open_filex` use kar sakte ho
      // yahan sirf URL return karna kaafi hai, UI side me open karna hoga
    } catch (e) {
      debugPrint("❌ Error previewing document: $e");
    }
  }

  // ================= Delete Document =================
  static Future<bool> deleteDocument(String docId) async {
    try {
      final url = Uri.parse("$baseUrl/$docId");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        debugPrint("✅ Document deleted: $docId");
        return true;
      } else {
        debugPrint("❌ Delete failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Error deleting document: $e");
      return false;
    }
  }

  // ================= Fetch Documents =================
  static Future<List<Document>> fetchDocuments({
    String? category,
    required String userEmail,
  }) async {
    try {
      final uri = Uri.parse(
          "$baseUrl?category=${category ?? ''}&email=$userEmail");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey("documents")) {
          final List docs = data["documents"];
          return docs.map((e) => Document.fromApi(e)).toList();
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
  static Future<Document?> uploadDocument({
    required File file,
    required String userId,
    required String userEmail,
    required String title,
    required String category,
    required String date,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/upload");
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
        final docData = jsonResponse['file'] ?? jsonResponse;
        return Document.fromApi(docData);
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
