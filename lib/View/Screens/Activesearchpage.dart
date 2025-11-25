import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'UserProfilePage.dart';
import 'ChatPage.dart';
import 'PostDetailPage.dart';

class ActiveSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> postSearchResults = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<String> followLoadingUsers = <String>{}.obs;
  final RxInt currentTabIndex = 0.obs; // 0 for users, 1 for posts

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      searchResults.clear();
      postSearchResults.clear();
      hasSearched.value = false;
      errorMessage.value = '';
    } else if (query.length >= 2) {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      isLoading.value = true;
      hasSearched.value = true;
      errorMessage.value = '';
      
      print('🔍 Searching for: $query');
      
      // Search for users
      try {
        final userResult = await AuthService.searchUsers(query);
        if (userResult['success'] == true && userResult['users'] != null) {
          searchResults.value = List<Map<String, dynamic>>.from(userResult['users']);
          print('🔍 Found ${searchResults.length} users');
        } else {
          searchResults.clear();
          print('🔍 No users found or API error: ${userResult['message']}');
        }
      } catch (e) {
        print('❌ Error searching users: $e');
        searchResults.clear();
      }
      
      // Search for posts
      try {
        final postResult = await AuthService.searchPosts(query);
        if (postResult['success'] == true && postResult['posts'] != null) {
          postSearchResults.value = List<Map<String, dynamic>>.from(postResult['posts']);
          print('🔍 Found ${postSearchResults.length} posts');
        } else {
          postSearchResults.clear();
          print('🔍 No posts found or API error: ${postResult['message']}');
        }
      } catch (e) {
        print('⚠️ Post search not available: $e');
        postSearchResults.clear();
      }
      
      // Set error message if no results found
      if (searchResults.isEmpty && postSearchResults.isEmpty) {
        errorMessage.value = 'No results found for "$query"';
      } else {
        errorMessage.value = '';
      }
      
      print('🔍 Search completed - Users: ${searchResults.length}, Posts: ${postSearchResults.length}');
    } catch (e) {
      print('❌ Error searching: $e');
      searchResults.clear();
      postSearchResults.clear();
      errorMessage.value = 'Search failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void onUserTap(Map<String, dynamic> user) {
    print('🔍 User tapped: ${user['username']}');
    Get.to(() => UserProfilePage(userId: user['id'].toString()))?.then((_) {
      // Refresh search results when returning from profile
      if (searchController.text.trim().isNotEmpty) {
        _performSearch(searchController.text.trim());
      }
    });
  }

  void onPostTap(Map<String, dynamic> post) {
    print('🔍 Post tapped: ${post['id']}');
    // Navigate to PostDetailPage with all posts for swipe functionality
    final allPosts = postSearchResults.toList();
    final initialIndex = allPosts.indexWhere((p) => p['id'] == post['id']);
    
    if (initialIndex != -1) {
      Get.to(() => PostDetailPage(
        post: post,
        allPosts: allPosts,
        initialIndex: initialIndex,
      ));
    } else {
      // Fallback to user profile if post not found
      Get.to(() => UserProfilePage(userId: post['user_id'].toString()));
    }
  }

  Future<void> onFollowTap(Map<String, dynamic> user) async {
    try {
      // Check for guest mode first
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('is_guest_user') ?? false;
      
      if (isGuest) {
        Get.snackbar(
          'Sign Up Required',
          'Please sign up to follow other users',
          backgroundColor: Color(0xFF535AF4),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      print('🔍 Toggling follow for user: ${user['username']}');
      
      // Set loading state for this specific user
      followLoadingUsers.add(user['id'].toString());
      
      // Find the user index
      final index = searchResults.indexWhere((u) => u['id'] == user['id']);
      if (index == -1) return;
      
      final isCurrentlyFollowing = searchResults[index]['is_following'] == true;
      
      // Call appropriate API based on current status
      final result = isCurrentlyFollowing 
          ? await AuthService.unfollowUser(user['id'].toString())
          : await AuthService.followUser(user['id'].toString());
      
      // Update the UI based on the response
      searchResults[index]['is_following'] = result['is_following'] ?? false;
      searchResults.refresh();
      
      // Show success message
      final action = searchResults[index]['is_following'] == true ? 'following' : 'unfollowed';
      Get.snackbar(
        'Success!',
        'Successfully $action ${user['username']}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error toggling follow: $e');
      Get.snackbar(
        'Error',
        'Failed to update follow status: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Remove loading state for this user
      followLoadingUsers.remove(user['id'].toString());
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class Activesearchpage extends StatefulWidget {
  const Activesearchpage({Key? key}) : super(key: key);

  @override
  State<Activesearchpage> createState() => _ActivesearchpageState();
}

class _ActivesearchpageState extends State<Activesearchpage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Update the controller's current tab index
      final controller = Get.find<ActiveSearchController>();
      controller.currentTabIndex.value = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Start chat with user
  void _startChatWithUser(Map<String, dynamic> user) {
    try {
      print('🔍 Starting chat with user from search: ${user['username']}');
      print('🔍 Raw user data: $user');
      
      // Ensure we have the required fields
      if (user['id'] == null) {
        print('❌ User ID is null in search results');
        Get.snackbar(
          'Error',
          'Invalid user information',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Create properly formatted user data for ChatPage
      final userData = {
        'id': user['id'].toString(),
        'username': user['username'] ?? 'Unknown',
        'full_name': user['full_name'] ?? user['username'] ?? 'Unknown',
        'profile_picture': user['profile_picture'] ?? '',
      };
      
      print('🔍 Formatted user data for chat: $userData');
      
      // Navigate to chat page with user info
      Get.to(() => ChatPage(), arguments: {
        'user_id': user['id'],
        'username': user['username'],
        'full_name': user['full_name'],
        'profile_picture': user['profile_picture'],
        'open_direct_chat': true, // Add this flag
      });
    } catch (e) {
      print('❌ Error starting chat: $e');
      Get.snackbar(
        'Error',
        'Failed to start chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildUserTile(Map<String, dynamic> user, ActiveSearchController controller) {
    print('🔍 Building user tile for: ${user['username']}');
    print('🔍 User data: $user');
    
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(
          user['profile_picture'] ?? '',
        ),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle error
        },
      ),
      title: Text(
        user['username'] ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user['full_name'] != null && user['full_name'].isNotEmpty)
            Text(
              user['full_name'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          Row(
            children: [
              if (user['is_private'] == true)
                Icon(
                  Icons.lock,
                  size: 14,
                  color: Colors.grey[500],
                ),
              SizedBox(width: 4),
              Text(
                '${user['public_posts_count']} posts',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${user['followers_count']} followers',
                style: TextStyle(
                  color: Colors.grey[500],
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
          // Chat Button
          GestureDetector(
            onTap: () {
              print('🔍 Chat button tapped for: ${user['username']}');
              _startChatWithUser(user);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Follow/Unfollow Button
          Obx(() {
            final isLoading = controller.followLoadingUsers.contains(user['id'].toString());
            
            return GestureDetector(
              onTap: isLoading ? null : () {
                print('🔍 Follow/Unfollow button tapped for: ${user['username']}');
                controller.onFollowTap(user);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user['is_following'] == true ? Colors.grey[200] : Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading) ...[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                          user['is_following'] == true ? (Colors.grey[700] ?? Colors.grey) : Colors.white,
                        ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ] else if (user['is_following'] == true) ...[
                      Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8),
                    ],
                    Text(
                      isLoading 
                          ? 'Updating...' 
                          : (user['is_following'] == true ? 'Following' : 'Follow'),
                      style: TextStyle(
                        color: user['is_following'] == true ? Colors.grey[700] : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      onTap: () => controller.onUserTap(user),
    );
  }

  Widget _buildPostTile(Map<String, dynamic> post, ActiveSearchController controller) {
    print('🔍 Building post tile for: ${post['id']}');
    print('🔍 Post data: $post');

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: post['media_url'] ?? '',
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: Icon(Icons.image, color: Colors.grey.shade400),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        post['caption'] ?? 'No caption',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By ${post['username'] ?? 'Unknown'}',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.favorite, size: 12, color: Colors.red),
              SizedBox(width: 4),
              Text(
                '${post['likes_count'] ?? 0}',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(width: 12),
              Icon(Icons.comment, size: 12, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                '${post['comments_count'] ?? 0}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      onTap: () => controller.onPostTap(post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveSearchController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Search',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search users or posts...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Users'),
                Tab(text: 'Posts'),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Users Tab
                _buildUsersTab(controller),
                // Posts Tab
                _buildPostsTab(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(ActiveSearchController controller) {
    return Obx(() {
      print('🔍 Building Users Tab - isLoading: ${controller.isLoading.value}, hasSearched: ${controller.hasSearched.value}');
      print('🔍 Users count: ${controller.searchResults.length}');
      print('🔍 Error message: ${controller.errorMessage.value}');
      
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Searching...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              SizedBox(height: 16),
              Text(
                'Search Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (!controller.hasSearched.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Search for users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enter a username or full name to search',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No users found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try searching with a different username',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = controller.searchResults[index];
          print('🔍 Building user tile for: ${user['username']}');
          return _buildUserTile(user, controller);
        },
      );
    });
  }

  Widget _buildPostsTab(ActiveSearchController controller) {
    return Obx(() {
      print('🔍 Building Posts Tab - isLoading: ${controller.isLoading.value}, hasSearched: ${controller.hasSearched.value}');
      print('🔍 Posts count: ${controller.postSearchResults.length}');
      print('🔍 Error message: ${controller.errorMessage.value}');
      
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Searching...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              SizedBox(height: 16),
              Text(
                'Search Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (!controller.hasSearched.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Search for posts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enter keywords to search posts',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (controller.postSearchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No posts found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.postSearchResults.length,
        itemBuilder: (context, index) {
          final post = controller.postSearchResults[index];
          print('🔍 Building post tile for: ${post['id']}');
          return _buildPostTile(post, controller);
        },
      );
    });
  }
}
