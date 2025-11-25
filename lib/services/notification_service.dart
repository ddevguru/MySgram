import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/NotificationModel.dart';

class NotificationService {
  // Temporarily using working backend - change back to https://mysgram.com when accessible
  static const String baseUrl = 'https://mysgram.com';
  
  // Create and send notification
  static Future<bool> createNotification({
    required String type,
    required String recipientId,
    required String senderId,
    String? message,
    String? targetId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found for notification');
        return false;
      }

      print('🔔 Creating notification: $type from $senderId to $recipientId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/create_notification.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': type,
          'recipient_id': recipientId,
          'sender_id': senderId,
          'message': message,
          'post_id': targetId,
        }),
      );

      print('📡 Notification response status: ${response.statusCode}');
      print('📡 Notification response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Notification created successfully: $type');
          return true;
        } else {
          print('❌ Failed to create notification: ${data['message']}');
        }
      } else {
        print('❌ HTTP error creating notification: ${response.statusCode}');
      }
      
      return false;
    } catch (e) {
      print('❌ Error creating notification: $e');
      return false;
    }
  }

  // Get notifications for current user
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found for getting notifications');
        return [];
      }

      print('🔍 Fetching notifications from: $baseUrl/get_notifications.php');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/auth/get_notifications.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final notifications = <NotificationModel>[];
          for (var notifData in data['notifications']) {
            try {
              // Convert backend format to NotificationModel format
              final convertedData = {
                'id': notifData['id'].toString(),
                'type': notifData['type'],
                'title': notifData['title'],
                'message': notifData['message'],
                'image_url': notifData['image_url'],
                'target_id': notifData['target_id']?.toString(),
                'sender_id': notifData['sender_id'].toString(),
                'sender_name': notifData['sender_name'],
                'sender_profile_picture': notifData['sender_profile_picture'],
                'created_at': notifData['timestamp'],
                'is_read': notifData['is_read'],
                'metadata': notifData['metadata'],
              };
              
              notifications.add(NotificationModel.fromJson(convertedData));
            } catch (parseError) {
              print('❌ Error parsing notification: $parseError');
              print('❌ Notification data: $notifData');
            }
          }
          print('📱 Fetched ${notifications.length} notifications');
          return notifications;
        } else {
          print('❌ Failed to get notifications: ${data['message']}');
        }
      } else {
        print('❌ HTTP error getting notifications: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
      }
      
      return [];
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markNotificationRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found for marking notification read');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/mark_notification_read.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'notification_id': notificationId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error marking notification read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  static Future<bool> markAllNotificationsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found for marking all notifications read');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/mark_all_notifications_read.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error marking all notifications read: $e');
      return false;
    }
  }

  // Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return 0;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/get_unread_notification_count.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['unread_count'] ?? 0;
        }
      }
      
      return 0;
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
      return 0;
    }
  }

  // Helper methods for specific notification types
  static Future<bool> notifyFollow(String recipientId, String senderId) {
    return createNotification(
      type: 'follow',
      recipientId: recipientId,
      senderId: senderId,
      message: 'started following you',
    );
  }

  static Future<bool> notifyUnfollow(String recipientId, String senderId) {
    return createNotification(
      type: 'unfollow',
      recipientId: recipientId,
      senderId: senderId,
      message: 'unfollowed you',
    );
  }

  static Future<bool> notifyLike(String recipientId, String senderId, String postId) {
    return createNotification(
      type: 'like',
      recipientId: recipientId,
      senderId: senderId,
      targetId: postId,
      message: 'liked your post',
    );
  }

  static Future<bool> notifyUnlike(String recipientId, String senderId, String postId) {
    return createNotification(
      type: 'unlike',
      recipientId: recipientId,
      senderId: senderId,
      targetId: postId,
      message: 'unliked your post',
    );
  }

  static Future<bool> notifyComment(String recipientId, String senderId, String postId, String comment) {
    return createNotification(
      type: 'comment',
      recipientId: recipientId,
      senderId: senderId,
      targetId: postId,
      message: comment,
    );
  }

  static Future<bool> notifyMessage(String recipientId, String senderId, String message) {
    return createNotification(
      type: 'message',
      recipientId: recipientId,
      senderId: senderId,
      message: message,
    );
  }
} 