import 'dart:typed_data';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'constant.dart';

class MongoDataBase {
  static late Db db;
  static late DbCollection userCollection;
  static late DbCollection docCollection;

  // ================= CONNECT =================
  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_URL);
      await db.open();
      userCollection = db.collection(COLLECTION_NAME);
      docCollection = db.collection(DOC_COLLECTION);
      print("✅ MongoDB Connected");
    } catch (e) {
      print("❌ MongoDB connection failed: $e");
    }
  }

  // ================= USER FUNCTIONS =================

  // Signup
  static Future<void> signupUser(
      String name, String email, String phone, String password) async {
    try {
      var result = await userCollection.insertOne({
        "_id": ObjectId(),
        "name": name,
        "email": email.trim().toLowerCase(),
        "phone": phone,
        "password": password,
      });

      print(result.isSuccess
          ? "✅ User inserted successfully"
          : "❌ Failed to insert user");
    } catch (e) {
      print("❌ Error in signup: $e");
    }
  }

  // Login
  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    try {
      final user = await userCollection.findOne({
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      return user;
    } catch (e) {
      print("❌ Error during login: $e");
      return null;
    }
  }

  // ================= DOCUMENT FUNCTIONS =================

  // Upload Document
  static Future<void> uploadDocument(
      String userEmail,
      String fileName,
      String fileType,
      String category,
      Uint8List fileBytes, {
        String title = "",
        String notes = "",
        String date = "",
      }) async {
    try {
      var result = await docCollection.insertOne({
        "_id": ObjectId(),
        "email": userEmail.trim().toLowerCase(),
        "fileName": fileName,
        "fileType": fileType,
        "category": category,
        "fileBytes": fileBytes.toList(),
        "title": title,
        "notes": notes,
        "date": date,
        "uploadedAt": DateTime.now().toUtc(),
      });

      print(result.isSuccess
          ? "✅ Document uploaded with category: $category"
          : "❌ Document upload failed");
    } catch (e) {
      print("❌ Error uploading document: $e");
    }
  }

  // Get All User Documents
  static Future<List<Map<String, dynamic>>> getUserDocuments(
      String email) async {
    try {
      final docs = await docCollection
          .find({"email": email.trim().toLowerCase()}).toList();

      print("📂 Found ${docs.length} documents for $email");

      return docs;
    } catch (e) {
      print("❌ Error fetching documents: $e");
      return [];
    }
  }

  // ✅ Get User Documents by Category
  // Get documents by category
  static Future<List<Map<String, dynamic>>> getDocumentsByCategory(
      String userEmail, String category) async {
    try {
      final docs = await docCollection.find({
        "email": userEmail.trim().toLowerCase(),
        "category": category
      }).toList();

      return docs;
    } catch (e) {
      print("❌ Error fetching documents by category: $e");
      return [];
    }
  }


  // Get Document Count by Category
  // Get Document Count by Category
  static Future<Map<String, int>> getDocumentCountByCategory(String userEmail) async {
    try {
      final pipeline = [
        {
          '\$match': {"email": userEmail.trim().toLowerCase()}
        },
        {
          '\$group': {
            "_id": "\$category",
            "count": {"\$sum": 1}
          }
        }
      ];

      final aggResult = await docCollection.aggregateToStream(pipeline).toList();

      Map<String, int> counts = {};
      for (var doc in aggResult) {
        counts[doc["_id"]] = doc["count"] as int;
      }

      return counts;
    } catch (e) {
      print("❌ Error counting documents: $e");
      return {};
    }
  }


  // Download Document
  static Future<void> downloadDocument(
      Map<String, dynamic> document, String savePath) async {
    try {
      final fileBytes = document["fileBytes"] != null
          ? List<int>.from(document["fileBytes"])
          : null;

      if (fileBytes == null) {
        print("❌ No file data found");
        return;
      }

      File file = File(savePath);
      await file.writeAsBytes(fileBytes);

      print("✅ File saved at $savePath");
    } catch (e) {
      print("❌ Error saving file: $e");
    }
  }

  // Delete Document
  static Future<bool> deleteDocument(String userEmail, String fileName) async {
    try {
      final result = await docCollection.deleteOne({
        "email": userEmail.trim().toLowerCase(),
        "fileName": fileName,
      });

      print(result.isSuccess
          ? "✅ Document deleted successfully"
          : "❌ Document deletion failed");

      return result.isSuccess;
    } catch (e) {
      print("❌ Error deleting document: $e");
      return false;
    }
  }
}
