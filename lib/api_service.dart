import 'dart:convert';
import 'dart:io';import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'Document_model.dart';

class ApiService {
  /// ✅ Replace with your LAN IP or actual server IP
  static const String serverIP = "192.168.31.166";
  static final String baseUrl = "http://$serverIP:5000/api";

  /// ================= Upload Document =================
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

  /// ================= Fetch Documents =================
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

  /// ✅ Preview Document (Download & Open)
  static Future<void> previewDocument(Document document) async {
    try {
      if (document.url == null || document.url!.isEmpty) {
        throw "File URL is missing";
      }

      final fileUrl = document.url!.startsWith("http")
          ? document.url!
          : "$baseUrl${document.url}";

      final uri = Uri.parse(fileUrl);
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final dir = await getTemporaryDirectory();
        final path = "${dir.path}/${document.title}";
        final tempFile = File(path);
        await tempFile.writeAsBytes(bytes, flush: true);
        await OpenFile.open(tempFile.path);
      } else {
        throw "Failed to fetch file: ${response.statusCode}";
      }
    } catch (e) {
      print("❌ Error previewing document: $e");
    }
  }


  /// ================= Delete Document =================
  static Future<bool> deleteDocument(String docId) async {
    try {
      final url = Uri.parse("$baseUrl/files/$docId"); // backend route
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("✅ Document deleted successfully: $docId");
        return true;
      } else {
        print("❌ Failed to delete document: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error deleting document: $e");
      return false;
    }
  }
}
