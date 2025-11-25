import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/php_chat_service.dart'; // This contains ChatMessage and MessageType
import '../../services/gift_service_simple.dart';
import '../../services/auth_service.dart';
import '../../services/razorpay_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  var chatRooms = <ChatRoom>[].obs;
  var followUsers = <Map<String, dynamic>>[].obs;
  var currentMessages = <ChatMessage>[].obs;
  var currentRoom = Rxn<ChatRoom>();
  var isLoading = false.obs;
  var userCoins = 0.obs;
  var currentUserId = ''.obs;
  var postToShare = Rxn<Map<String, dynamic>>(); // Store post data for sharing via chat
  
  @override
  void onInit() {
    super.onInit();
    initializeChat();
    loadUserCoins();
  }
  
  Future<void> initializeChat() async {
    try {
      await PHPChatService.initialize();
      
      // Get current user ID
      final userId = await AuthService.getCurrentUserId();
      if (userId != null) {
        currentUserId.value = userId;
        print('🔍 Current user ID set: $userId');
      }
      
      await loadChatRooms();
      await loadFollowUsers(); // Load follow users for chat
      
      // Trigger rebuild for GetBuilder
      update();
      
      // Listen to purchase updates
      GiftService.purchaseUpdates.listen((purchases) {
        for (var purchase in purchases) {
          GiftService.processPurchase(purchase);
        }
        loadUserCoins(); // Refresh coins after purchase
      });
      
      // Register callback for coin updates from payment
      RazorpayService.onCoinsUpdated = () {
        loadUserCoins();
      };
    } catch (e) {
      print('❌ Error initializing chat: $e');
    }
  }
  
  Future<void> loadUserCoins() async {
    try {
      final coins = await GiftService.getUserCoins();
      userCoins.value = coins;
    } catch (e) {
      print('❌ Error loading user coins: $e');
    }
  }
  
  Future<void> loadChatRooms() async {
    try {
      isLoading.value = true;
      final rooms = await PHPChatService.getChatRooms();
      chatRooms.value = rooms;
      
      if (rooms.isEmpty) {
        print('ℹ️ No chat rooms found - this is normal for new users');
      }
    } catch (e) {
      print('❌ Error loading chat rooms: $e');
      
      // Show user-friendly error message
      if (e.toString().contains('Column not found')) {
        Get.snackbar(
          'Setup Required',
          'Chat system needs to be initialized. Please contact support.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load chat rooms: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load follow users for chat
  Future<void> loadFollowUsers() async {
    try {
      isLoading.value = true;
      final users = await PHPChatService.getFollowUsers();
      followUsers.value = users;
      
      if (users.isEmpty) {
        print('ℹ️ No follow users found - user needs to follow someone first');
      } else {
        print('✅ Loaded ${users.length} follow users for chat');
      }
      
      // Trigger rebuild for GetBuilder
      update();
    } catch (e) {
      print('❌ Error loading follow users: $e');
      Get.snackbar(
        'Error',
        'Failed to load follow users: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Follow or unfollow user
  Future<void> toggleFollow(String targetUserId, String action) async {
    try {
     
      
      final success = await PHPChatService.toggleFollow(targetUserId, action);
      
      if (success) {
     
        // Refresh follow users list
        await loadFollowUsers();
        
        // Also refresh all users list if available
        await _refreshAllUsersList();
        
        final actionText = action == 'follow' ? 'followed' : 'unfollowed';
        Get.snackbar(
          'Success',
          'User $actionText successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Force UI update
        update();
      } else {
        print('❌ Follow action failed');
        Get.snackbar(
          'Error',
          'Failed to $action user',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error toggling follow: $e');
      Get.snackbar(
        'Error',
        'Failed to $action user: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Refresh all users list to update follow status
  Future<void> _refreshAllUsersList() async {
    try {
      // This will be implemented when we have getAllUsers functionality
      print('🔍 Refreshing all users list...');
    } catch (e) {
      print('❌ Error refreshing all users list: $e');
    }
  }
  
  Future<void> loadMessages(String roomId) async {
    try {
      final messages = await PHPChatService.getChatMessages(roomId);
      currentMessages.value = messages;
    } catch (e) {
      print('❌ Error loading messages: $e');
    }
  }
  
  Future<void> sendMessage(String message, {String? replyTo}) async {
    if (message.trim().isEmpty || currentRoom.value == null) return;
    
    try {
      final success = await PHPChatService.sendMessage(
        currentRoom.value!.id, 
        message.trim(),
        replyTo: replyTo,
      );
      
      if (success) {
        // Reload messages to show the new message
        await loadMessages(currentRoom.value!.id);
      } else {
        Get.snackbar('Error', 'Failed to send message');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }
  
  Future<void> sendGift(String giftId, {int quantity = 1}) async {
    if (currentRoom.value == null) return;
    
    try {
      // Get recipient ID from current room
      String recipientId = '';
      
      // Try to get recipient from participants
      for (var participantId in currentRoom.value!.participants) {
        if (participantId != currentUserId.value && participantId != 'current_user') {
          recipientId = participantId;
          break;
        }
      }
      
      // If not found in participants, try to get from otherUser
      if (recipientId.isEmpty && currentRoom.value!.otherUser != null) {
        recipientId = currentRoom.value!.otherUser!['id']?.toString() ?? 
                     currentRoom.value!.otherUser!['user_id']?.toString() ?? '';
      }
      
      if (recipientId.isEmpty) {
        print('❌ Unable to identify recipient. Participants: ${currentRoom.value!.participants}');
        print('❌ Current user ID: ${currentUserId.value}');
        Get.snackbar('Error', 'Unable to identify recipient');
        return;
      }
      
      print('🎁 Sending gift $giftId to recipient: $recipientId');
      
      final success = await GiftService.sendGift(recipientId, giftId, quantity: quantity);
      
      if (success) {
        Get.snackbar('Success', 'Gift sent successfully! 🎁');
        
        // Add gift message to chat
        final giftItem = _findGiftItem(giftId);
        if (giftItem != null) {
          final giftMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: currentRoom.value!.id,
            senderId: currentUserId.value,
            message: 'Sent ${giftItem.icon} ${giftItem.name}',
            timestamp: DateTime.now(),
            type: MessageType.gift,
            metadata: {
              'gift_id': giftItem.id,
              'gift_name': giftItem.name,
              'gift_icon': giftItem.icon,
            },
          );
          
          currentMessages.add(giftMessage);
        }
        
        // Refresh user coins
        await loadUserCoins();
        
        // Reload messages to show the gift in chat
        await loadMessages(currentRoom.value!.id);
      } else {
        // Error message is already shown by GiftService
      }
    } catch (e) {
      print('❌ Error sending gift: $e');
      Get.snackbar('Error', 'Failed to send gift: $e');
    }
  }
  
  GiftItem? _findGiftItem(String giftId) {
    for (var category in GiftService.giftCategories) {
      for (var gift in category.gifts) {
        if (gift.id == giftId) {
          return gift;
        }
      }
    }
    return null;
  }
  
  Future<void> startVoiceCall(String phoneNumber) async {
    try {
      // Initialize PHP service if not already done
      if (!PHPChatService.isInitialized) {
        await PHPChatService.initialize();
      }
      
      final success = await PHPChatService.startVoiceCall('voice_$phoneNumber');
      if (success) {
        Get.snackbar('Success', 'Call initiated! 📞');
      } else {
        Get.snackbar('Error', 'Failed to start voice call');
      }
    } catch (e) {
      print('❌ Error starting voice call: $e');
      Get.snackbar('Error', 'Failed to start voice call');
    }
  }
  
  Future<void> startVideoCall(String channelName) async {
    try {
      final success = await PHPChatService.startVideoCall(channelName);
      if (!success) {
        Get.snackbar('Error', 'Failed to start video call');
      }
    } catch (e) {
      print('❌ Error starting video call: $e');
      Get.snackbar('Error', 'Failed to start video call');
    }
  }
  
  // Create chat room with specific user
  Future<void> createChatRoomWithUser(String userId, Map<String, dynamic> userInfo) async {
    try {
      print('🔍 Creating chat room with user: ${userInfo['username']}');
      
      // Debug: Check current user data
      final currentUser = await AuthService.getCurrentUser();
      print('🔍 Current user data: $currentUser');
      
      final currentUserId = await AuthService.getCurrentUserId();
      print('🔍 Current user ID: $currentUserId');
      
      if (currentUserId == null) {
        print('❌ No current user ID found');
        
        // Try to get token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final userData = prefs.getString('user_data');
        print('🔍 Stored token: ${token != null ? 'exists' : 'null'}');
        print('🔍 Stored user data: ${userData != null ? 'exists' : 'null'}');
        
        Get.snackbar(
          'Error', 
          'Please login first',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Validate target user ID
      if (userId.isEmpty || userId == currentUserId) {
        print('❌ Invalid target user ID: $userId');
        Get.snackbar(
          'Error', 
          'Cannot create chat room with yourself',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      print('🔍 Creating chat room between $currentUserId and $userId');
      
      // Create chat room with user info
      final room = await PHPChatService.createChatRoom(currentUserId, userId, otherUserInfo: userInfo);
      if (room != null) {
        // Set as current room
        setCurrentRoom(room);
        
        // Refresh chat rooms list
        await loadChatRooms();
        
        // Show success message
        Get.snackbar(
          'Success',
          'Chat started with ${userInfo['username']}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        print('✅ Chat room created successfully: ${room.id}');
      } else {
        print('❌ Failed to create chat room - PHPChatService returned null');
        Get.snackbar(
          'Error', 
          'Failed to create chat room. Please check your connection and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error creating chat room: $e');
      Get.snackbar(
        'Error', 
        'Failed to create chat room: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void setCurrentRoom(ChatRoom? room) {
    currentRoom.value = room;
    if (room != null) {
      loadMessages(room.id);
      
      // Ensure we have the current user ID
      if (currentUserId.value.isEmpty) {
        // This will be handled in initializeChat
        print('🔍 Current user ID not set, will be set in initializeChat');
      }
      
      print('🔍 Set current room: ${room.id}');
      print('🔍 Room participants: ${room.participants}');
      print('🔍 Current user ID: ${currentUserId.value}');
    } else {
      currentMessages.clear();
    }
    // Trigger rebuild for GetBuilder
    update();
  }
  
  void clearCurrentRoom() {
    currentRoom.value = null;
    currentMessages.clear();
    // Trigger rebuild for GetBuilder
    update();
  }
  
  @override
  void onClose() {
    // Unregister callback
    RazorpayService.onCoinsUpdated = null;
    PHPChatService.dispose();
    super.onClose();
  }
} 