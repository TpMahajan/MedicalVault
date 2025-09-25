import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static const String baseUrl = "https://backend-medicalvault.onrender.com/api";

  // Singleton pattern
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('FCM Permission status: ${settings.authorizationStatus}');
      }

      // Configure foreground notification presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Handle messages when app is terminated
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleTerminatedMessage(initialMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM initialization error: $e');
      }
    }
  }

  // Get FCM token and save it to backend
  Future<void> registerToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('FCM Token: $token');
        }

        // Save token to backend
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM token registration error: $e');
      }
    }
  }

  // Save FCM token to backend
  Future<void> _saveTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      final userId = prefs.getString('userId');

      if (authToken == null || userId == null) {
        if (kDebugMode) {
          print('No auth token or user ID found for FCM registration');
        }
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/save-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcmToken': token,
          'userId': userId,
          'role': 'patient', // Flutter app is for patients
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('FCM token saved successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to save FCM token: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // You can show a local notification or in-app notification here
    // For now, we'll just log it
  }

  // Handle background messages (when app is in background)
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received background message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Handle the notification data here
    _processNotificationData(message.data);
  }

  // Handle terminated app messages
  void _handleTerminatedMessage(RemoteMessage message) {
    if (kDebugMode) {
      print(
          'App opened from terminated state by notification: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Handle the notification data here
    _processNotificationData(message.data);
  }

  // Process notification data based on type
  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'SESSION_REQUEST':
        if (kDebugMode) {
          print('Processing session request notification');
        }
        // Navigate to session requests page or show dialog
        break;
      case 'SESSION_RESPONSE':
        if (kDebugMode) {
          print('Processing session response notification');
        }
        // Handle session response
        break;
      case 'FILE_UPLOAD':
        if (kDebugMode) {
          print('Processing file upload notification');
        }
        // Navigate to documents page or refresh
        break;
      default:
        if (kDebugMode) {
          print('Unknown notification type: $type');
        }
    }
  }

  // Subscribe to topic (optional - for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
  // Handle background message here
}
