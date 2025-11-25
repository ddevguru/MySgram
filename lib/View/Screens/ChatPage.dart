import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Controller/ChatController.dart';
import '../../services/php_chat_service.dart';
import '../../services/auth_service.dart';
import '../../services/gift_service_simple.dart';
import 'dart:convert';
import 'WalletPage.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic>? userInfo;
  
  const ChatPage({super.key, this.userInfo});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatController chatController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<ChatRoom> _chatRooms = [];
  List<Map<String, dynamic>> _followUsers = [];
  ChatRoom? _currentRoom;
  List<ChatMessage> _currentMessages = [];
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    
    // Initialize chat controller
    chatController = Get.put(ChatController());
    
    // Load initial data
    _loadInitialData();
    
    // Check if arguments were passed (for direct chat or post sharing)
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      print('🔍 ChatPage received arguments: $arguments');
      
      // Check if we should open a direct chat
      if (arguments['open_direct_chat'] == true) {
        print('🔍 Opening direct chat with user: ${arguments['username']}');
        
        // Create a properly formatted user object from arguments
        final userData = {
          'id': arguments['user_id'],
          'username': arguments['username'],
          'full_name': arguments['full_name'],
          'profile_picture': arguments['profile_picture'],
        };
        
        print('🔍 Formatted user data from arguments: $userData');
        _startChatWithUser(userData);
      }
      
      // Check if we should share a post
      if (arguments['share_post'] == true) {
        print('🔍 Sharing post via chat');
        _showPostSharingDialog(arguments['post_data']);
      }
    }
    
    // If user info is provided via widget, start chat with that user
    if (widget.userInfo != null) {
      print('🔍 Using widget user info: ${widget.userInfo}');
      _startChatWithUser(widget.userInfo!);
    }
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load chat rooms and follow users
      await chatController.loadChatRooms();
      await chatController.loadFollowUsers();
      
      // Get current user ID
      _currentUserId = await AuthService.getCurrentUserId() ?? '';
      
      // Update local state
      setState(() {
        _chatRooms = chatController.chatRooms;
        _followUsers = chatController.followUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading initial data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllMessagesAsSeen() async {
    if (_currentRoom == null) return;
    
    try {
      await PHPChatService.markAllMessagesAsSeen(_currentRoom!.id);
      print('✅ All messages marked as seen in room: ${_currentRoom!.id}');
    } catch (e) {
      print('❌ Error marking messages as seen: $e');
    }
  }
  
  // Start chat with a user
  void _startChatWithUser(Map<String, dynamic> user) async {
    try {
      print('🔍 Starting chat with user: ${user['username']}');
      print('🔍 User data received: $user');
      
      // Check if chat room already exists
      ChatRoom? existingRoom;
      try {
        final userId = _extractUserId(user);
        if (userId == null) {
          print('❌ Could not extract user ID from user data');
          Get.snackbar(
            'Error',
            'Invalid user information',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        existingRoom = _chatRooms.firstWhere(
          (room) => room.participants.contains(userId),
        );
      } catch (e) {
        existingRoom = null;
      }
      
      if (existingRoom != null) {
        print('🔍 Existing chat room found: ${existingRoom.id}');
        // Open existing chat room
        if (mounted) {
          setState(() {
            _currentRoom = existingRoom;
          });
        }
        
        // Load messages directly from PHP service
        final messages = await PHPChatService.getChatMessages(existingRoom.id);
        if (mounted) {
          setState(() {
            _currentMessages = messages;
          });
        }
        
        _markAllMessagesAsSeen();
      } else {
        print('🔍 Creating new chat room for user: ${user['username']}');
        
        // Ensure we have valid user IDs
        final currentUserId = await AuthService.getCurrentUserId();
        if (currentUserId == null) {
          print('❌ No current user ID found');
          Get.snackbar(
            'Error',
            'Please login first',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        final targetUserId = _extractUserId(user);
        if (targetUserId == null || targetUserId.isEmpty) {
          print('❌ Invalid target user ID');
          print('❌ User data: $user');
          Get.snackbar(
            'Error',
            'Invalid user information',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        // Validate that we're not trying to chat with ourselves
        if (targetUserId == currentUserId) {
          print('❌ Cannot create chat room with yourself');
          Get.snackbar(
            'Error',
            'Cannot start a chat with yourself',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        print('🔍 Creating chat room between $currentUserId and $targetUserId');
        
        // Create new chat room using the existing method
        await chatController.createChatRoomWithUser(targetUserId, user);
        
        // Wait a bit for the room to be created, then refresh
        await Future.delayed(Duration(milliseconds: 500));
        await chatController.loadChatRooms();
        
        // Update local state with new chat rooms
        if (mounted) {
          setState(() {
            _chatRooms = chatController.chatRooms;
          });
        }
        
        // Find the newly created room
        ChatRoom? newRoom;
        try {
          newRoom = _chatRooms.firstWhere(
            (room) => room.participants.contains(targetUserId),
          );
        } catch (e) {
          newRoom = null;
        }
        
        if (newRoom != null && mounted) {
          setState(() {
            _currentRoom = newRoom;
            _currentMessages = [];
          });
          
          print('🔍 New chat room created: ${newRoom.id}');
        } else if (newRoom == null) {
          print('❌ Failed to create chat room');
          if (mounted) {
            Get.snackbar(
              'Error', 
              'Failed to create chat room. Please try again.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
      
      print('🔍 Chat started successfully with: ${user['username']}');
      
    } catch (e) {
      print('❌ Error starting chat: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to start chat: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
  
  // Helper method to extract user ID from different data structures
  String? _extractUserId(Map<String, dynamic> user) {
    // Try different possible field names for user ID
    final possibleFields = ['id', 'user_id', 'userId'];
    
    for (final field in possibleFields) {
      final value = user[field];
      if (value != null && value.toString().isNotEmpty) {
        print('🔍 Found user ID in field "$field": $value');
        return value.toString();
      }
    }
    
    print('❌ Could not find user ID in user data');
    print('❌ Available fields: ${user.keys.toList()}');
    return null;
  }
  
  // Helper method to check if user is online
  bool _isUserOnline(Map<String, dynamic>? user) {
    if (user == null) return false;
    
    final isOnline = user['is_online'] ?? false;
    final lastSeen = user['last_seen'];
    
    if (isOnline == true) {
      return true;
    }
    
    // If not explicitly online, check last seen time
    if (lastSeen != null) {
      try {
        final lastSeenTime = DateTime.parse(lastSeen);
        final now = DateTime.now();
        final difference = now.difference(lastSeenTime);
        
        // Consider user online if last seen within last 5 minutes
        return difference.inMinutes < 5;
      } catch (e) {
        print('❌ Error parsing last_seen: $e');
      }
    }
    
    return false;
  }
  
  // Helper method to get online status text
  String _getOnlineStatus(Map<String, dynamic>? user) {
    if (user == null) return 'Offline';
    
    if (_isUserOnline(user)) {
      return 'Online';
    }
    
    final lastSeen = user['last_seen'];
    if (lastSeen != null) {
      try {
        final lastSeenTime = DateTime.parse(lastSeen);
        final now = DateTime.now();
        final difference = now.difference(lastSeenTime);
        
        if (difference.inDays > 0) {
          return '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes}m ago';
        } else {
          return 'Just now';
        }
      } catch (e) {
        print('❌ Error parsing last_seen for status: $e');
      }
    }
    
    return 'Offline';
  }
  
  // Toggle follow/unfollow user
  void _toggleFollow(String userId, String action) async {
    try {
      print('🔍 Frontend: Toggling follow: $action for user: $userId');
      await chatController.toggleFollow(userId, action);
      
      // Refresh follow users list
      await chatController.loadFollowUsers();
      
      // Update local state
      if (mounted) {
        setState(() {
          _followUsers = chatController.followUsers;
        });
      }
      
      print('🔍 Frontend: Follow action completed, UI refreshed');
    } catch (e) {
      print('❌ Error toggling follow: $e');
    }
  }
  
  // Show users list popup modal
  void _showUsersListModal() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    'All Users',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
            
            // Users list
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: PHPChatService.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  
                  final users = snapshot.data ?? [];
                  
                  if (users.isEmpty) {
                    return Center(
                      child: Text('No users found'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserTileForModal(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserTileForModal(Map<String, dynamic> user) {
    final displayName = user['full_name'] ?? user['username'] ?? 'Unknown';
    final isFollowing = user['is_following'] ?? false;
    
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: user['profile_picture'] != null
            ? CachedNetworkImageProvider(user['profile_picture'])
            : null,
        child: user['profile_picture'] == null
            ? Icon(Icons.person, size: 25)
            : null,
      ),
      title: Text(
        displayName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '@${user['username']}',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Follow/Unfollow button
          if (!isFollowing)
            IconButton(
              onPressed: () {
                Get.back(); // Close modal
                _toggleFollow(user['id'].toString(), 'follow');
              },
              icon: Icon(Icons.person_add, color: Colors.blue, size: 20),
              tooltip: 'Follow',
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            )
          else
            IconButton(
              onPressed: () {
                Get.back(); // Close modal
                _toggleFollow(user['id'].toString(), 'unfollow');
              },
              icon: Icon(Icons.person_remove, color: Colors.red, size: 20),
              tooltip: 'Unfollow',
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          
          SizedBox(width: 8),
          
          // Chat button
          SizedBox(
            width: 70,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close modal
                _startChatWithUser(user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7D64FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _initializeChat() async {
    await PHPChatService.initialize();
    await _loadChatRooms();
    
    // Listen to purchase updates
    GiftService.purchaseUpdates.listen((purchases) {
      for (var purchase in purchases) {
        GiftService.processPurchase(purchase);
      }
      _loadUserCoins(); // Refresh coins after purchase
    });
  }
  
  Future<void> _loadUserCoins() async {
    await chatController.loadUserCoins();
  }
  
  Future<void> _loadChatRooms() async {
    await chatController.loadChatRooms();
  }
  
  Future<void> _loadMessages(String roomId) async {
    await chatController.loadMessages(roomId);
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentRoom == null) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    try {
      final success = await PHPChatService.sendMessage(
        _currentRoom!.id,
        message,
      );
      
      if (success && mounted) { // Check if widget is still mounted
        // Reload messages to show the new message
        final messages = await PHPChatService.getChatMessages(_currentRoom!.id);
        
        if (mounted) { // Check again before setState
          setState(() {
            _currentMessages = messages;
          });
          
          // Scroll to bottom
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      } else if (!success) {
        Get.snackbar('Error', 'Failed to send message');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      if (mounted) { // Only show snackbar if widget is mounted
        Get.snackbar('Error', 'Failed to send message: $e');
      }
    }
  }
  
  Future<void> _startVoiceCall(String phoneNumber) async {
    final success = await PHPChatService.startVoiceCall(phoneNumber);
    if (!success) {
      Get.snackbar('Error', 'Failed to start voice call');
    }
  }
  
  Future<void> _startVideoCall(String channelName) async {
    // In a real app, you would get the token from your backend
    final success = await PHPChatService.startVideoCall(channelName);
    if (!success) {
      Get.snackbar('Error', 'Failed to start video call');
    }
  }
  
  void _showGiftDialog() {
    if (_currentRoom == null) {
      Get.snackbar('Error', 'No active chat room');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Gift'),
        content: Text('Gift functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _purchaseCoins(String productId) async {
    try {
      final success = await GiftService.purchaseCoins(productId);
      if (success) {
        Get.back(); // Close buy coins dialog
        Get.snackbar('Success', 'Purchase initiated successfully');
      } else {
        Get.snackbar('Error', 'Failed to initiate purchase');
      }
    } catch (e) {
      Get.snackbar('Error', 'Purchase failed: $e');
    }
  }
  
  Future<void> _sendGift(GiftItem gift) async {
    if (_currentRoom == null) return;
    
    // Use the controller to send gift
    await chatController.sendGift(gift.id, quantity: 1);
    Get.back(); // Close gift dialog
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF7D64FF),
        foregroundColor: Colors.white,
        title: Text('Chats'),
        elevation: 0,
        actions: [
          // Wallet button
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () => Get.to(() => WalletPage()),
            tooltip: 'Wallet',
          ),
          // Plus button to show all users
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showUsersListModal,
            tooltip: 'Add new chat',
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Chat rooms list or follow users list
          _currentRoom == null
            ? Expanded(child: _buildChatList())
            : Expanded(child: _buildChatMessages()),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Color(0xFF7D64FF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF7D64FF),
              tabs: [
                Tab(text: 'Chats (${_chatRooms.length})'),
                Tab(text: 'Follow Users (${_followUsers.length})'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildChatRoomsList(),
                _buildFollowUsersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
        ),
      );
    }
    
    if (_chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation with someone!',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        final room = _chatRooms[index];
        return _buildChatRoomTile(room);
      },
    );
  }
  
  Widget _buildFollowUsersList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
        ),
      );
    }
    
    if (_followUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No follow users yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Follow someone to start chatting!',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: _followUsers.length,
      itemBuilder: (context, index) {
        final user = _followUsers[index];
        return _buildFollowUserTile(user);
      },
    );
  }

  Widget _buildChatMessages() {
    return SafeArea(
      child: Column(
        children: [
          // Chat header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _currentRoom = null;
                        _currentMessages = [];
                      });
                    }
                  },
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _currentRoom != null
                    ? Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: _currentRoom!.otherUser?['profile_picture'] != null
                                ? CachedNetworkImageProvider(_currentRoom!.otherUser!['profile_picture'])
                                : null,
                            backgroundColor: Color(0xFF7D64FF),
                            child: _currentRoom!.otherUser?['profile_picture'] == null
                                ? Icon(Icons.person, size: 20, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentRoom!.otherUser?['full_name'] ?? _currentRoom!.otherUser?['username'] ?? 'Unknown User',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _getOnlineStatus(_currentRoom!.otherUser),
                                  style: TextStyle(
                                    color: _isUserOnline(_currentRoom!.otherUser) ? Colors.green : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Text('Chat', style: TextStyle(fontSize: 16)),
                ),
                // Gift button
                IconButton(
                  icon: Icon(Icons.card_giftcard, color: Colors.orange),
                  onPressed: _showGiftDialog,
                  tooltip: 'Send Gift',
                ),
              ],
            ),
          ),
          
          // Messages - This should take most of the space
          Expanded(
            child: _currentMessages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = _currentMessages[index];
                    final isMe = message.senderId == _currentUserId;
                    
                    return _buildMessageBubble(message, isMe);
                  },
                ),
          ),
          
          // Message Input - This should be at the bottom
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildChatRoomTile(ChatRoom room) {
    final otherUser = room.otherUser;
    final lastMessage = room.lastMessage;
    
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: otherUser?['profile_picture'] != null
            ? CachedNetworkImageProvider(otherUser!['profile_picture'])
            : null,
        backgroundColor: Color(0xFF7D64FF),
        child: otherUser?['profile_picture'] == null
            ? Icon(Icons.person, size: 25, color: Colors.white)
            : null,
      ),
      title: Text(
        otherUser?['full_name'] ?? otherUser?['username'] ?? 'Unknown User',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMessage?.message ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(lastMessage?.timestamp ?? DateTime.now()),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          if (room.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${room.unreadCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () async {
        print('🔍 Chat room tapped: ${room.id}');
        
        // Set current room
        if (mounted) {
          setState(() {
            _currentRoom = room;
          });
        }
        
        // Load messages directly from PHP service
        try {
          final messages = await PHPChatService.getChatMessages(room.id);
          if (mounted) {
            setState(() {
              _currentMessages = messages;
            });
          }
          
          // Mark messages as seen
          _markAllMessagesAsSeen();
          
          // Scroll to bottom
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          
          print('🔍 Chat room opened: ${room.id}');
        } catch (e) {
          print('❌ Error loading messages: $e');
          if (mounted) {
            Get.snackbar(
              'Error',
              'Failed to load messages: $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      },
    );
  }

  Widget _buildFollowUserTile(Map<String, dynamic> user) {
    final relationshipType = user['relationship_type'] ?? 'none';
    final displayName = user['display_name'] ?? user['username'] ?? 'Unknown';
    
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: user['profile_picture'] != null
            ? CachedNetworkImageProvider(user['profile_picture'])
            : null,
        child: user['profile_picture'] == null
            ? Icon(Icons.person, size: 25)
            : null,
      ),
      title: Text(
        displayName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${user['username']}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Row(
            children: [
              Icon(
                relationshipType == 'following' ? Icons.person_add : Icons.person,
                size: 14,
                color: relationshipType == 'following' ? Colors.blue : Colors.green,
              ),
              SizedBox(width: 4),
              Text(
                relationshipType == 'following' ? 'Following' : 'Follows you',
                style: TextStyle(
                  color: relationshipType == 'following' ? Colors.blue : Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Follow/Unfollow button
          Builder(
            builder: (context) {
              // Get fresh data from local state
              final freshUser = _followUsers.firstWhere(
                (u) => u['id'].toString() == user['id'].toString(),
                orElse: () => user,
              );
              
              final isFollowing = freshUser['is_following'] == true || 
                                 freshUser['relationship_type'] == 'following';
              
              if (!isFollowing) {
                return IconButton(
                  onPressed: () => _toggleFollow(user['id'].toString(), 'follow'),
                  icon: Icon(Icons.person_add, color: Colors.blue, size: 20),
                  tooltip: 'Follow',
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                );
              } else {
                return IconButton(
                  onPressed: () => _toggleFollow(user['id'].toString(), 'unfollow'),
                  icon: Icon(Icons.person_remove, color: Colors.red, size: 20),
                  tooltip: 'Unfollow',
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                );
              }
            },
          ),
          
          SizedBox(width: 8),
          
          // Chat button
          SizedBox(
            width: 70,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                print('🔍 Chat button clicked for user: ${user['username']}');
                _startChatWithUser(user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7D64FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      onTap: () {
        print('🔍 Follow user tapped: ${user['username']}');
        _startChatWithUser(user);
      },
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // Other user's profile picture
            CircleAvatar(
              radius: 16,
              backgroundImage: message.metadata?['sender_photo'] != null
                  ? CachedNetworkImageProvider(message.metadata!['sender_photo'])
                  : null,
              backgroundColor: Color(0xFF7D64FF),
              child: message.metadata?['sender_photo'] == null
                  ? Icon(Icons.person, size: 16, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 8),
          ],
          
          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
                minWidth: 0,
              ),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Color(0xFF7D64FF) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message text
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Message info row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 8),
                        Icon(
                          message.isSeen ? Icons.done_all : Icons.done,
                          size: 16,
                          color: message.isSeen ? Colors.blue : Colors.white70,
                        ),
                        if (message.isSeen && message.seenAt != null) ...[
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Seen ${_formatTime(message.seenAt!)}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) ...[
            SizedBox(width: 8),
            // Current user's profile picture
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF7D64FF),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildGiftMessage(ChatMessage message) {
    final giftIcon = message.metadata?['gift_icon'] ?? '🎁';
    final giftName = message.metadata?['gift_name'] ?? 'Gift';
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          giftIcon,
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(width: 8),
        Text(
          giftName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Message text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Send button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return Container(
                decoration: BoxDecoration(
                  color: hasText ? Color(0xFF7D64FF) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: hasText ? _sendMessage : null,
                  icon: Icon(
                    Icons.send,
                    color: hasText ? Colors.white : Colors.grey.shade500,
                  ),
                  tooltip: 'Send message',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  

  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // Show dialog for sharing post with followers/following
  void _showPostSharingDialog(dynamic postData) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.share, color: Color(0xFF7D64FF)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Share Post via Chat',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Post preview
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    // Post image thumbnail
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            postData['media_url'] ?? postData['postImage'] ?? '',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Post details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Post by ${postData['username'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            postData['caption'] ?? 'No caption',
                            style: TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Instructions
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF7D64FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Color(0xFF7D64FF), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select a user from your followers/following to share this post with via chat',
                        style: TextStyle(
                          color: Color(0xFF7D64FF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Users list
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_followUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users to share with',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Follow some users first to share posts with them',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _followUsers.length,
                      itemBuilder: (context, index) {
                        final user = _followUsers[index];
                        return _buildPostSharingUserTile(user, postData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Build user tile for post sharing
  Widget _buildPostSharingUserTile(Map<String, dynamic> user, dynamic postData) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user['profile_picture'] != null
            ? CachedNetworkImageProvider(user['profile_picture'])
            : null,
        backgroundColor: Color(0xFF7D64FF),
        child: user['profile_picture'] == null
            ? Icon(Icons.person, size: 20, color: Colors.white)
            : null,
      ),
      title: Text(
        user['full_name'] ?? user['username'] ?? 'Unknown User',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '@${user['username']}',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: ElevatedButton(
        onPressed: () => _sharePostWithUser(user, postData),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7D64FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text('Share'),
      ),
      onTap: () => _sharePostWithUser(user, postData),
    );
  }

  // Share post with specific user via chat
  void _sharePostWithUser(Map<String, dynamic> user, dynamic postData) {
    // Close the sharing dialog
    Get.back();
    
    // Start chat with the user
    _startChatWithUser(user);
    
    // Store the post data to send when chat opens
    chatController.postToShare.value = postData;
    
    // Wait a bit for chat to load, then send the post
    Future.delayed(Duration(milliseconds: 500), () {
      _sendPostAsMessage(postData);
    });
    
    Get.snackbar(
      'Post Shared!',
      'Post shared with ${user['full_name'] ?? user['username']} via chat',
      backgroundColor: Color(0xFF7D64FF),
      colorText: Colors.white,
    );
  }

  // Send post as a message in chat
  void _sendPostAsMessage(dynamic postData) {
    try {
      final caption = postData['caption'] ?? 'Check out this post!';
      final mediaUrl = postData['media_url'] ?? postData['postImage'] ?? '';
      final username = postData['username'] ?? 'Unknown';
      
      // Create a formatted post message
      final postMessage = '''
📸 **Post by @$username**

$caption

🔗 View post: $mediaUrl

Shared from MySgram
      '''.trim();
      
      // Set the message in controller
      _messageController.text = postMessage;
      
      // Send the message
      _sendMessage();
      
      // Clear the post to share
      chatController.postToShare.value = null;
      
    } catch (e) {
      print('❌ Error sending post as message: $e');
      Get.snackbar(
        'Error',
        'Failed to share post via chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 