import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'auth_service.dart'; // Add this import

class PHPChatService {
  // Update this URL to your actual backend
  // Temporarily using working backend - change back to https://mysgram.com/ when accessible
  static const String baseUrl = 'https://mysgram.com';
  
  // Chat state
  static final List<ChatMessage> messages = [];
  static final List<ChatRoom> chatRooms = [];
  
  // Initialize PHP chat service
  static Future<void> initialize() async {
    try {
      print('✅ PHP chat service initialized successfully');
    } catch (e) {
      print('❌ Error initializing PHP chat service: $e');
    }
  }
  
  // Send message via PHP backend
  static Future<bool> sendMessage(String roomId, String message, {String? replyTo}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }
      
      // Get current user ID using the proper AuthService method
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) {
        print('❌ No current user ID found');
        return false;
      }
      
      print('🔍 Sending message: roomId=$roomId, message=$message, userId=$currentUserId');
      
      // Send message to PHP backend
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send_message.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'room_id': roomId,
          'message': message,
          'reply_to': replyTo,
        }),
      );
      
      print('🔍 Send message response status: ${response.statusCode}');
      print('🔍 Send message response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Add message locally with proper timestamp
          final newMessage = ChatMessage(
            id: data['message_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: roomId,
            senderId: currentUserId, // Use actual user ID
            message: message,
            timestamp: DateTime.now(), // Use current time
            replyTo: replyTo,
          );
          
          messages.add(newMessage);
          
          // Send notification to the other user in the chat
          try {
            // Get the other user's ID from the room
            final roomResponse = await http.get(
              Uri.parse('$baseUrl/chat/get_room_participants.php?room_id=$roomId'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );
            
            if (roomResponse.statusCode == 200) {
              final roomData = json.decode(roomResponse.body);
              if (roomData['success'] == true) {
                final participants = roomData['participants'] as List;
                final otherUserId = participants.firstWhere(
                  (p) => p['user_id'].toString() != currentUserId,
                  orElse: () => null,
                )?['user_id'];
                
                if (otherUserId != null) {
                  // Get current user info
                  final userResponse = await http.get(
                    Uri.parse('$baseUrl/auth/get_user_profile.php'),
                    headers: {
                      'Authorization': 'Bearer $token',
                    },
                  );
                  
                  if (userResponse.statusCode == 200) {
                    final userData = json.decode(userResponse.body);
                    if (userData['success'] == true) {
                      await NotificationService.notifyMessage(
                        otherUserId,
                        currentUserId,
                        message,
                      );
                      print('✅ Message notification sent successfully');
                    }
                  }
                }
              }
            }
          } catch (e) {
            print('❌ Error sending message notification: $e');
          }
          
          print('✅ Message sent successfully via PHP');
          return true;
        }
      }
      
      print('❌ Failed to send message: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }
  
  // Create or get chat room
  static Future<ChatRoom?> createChatRoom(String userId1, String userId2, {Map<String, dynamic>? otherUserInfo}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return null;
      }
      
      print('🔍 Creating chat room via PHP backend');
      print('🔍 User ID 1: $userId1');
      print('🔍 User ID 2: $userId2');
      print('🔍 Other user info: $otherUserInfo');
      
      // Create room via PHP backend
      final response = await http.post(
        Uri.parse('$baseUrl/chat/create_room.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id_1': int.parse(userId1),
          'user_id_2': int.parse(userId2),
        }),
      );
      
      print('🔍 Create room response status: ${response.statusCode}');
      print('🔍 Create room response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final room = ChatRoom(
            id: data['room_id'],
            participants: [userId1, userId2],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            otherUser: otherUserInfo,
          );
          
          chatRooms.add(room);
          print('✅ Chat room created successfully via PHP: ${room.id}');
          return room;
        } else {
          print('❌ PHP backend returned success: false - ${data['message']}');
          return null;
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating chat room: $e');
      return null;
    }
  }
  
  // Get chat messages from PHP backend
  static Future<List<ChatMessage>> getChatMessages(String roomId, {int limit = 50, int offset = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }
      
      // Get messages from PHP backend
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_messages.php?room_id=$roomId&limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final messagesList = <ChatMessage>[];
          for (var msgData in data['messages']) {
            messagesList.add(ChatMessage(
              id: msgData['id'],
              roomId: roomId,
              senderId: msgData['sender_id'].toString(),
              message: msgData['message'],
              replyTo: msgData['reply_to'],
              timestamp: DateTime.parse(msgData['timestamp']),
              type: MessageType.values.firstWhere(
                (e) => e.toString().split('.').last == (msgData['type'] ?? 'text'),
                orElse: () => MessageType.text,
              ),
              metadata: {
                'sender_name': msgData['sender_name'],
                'sender_photo': msgData['sender_photo'],
              },
              isSeen: _parseBoolean(msgData['is_seen']),
              seenAt: msgData['seen_at'] != null ? DateTime.parse(msgData['seen_at']) : null,
            ));
          }
          
          print('📥 Fetched ${messagesList.length} messages via PHP');
          return messagesList;
        }
      }
      
      print('❌ Failed to get messages: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Error getting chat messages: $e');
      return [];
    }
  }
  
  // Get follow users for chat
  static Future<List<Map<String, dynamic>>> getFollowUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }
      
      // Get follow users from PHP backend
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_follow_users.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔍 Follow users response status: ${response.statusCode}');
      print('🔍 Follow users response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final usersList = List<Map<String, dynamic>>.from(data['users']);
          print('📋 Fetched ${usersList.length} follow users via PHP');
          return usersList;
        } else {
          print('❌ API returned success: false - ${data['message']}');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
      }
      
      print('❌ Failed to get follow users: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Error getting follow users: $e');
      return [];
    }
  }
  
  // Follow or unfollow user
  static Future<bool> toggleFollow(String targetUserId, String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }
      
      // Prepare request data
      final requestData = {
        'target_user_id': targetUserId,
        'action': action, // 'follow' or 'unfollow'
      };
      
      print('🔍 Sending follow request:');
      print('🔍 URL: $baseUrl/auth/follow_user.php');
      print('🔍 Token: ${token.substring(0, 20)}...');
      print('🔍 Request data: $requestData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/follow_user.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );
      
      print('🔍 Follow action response status: ${response.statusCode}');
      print('🔍 Follow action response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Send notification for follow/unfollow
          try {
            final currentUser = await _getCurrentUserInfo();
            if (currentUser != null) {
              if (action == 'follow') {
                await _sendNotification(
                  type: 'follow',
                  recipientId: targetUserId,
                  senderId: currentUser['id'],
                  senderName: currentUser['full_name'] ?? currentUser['username'],
                  senderProfilePicture: currentUser['profile_picture'],
                );
              } else if (action == 'unfollow') {
                await _sendNotification(
                  type: 'unfollow',
                  recipientId: targetUserId,
                  senderId: currentUser['id'],
                  senderName: currentUser['full_name'] ?? currentUser['username'],
                );
              }
            }
          } catch (e) {
            print('⚠️ Failed to send notification: $e');
            // Don't fail the main operation if notification fails
          }
          
          return true;
        }
      } else if (response.statusCode == 400) {
        // Parse error message for better debugging
        try {
          final errorData = json.decode(response.body);
          print('❌ Backend error: ${errorData['message']}');
        } catch (e) {
          print('❌ Backend error (unparseable): ${response.body}');
        }
      }
      
      return false;
    } catch (e) {
      print('❌ Error toggling follow: $e');
      return false;
    }
  }
  
  // Helper method to get current user info
  static Future<Map<String, dynamic>?> _getCurrentUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user info: $e');
      return null;
    }
  }
  
  // Helper method to send notifications
  static Future<void> _sendNotification({
    required String type,
    required String recipientId,
    required String senderId,
    required String senderName,
    String? senderProfilePicture,
    String? targetId,
    String? message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;
      
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
          'sender_name': senderName,
          'sender_profile_picture': senderProfilePicture,
          'target_id': targetId,
          'title': _getNotificationTitle(type, senderName),
          'message': message ?? _getNotificationMessage(type, senderName),
          'metadata': metadata,
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ Notification sent: $type');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
  
  // Helper methods for notification content
  static String _getNotificationTitle(String type, String senderName) {
    switch (type) {
      case 'follow':
        return 'New Follower';
      case 'unfollow':
        return 'Follower Removed';
      case 'like':
        return 'New Like';
      case 'comment':
        return 'New Comment';
      case 'message':
        return 'New Message';
      default:
        return 'New Activity';
    }
  }
  
  static String _getNotificationMessage(String type, String senderName) {
    switch (type) {
      case 'follow':
        return '$senderName started following you';
      case 'unfollow':
        return '$senderName unfollowed you';
      case 'like':
        return '$senderName liked your post';
      case 'comment':
        return '$senderName commented on your post';
      case 'message':
        return '$senderName sent you a message';
      default:
        return '$senderName performed an action';
    }
  }

  // Get all users for the modal
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/get_all_users.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔍 Get all users response status: ${response.statusCode}');
      print('🔍 Get all users response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final usersList = List<Map<String, dynamic>>.from(data['users']);
          print('📋 Fetched ${usersList.length} users via PHP');
          return usersList;
        } else {
          print('❌ API returned success: false - ${data['message']}');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
      }
      
      print('❌ Failed to get all users: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  // Get chat rooms from PHP backend
  static Future<List<ChatRoom>> getChatRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return [];
      }
      
      // Get rooms from PHP backend
      final response = await http.get(
        Uri.parse('$baseUrl/chat/get_rooms.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔍 Chat rooms response status: ${response.statusCode}');
      print('🔍 Chat rooms response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final roomsList = <ChatRoom>[];
          for (var roomData in data['rooms']) {
            ChatMessage? lastMessage;
            if (roomData['last_message'] != null) {
              final lastMsg = roomData['last_message'];
              lastMessage = ChatMessage(
                id: 'last_${roomData['id']}',
                roomId: roomData['id'],
                senderId: lastMsg['sender_id'].toString(),
                message: lastMsg['message'],
                timestamp: DateTime.parse(lastMsg['timestamp']),
              );
            }
            
            roomsList.add(ChatRoom(
              id: roomData['id'],
              participants: (roomData['participants'] as List).map((id) => id.toString()).toList(),
              lastMessage: lastMessage,
              unreadCount: roomData['unread_count'] ?? 0,
              createdAt: DateTime.parse(roomData['created_at']),
              updatedAt: DateTime.parse(roomData['updated_at']),
              otherUser: roomData['other_user'], // Include other user info from backend
            ));
          }
          
          print('📋 Fetched ${roomsList.length} chat rooms via PHP');
          return roomsList;
        } else {
          print('❌ API returned success: false - ${data['message']}');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
      }
      
      print('❌ Failed to get chat rooms: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Error getting chat rooms: $e');
      return [];
    }
  }
  
  // Send gift via PHP backend
  static Future<bool> sendGift(String recipientId, String giftId, {int quantity = 1, String? message}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }
      
      print('🔍 Sending gift: recipientId=$recipientId, giftId=$giftId, quantity=$quantity');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send_gift.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'recipient_id': recipientId,
          'gift_id': giftId,
          'quantity': quantity,
          'message': message ?? '',
        }),
      );
      
      print('🔍 Send gift response status: ${response.statusCode}');
      print('🔍 Send gift response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Gift sent successfully via PHP');
          return true;
        } else {
          print('❌ Gift sending failed: ${data['message']}');
          return false;
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending gift: $e');
      return false;
    }
  }
  
  // Start voice call (simulated)
  static Future<bool> startVoiceCall(String phoneNumber) async {
    try {
      print('📞 Starting voice call to: $phoneNumber');
      print('🔑 Using PHP backend for call management');
      
      // Simulate call setup
      await Future.delayed(Duration(seconds: 2));
      print('✅ Voice call started successfully');
      return true;
    } catch (e) {
      print('❌ Error starting voice call: $e');
      return false;
    }
  }
  
  // Start video call (simulated)
  static Future<bool> startVideoCall(String channelName) async {
    try {
      print('📹 Starting video call in channel: $channelName');
      print('🔑 Using PHP backend for call management');
      
      // Simulate call setup
      await Future.delayed(Duration(seconds: 2));
      print('✅ Video call started successfully');
      return true;
    } catch (e) {
      print('❌ Error starting video call: $e');
      return false;
    }
  }
  
  // End call
  static Future<void> endCall() async {
    try {
      print('📞 Ending call');
      await Future.delayed(Duration(milliseconds: 500));
      print('✅ Call ended');
    } catch (e) {
      print('❌ Error ending call: $e');
    }
  }
  
  // Mark message as seen
  static Future<bool> markMessageAsSeen(String messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }
      
      // Mark message as seen via PHP backend
      final response = await http.post(
        Uri.parse('$baseUrl/chat/mark_message_seen.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'message_id': messageId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Message marked as seen: $messageId');
          return true;
        }
      }
      
      print('❌ Failed to mark message as seen: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error marking message as seen: $e');
      return false;
    }
  }

  // Mark all messages in a room as seen
  static Future<bool> markAllMessagesAsSeen(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('❌ No auth token found');
        return false;
      }
      
      // Mark all messages as seen via PHP backend
      final response = await http.post(
        Uri.parse('$baseUrl/chat/mark_all_messages_seen.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'room_id': roomId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ All messages marked as seen in room: $roomId');
          return true;
        }
      }
      
      print('❌ Failed to mark all messages as seen: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error marking all messages as seen: $e');
      return false;
    }
  }

  // Parse boolean values from various formats
  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  // Check if service is initialized
  static bool get isInitialized => true;
  
  // Dispose resources
  static void dispose() {
    print('🔄 PHP chat service disposed');
  }
}

// Data models
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final String? replyTo;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final bool isSeen;
  final DateTime? seenAt;
  
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    this.replyTo,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
    this.isSeen = false,
    this.seenAt,
  });
}

class ChatRoom {
  final String id;
  final List<String> participants;
  ChatMessage? lastMessage;
  int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? otherUser; // Store other user info
  
  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.otherUser,
  });
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  gift,
  location,
} 