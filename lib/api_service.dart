import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Document_model.dart';
import 'package:http_parser/http_parser.dart';
import 'fcm_service.dart';

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

  // ---------------- PASSWORD FLOWS ----------------
  static Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$authUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        print("Forgot password failed: ${res.body}");
        return {"success": false, "message": "Failed to send reset email"};
      }
    } catch (e) {
      print("Forgot password error: $e");
      return {"success": false, "message": "Network error"};
    }
  }

  static Future<Map<String, dynamic>?> resetPassword(
      {required String token, required String newPassword}) async {
    try {
      final res = await http.post(
        Uri.parse("$authUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "newPassword": newPassword}),
      );

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      print("Reset password error: $e");
      return {"success": false, "message": "Network error"};
    }
  }

  static Future<Map<String, dynamic>?> changePassword(
      {required String oldPassword, required String newPassword}) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse("$authUrl/change-password"),
        headers: {...headers, "Content-Type": "application/json"},
        body: jsonEncode(
            {"oldPassword": oldPassword, "newPassword": newPassword}),
      );

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      print("Change password error: $e");
      return {"success": false, "message": "Network error"};
    }
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

          // Register FCM token after successful login
          await FCMService().registerToken();
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
      } else {
        print("Profile fetch failed: ${res.body}");
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
          validCategories.contains(category) ? category : "Report";

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

      // ✅ Detect MIME type by file extension and set explicit contentType
      String filename = file.path.split("/").last;
      final lowerName = filename.toLowerCase();
      String mimeType = _detectMimeType(lowerName);

      final multipartFile = http.MultipartFile(
        "file",
        stream,
        length,
        filename: filename,
        contentType: MediaType.parse(mimeType),
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

  // ---------------- MIME TYPE HELPERS ----------------
  static String _detectMimeType(String filename) {
    final ext =
        filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
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
      } else {
        print("Fetch docs failed: ${res.body}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>?> fetchGroupedDocs(String userId) async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(
        Uri.parse("$filesUrl/user/$userId/grouped"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print("Grouped fetch failed: ${res.body}");
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
      } else {
        print("Grouped fetch by email failed: ${res.body}");
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

      if (res.statusCode == 200) {
        return true;
      } else {
        print("Delete failed: ${res.body}");
        return false;
      }
    } catch (e) {
      print("Delete error: $e");
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
      } else {
        print("QR generation failed: ${res.body}");
      }
    } catch (e) {
      print("QR error: $e");
    }
    return null;
  }

  // ---------------- PROFILE MANAGEMENT ----------------
  static Future<List<Map<String, dynamic>>> getLinkedProfiles() async {
    try {
      final headers = await _authHeaders();
      final res = await http.get(
        Uri.parse("${baseUrl}/profiles"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(
            data['data']['linkedProfiles'] ?? []);
      } else {
        print("Get profiles failed: ${res.body}");
      }
    } catch (e) {
      print("Get profiles error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>?> addSelfProfile(
      String email, String password) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse("${baseUrl}/profiles/add-self"),
        headers: {...headers, "Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        print("Add self profile failed: ${res.body}");
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? 'Failed to add profile');
      }
    } catch (e) {
      print("Add self profile error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> addOtherProfile({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse("${baseUrl}/profiles/add-other"),
        headers: {...headers, "Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "mobile": mobile,
          "password": password,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        print("Add other profile failed: ${res.body}");
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? 'Failed to create profile');
      }
    } catch (e) {
      print("Add other profile error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> switchProfile(
      String profileId, String password) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse("${baseUrl}/profiles/switch/$profileId"),
        headers: {...headers, "Content-Type": "application/json"},
        body: jsonEncode({"password": password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['data']['token'];
        final user = data['data']['user'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("authToken", token);
          await prefs.setString("userId", user['id']?.toString() ?? "");
          await prefs.setString("email", user['email']?.toString() ?? "");
          await prefs.setString("name", user['name']?.toString() ?? "Patient");
          await prefs.setString("userData", jsonEncode(user));
          await prefs.setString(
              "activeProfileId", user['id']?.toString() ?? "");
        }

        return data;
      } else {
        print("Switch profile failed: ${res.body}");
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? 'Failed to switch profile');
      }
    } catch (e) {
      print("Switch profile error: $e");
      rethrow;
    }
  }

  static Future<bool> removeLinkedProfile(String profileId) async {
    try {
      final headers = await _authHeaders();
      final res = await http.delete(
        Uri.parse("${baseUrl}/profiles/remove/$profileId"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        return true;
      } else {
        print("Remove profile failed: ${res.body}");
        return false;
      }
    } catch (e) {
      print("Remove profile error: $e");
      return false;
    }
  }
}
