import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Document_model.dart';

class ApiService {
  static const String baseUrl = "https://backend-medicalvault.onrender.com/api";
  static const String authUrl = "$baseUrl/auth";
  static const String filesUrl = "$baseUrl/files";
  static const String qrUrl = "$baseUrl/qr";

  // ---------------- TOKEN ----------------
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // ✅ Public method to get token for Dio requests
  static Future<String?> getToken() async {
    return _getToken();
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      HttpHeaders.authorizationHeader: 'Bearer ${token ?? ''}',
    };
  }

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$authUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'];
        final user = data['user'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("authToken", token);
          await prefs.setString("userId", user?['id']?.toString() ?? "");
          await prefs.setString("email", user?['email']?.toString() ?? "");
          await prefs.setString("name", user?['name']?.toString() ?? "Patient");
          // ✅ Also store userData for dashboard compatibility
          await prefs.setString("userData", jsonEncode(user));
        }

        return data;
      } else {
        print("Login failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // ---------------- PROFILE ----------------
  static Future<Map<String, dynamic>?> me() async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(Uri.parse("$authUrl/me"), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data']['user'];
      }
    } catch (e) {
      print("Me error: $e");
    }
    return null;
  }

  // ---------------- UPLOAD ----------------
  static Future<Document?> uploadDocument({
    required File file,
    required String title,
    required String category,
    String? notes,
    String? date,
  }) async {
    try {
      // ✅ Force category to match backend accepted values
      final validCategories = ["Report", "Prescription", "Bill", "Insurance"];
      final normalizedCategory =
          validCategories.contains(category) ? category : "Report"; // fallback

      final uri = Uri.parse("$filesUrl/upload");
      final request = http.MultipartRequest("POST", uri);

      final token = await _getToken();
      if (token != null) {
        request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";
      }

      request.fields["title"] = title;
      request.fields["category"] = normalizedCategory;
      if (notes != null) request.fields["notes"] = notes;
      if (date != null) request.fields["date"] = date;

      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        "file",
        stream,
        length,
        filename: file.path.split("/").last,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        return Document.fromApi(json['document']);
      } else {
        print("Upload failed: $body");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // ---------------- FETCH FILES ----------------
  static Future<List<Document>> fetchMyDocs(String userId) async {
    try {
      final headers = await _authHeaders();
      final res =
          await http.get(Uri.parse("$filesUrl/user/$userId"), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final docs = data['documents'] as List;
        return docs.map((j) => Document.fromApi(j)).toList();
      }
    } catch (e) {
      print("Fetch error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>?> fetchGroupedDocs(String userId) async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(Uri.parse("$filesUrl/user/$userId/grouped"),
          headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("Grouped fetch error: $e");
    }
    return null;
  }

  // ---------------- FETCH GROUPED DOCS BY EMAIL (for ProfilePageSettings) ----------------
  static Future<Map<String, dynamic>?> fetchGroupedDocsByEmail(
      String email) async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(Uri.parse("$filesUrl/grouped/$email"),
          headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("Grouped fetch by email error: $e");
    }
    return null;
  }

  // ---------------- DELETE ----------------
  static Future<bool> deleteDocument(String docId) async {
    try {
      final headers = await _authHeaders();
      final res =
          await http.delete(Uri.parse("$filesUrl/$docId"), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ---------------- QR ----------------
  static Future<String?> generateQrToken() async {
    try {
      final headers = await _authHeaders();
      final res =
          await http.post(Uri.parse("$qrUrl/generate"), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['qrUrl'] ?? data['token'];
      }
    } catch (e) {
      print("QR error: $e");
    }
    return null;
  }
}
