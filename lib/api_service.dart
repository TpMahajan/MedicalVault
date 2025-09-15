import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'Document_model.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ add for preview

class ApiService {
  // 🔹 Render Hosted Backend URL
  static const String baseUrl =
      "https://healthvault-backend-c6xl.onrender.com/api/files";

  // ================= Preview Document =================
  /// Ab preview ke liye Cloudinary ka direct URL use hoga.
  /// Agar file Cloudinary pe `raw/upload/` ke saath hai (octet-stream),
  /// to Google Docs Viewer ka fallback use hoga.
  static Future<String?> previewDocument(String fileUrl) async {
    try {
      if (!fileUrl.startsWith("http")) {
        throw "Invalid file URL";
      }

      String previewUrl = fileUrl;

      // ✅ Special handling for PDFs with wrong mimetype (octet-stream → raw/upload/)
      if (fileUrl.toLowerCase().endsWith(".pdf") && fileUrl.contains("/raw/")) {
        previewUrl =
        "https://docs.google.com/viewer?url=${Uri.encodeComponent(fileUrl)}&embedded=true";
        debugPrint("🔄 Using Google Docs fallback for PDF: $previewUrl");
      } else {
        debugPrint("📂 Direct preview: $previewUrl");
      }

      // ✅ Try to launch
      final uri = Uri.parse(previewUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return previewUrl;
      } else {
        debugPrint("⚠️ Could not launch $previewUrl");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error previewing document: $e");
      return null;
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
