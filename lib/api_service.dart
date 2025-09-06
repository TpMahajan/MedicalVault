import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'Document_model.dart';

class ApiService {
  static const String serverIP = "192.168.31.166"; // your PC/LAN IP
  static final String baseUrl = "http://$serverIP:5000/api";

  // ================= Preview Document =================
  static Future<void> previewDocument(String fileUrl) async {
    try {
      // ensure full URL
      final fullUrl = fileUrl.startsWith("http") ? fileUrl : "http://$serverIP:5000$fileUrl";

      final uri = Uri.parse(fullUrl);
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final dir = await getTemporaryDirectory();
        final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "temp_file";
        final tempFile = File("${dir.path}/$fileName");
        await tempFile.writeAsBytes(bytes, flush: true);
        await OpenFile.open(tempFile.path);
      } else {
        throw "Failed to fetch file: ${response.statusCode}";
      }
    } catch (e) {
      print("❌ Error previewing document: $e");
    }
  }

  // ================= Delete Document =================
  static Future<bool> deleteDocument(String docId) async {
    try {
      final url = Uri.parse("$baseUrl/files/$docId");
      print("Deleting document at: $url"); // 🔍 debug
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("✅ Document deleted successfully: $docId");
        return true;
      } else {
        print("❌ Failed to delete document: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error deleting document: $e");
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
        "$baseUrl/files?category=${category ?? ''}&email=$userEmail",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List docs = data["documents"] ?? [];
        return docs.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        print("❌ Fetch failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("⚠️ Error fetching documents: $e");
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

      print("⬅️ Upload response: ${response.statusCode} $respStr");

      final jsonResponse = json.decode(respStr);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      }
      return null;
    } catch (e) {
      print("⚠️ Error uploading document: $e");
      return null;
    }
  }
}
