import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/php_chat_service.dart';
import 'ChatPage.dart';

class FollowersFollowingPage extends StatefulWidget {
  final String userId;
  final String username;
  final String type; // 'followers' or 'following'

  const FollowersFollowingPage({
    Key? key,
    required this.userId,
    required this.username,
    required this.type,
  }) : super(key: key);

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('🔍 Loading ${widget.type} for user ID: ${widget.userId}');
      
      // For now, let's use a simple approach - get all users and filter
      // This is a temporary solution until the backend APIs are working
      print('🔍 Using temporary solution - getting all users...');
      
      // Get current user's follow users and filter based on type
      final allUsers = await PHPChatService.getFollowUsers();
      print('🔍 All follow users: ${allUsers.length}');
      
      if (widget.type == 'followers') {
        // For followers, we need to check who follows the target user
        // This is a simplified approach - in real app, use the backend API
        users = allUsers.where((user) => user['id'].toString() != widget.userId).toList();
        print('🔍 Filtered followers: ${users.length}');
      } else {
        // For following, show all users the current user follows
        users = allUsers;
        print('🔍 Following users: ${users.length}');
      }

      print('🔍 Loaded ${users.length} users');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      print('❌ Error loading ${widget.type}: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error stack trace: ${e.toString()}');
    }
  }

  Future<void> _toggleFollow(String userId, String action) async {
    try {
      print('🔍 Toggling follow: $action for user: $userId');
      
      // Use PHPChatService for now
      final success = await PHPChatService.toggleFollow(userId, action);
      
      if (success) {
        // Update the user's follow status in the list
        final index = users.indexWhere((user) => user['id'].toString() == userId);
        if (index != -1) {
          setState(() {
            users[index]['is_following'] = action == 'follow';
          });
        }

        final actionText = action == 'follow' ? 'followed' : 'unfollowed';
        Get.snackbar(
          'Success',
          'User $actionText successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Refresh the users list
        _loadUsers();
      } else {
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
        'Failed to $action user: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startChatWithUser(Map<String, dynamic> user) {
    print('🔍 Starting chat with user: ${user['username']}');
    print('🔍 User data: $user');
    
    // Navigate to chat page with user info
    Get.to(() => ChatPage(), arguments: {
      'user_id': user['id'],
      'username': user['username'],
      'full_name': user['full_name'] ?? user['username'],
      'profile_picture': user['profile_picture'],
      'open_direct_chat': true, // Flag to indicate we want to open direct chat
    })?.then((_) {
      // Refresh the users list when returning from chat
      _loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.type == 'followers' ? 'Followers' : 'Following'}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error loading ${widget.type}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.type == 'followers' ? Icons.people_outline : Icons.person_add_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ${widget.type} yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.type == 'followers' 
                  ? 'When people follow you, they\'ll appear here'
                  : 'People you follow will appear here',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final isFollowing = user['is_following'] == true;
    
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
        user['full_name'] ?? user['username'] ?? 'Unknown',
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
          SizedBox(
            width: 70,
            height: 36,
            child: ElevatedButton(
              onPressed: () => _toggleFollow(
                user['id'].toString(),
                isFollowing ? 'unfollow' : 'follow',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: 6),
          // Message button
          SizedBox(
            width: 70,
            height: 36,
            child: ElevatedButton(
              onPressed: () => _startChatWithUser(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7D64FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                'Chat',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        // Navigate to user profile
        Get.back(); // Close this page first
        // You can add navigation to user profile here if needed
      },
    );
  }
} 