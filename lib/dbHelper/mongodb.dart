import 'dart:typed_data';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'constant.dart';

class MongoDataBase {
  static late Db db;
  static late DbCollection userCollection;
  static late DbCollection docCollection;

  // Connect to MongoDB
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
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      // Fetch user from MongoDB based on email & password
      final user = await userCollection.findOne({
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      if (user != null) {
        // Return the user map (contains name, email, phone, etc.)
        return user;
      } else {
        return null; // login failed
      }
    } catch (e) {
      print("❌ Error during login: $e");
      return null;
    }
  }

<<<<<<< HEAD
  // Upload Document with category
  static Future<void> uploadDocument(
      String userEmail, String fileName, String fileType, String category, Uint8List fileBytes) async {
    try {
      var result = await docCollection.insertOne({
        "_id": ObjectId(),
        "email": userEmail.trim().toLowerCase(),
        "fileName": fileName,
        "fileType": fileType,
        "category": category,
=======
  // Upload Document
  static Future<void> uploadDocument(
      String userEmail, String fileName, String fileType, Uint8List fileBytes) async {
    try {
      var result = await docCollection.insertOne({
        "_id": ObjectId(),
        "email": userEmail,
        "fileName": fileName,
        "fileType": fileType,
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
        "fileBytes": fileBytes.toList(), // stored as List<int>
        "uploadedAt": DateTime.now().toUtc(),
      });

      print(result.isSuccess
<<<<<<< HEAD
          ? "✅ Document uploaded with category: $category"
=======
          ? "✅ Document uploaded"
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
          : "❌ Document upload failed");
    } catch (e) {
      print("❌ Error uploading document: $e");
    }
  }

<<<<<<< HEAD
  // Get User Documents by category
  static Future<List<Map<String, dynamic>>> getUserDocumentsByCategory(String email, String category) async {
    try {
      final docs = await docCollection.find({
        "email": email.trim().toLowerCase(),
        "category": category
      }).toList();

      print("📂 Found ${docs.length} documents for $email in category: $category");

      // Clean map for Flutter (remove _id ObjectId format)
      return docs.map((doc) {
        return {
          "fileName": doc["fileName"],
          "fileType": doc["fileType"],
          "category": doc["category"],
          "fileBytes": doc["fileBytes"],
          "uploadedAt": doc["uploadedAt"].toString(),
        };
      }).toList();
    } catch (e) {
      print("❌ Error fetching documents by category: $e");
      return [];
    }
  }

  // Get All User Documents
  static Future<List<Map<String, dynamic>>> getUserDocuments(String email) async {
    try {
      final docs = await docCollection.find({"email": email.trim().toLowerCase()}).toList();
=======
  // Get User Documents
  static Future<List<Map<String, dynamic>>> getUserDocuments(String email) async {
    try {
      final docs = await docCollection.find({"email": email}).toList();
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538

      print("📂 Found ${docs.length} documents for $email");

      // Clean map for Flutter (remove _id ObjectId format)
      return docs.map((doc) {
        return {
          "fileName": doc["fileName"],
          "fileType": doc["fileType"],
<<<<<<< HEAD
          "category": doc["category"],
=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
          "fileBytes": doc["fileBytes"],
          "uploadedAt": doc["uploadedAt"].toString(),
        };
      }).toList();
    } catch (e) {
      print("❌ Error fetching documents: $e");
      return [];
    }
  }

<<<<<<< HEAD
  // Get Document Count by Category
  static Future<Map<String, int>> getDocumentCountByCategory(String email) async {
    try {
      final categories = ["Reports", "Prescription", "Bills", "Insurance"];
      Map<String, int> counts = {};
      
      for (String category in categories) {
        final count = await docCollection.count({
          "email": email.trim().toLowerCase(),
          "category": category
        });
        counts[category] = count;
      }

      print("📊 Document counts for $email: $counts");
      return counts;
    } catch (e) {
      print("❌ Error getting document counts: $e");
      return {};
    }
  }

=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
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
<<<<<<< HEAD

  // Delete Document
  static Future<bool> deleteDocument(String userEmail, String fileName) async {
    try {
      final result = await docCollection.deleteOne({
        "email": userEmail.trim().toLowerCase(),
        "fileName": fileName
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
=======
>>>>>>> 784214e06d8923dbaf5c46765cece00c1969c538
}
