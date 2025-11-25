import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'PostDetailPage.dart';
import 'FollowersFollowingPage.dart';
import 'ChatPage.dart';

class UserProfileController extends GetxController {
  final String userId;
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> userPosts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFollowing = false.obs;
  final RxBool isPrivate = false.obs;
  final RxBool isFollowLoading = false.obs; // Add loading state for follow button

  UserProfileController(this.userId);

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      print('🔍 Loading user profile for ID: $userId');
      
      final result = await AuthService.getUserProfile(userId);
      print('🔍 User profile result: $result');
      
      if (result['user'] != null) {
        userProfile.value = result['user'];
        isPrivate.value = result['user']['is_private'] == true;
        isFollowing.value = result['user']['is_following'] ?? false;
        
        print('🔍 User profile loaded: ${userProfile.value}');
        print('🔍 User ID: ${userProfile.value['user_id']}');
        print('🔍 Username: ${userProfile.value['username']}');
        print('🔍 Followers count: ${userProfile.value['followers_count']}');
        print('🔍 Following count: ${userProfile.value['following_count']}');
        print('🔍 Is following: ${isFollowing.value}');
        print('🔍 Is private: ${isPrivate.value}');
      } else {
        print('❌ No user data in response');
        // Set default values to prevent infinite loading
        userProfile.value = {
          'user_id': userId,
          'username': 'Unknown User',
          'full_name': 'Unknown User',
          'profile_picture': '',
          'is_private': false,
          'is_following': false,
        };
        isFollowing.value = false;
        isPrivate.value = false;
      }
      
      if (result['posts'] != null && !isPrivate.value) {
        userPosts.value = List<Map<String, dynamic>>.from(result['posts']);
        print('🔍 Loaded ${userPosts.length} posts');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      // Set default values to prevent infinite loading
      userProfile.value = {
        'user_id': userId,
        'username': 'Unknown User',
        'full_name': 'Unknown User',
        'profile_picture': '',
        'is_private': false,
        'is_following': false,
      };
      isFollowing.value = false;
      isPrivate.value = false;
      
      Get.snackbar(
        'Error',
        'Failed to load user profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> followUser() async {
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

    if (isFollowLoading.value) return; // Prevent multiple requests
    
    try {
      isFollowLoading.value = true;
      
      print('🔍 Current follow status: ${isFollowing.value}');
      print('🔍 About to call: ${isFollowing.value ? "unfollowUser" : "followUser"}');
      
      // If already following, unfollow. Otherwise, follow
      final result = isFollowing.value 
          ? await AuthService.unfollowUser(userId)
          : await AuthService.followUser(userId);
      
      print('🔍 API response: $result');
      
      // Update the following status based on the response
      final newFollowStatus = result['is_following'] ?? false;
      print('🔍 New follow status from API: $newFollowStatus');
      
      isFollowing.value = newFollowStatus;
      print('🔍 Updated isFollowing.value to: ${isFollowing.value}');
      
      // Show success message
      final action = isFollowing.value ? 'following' : 'unfollowed';
      Get.snackbar(
        'Success',
        'Successfully $action user',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Force refresh the UI
      isFollowing.refresh();
      
      // Also update the userProfile to reflect the new follow status
      userProfile.value['is_following'] = isFollowing.value;
      userProfile.refresh();
      
    } catch (e) {
      print('❌ Error following/unfollowing user: $e');
      Get.snackbar(
        'Error',
        'Failed to update follow status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isFollowLoading.value = false;
    }
  }

  void onPostTap(Map<String, dynamic> post) {
    // Find the index of the tapped post
    int postIndex = userPosts.indexWhere((p) => p['id'] == post['id']);
    if (postIndex == -1) postIndex = 0; // Fallback to first post
    
    Get.to(() => PostDetailPage(
      post: post,
      allPosts: userPosts,
      initialIndex: postIndex,
    ));
  }
}

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.userProfile['username'] ?? 'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadUserProfile,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(controller),
                _buildProfileStats(controller),
                _buildFollowButton(controller),
                if (controller.isFollowing.value) ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Tap "Following" to unfollow',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildBio(controller),
                _buildPostsGrid(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserProfileController controller) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 40,
            backgroundImage: CachedNetworkImageProvider(
              controller.userProfile['profile_picture'] ?? '',
            ),
          ),
          SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userProfile['username'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  controller.userProfile['full_name'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(UserProfileController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Posts', controller.userPosts.length.toString(), null),
          _buildStatItem(
            'Followers', 
            controller.userProfile['followers_count']?.toString() ?? '0',
            () => _showFollowersList(controller),
          ),
          _buildStatItem(
            'Following', 
            controller.userProfile['following_count']?.toString() ?? '0',
            () => _showFollowingList(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowersList(UserProfileController controller) {
    print('🔍 Showing followers list for user: ${controller.userProfile['username']}');
    print('🔍 User ID: ${controller.userProfile['user_id']}');
    
    if (controller.userProfile['user_id'] == null) {
      Get.snackbar(
        'Error',
        'User ID not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    Get.to(() => FollowersFollowingPage(
      userId: controller.userProfile['user_id'].toString(),
      username: controller.userProfile['username'] ?? '',
      type: 'followers',
    ));
  }

  void _showFollowingList(UserProfileController controller) {
    print('🔍 Showing following list for user: ${controller.userProfile['username']}');
    print('🔍 User ID: ${controller.userProfile['user_id']}');
    
    if (controller.userProfile['user_id'] == null) {
      Get.snackbar(
        'Error',
        'User ID not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    Get.to(() => FollowersFollowingPage(
      userId: controller.userProfile['user_id'].toString(),
      username: controller.userProfile['username'] ?? '',
      type: 'following',
    ));
  }

  void _startChatWithUser(UserProfileController controller) {
    print('🔍 Starting chat with user: ${controller.userProfile['username']}');
    print('🔍 User profile data: ${controller.userProfile}');
    
    // Create a properly formatted user object for ChatPage
    final userData = {
      'id': controller.userProfile['user_id'], // Use 'id' instead of 'user_id'
      'username': controller.userProfile['username'],
      'full_name': controller.userProfile['full_name'] ?? controller.userProfile['username'],
      'profile_picture': controller.userProfile['profile_picture'],
    };
    
    print('🔍 Formatted user data for chat: $userData');
    
    // Navigate to chat page with user info
    Get.to(() => ChatPage(), arguments: {
      'user_id': controller.userProfile['user_id'],
      'username': controller.userProfile['username'],
      'full_name': controller.userProfile['full_name'] ?? controller.userProfile['username'],
      'profile_picture': controller.userProfile['profile_picture'],
      'open_direct_chat': true, // Flag to indicate we want to open direct chat
    })?.then((_) {
      // Refresh the profile when returning from chat
      controller.loadUserProfile();
    });
  }

  Widget _buildFollowButton(UserProfileController controller) {
    return Obx(() {
      print('🔍 Building follow button - isLoading: ${controller.isLoading.value}');
      print('🔍 User profile data: ${controller.userProfile}');
      print('🔍 Is following: ${controller.isFollowing.value}');
      
      // Show loading if profile is still loading
      if (controller.isLoading.value) {
        return Container(
          margin: EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            child: Text('Loading...'),
          ),
        );
      }

      // Show loading if user profile is empty
      if (controller.userProfile.isEmpty) {
        return Container(
          margin: EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            child: Text('Loading...'),
          ),
        );
      }

      // Check if we have the required user_id field
      if (controller.userProfile['user_id'] == null) {
        print('🔍 User ID is null, showing loading');
        return Container(
          margin: EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            child: Text('Loading...'),
          ),
        );
      }
      
      return FutureBuilder<String?>(
        future: AuthService.getCurrentUserId().timeout(
          Duration(seconds: 5),
          onTimeout: () {
            print('❌ Timeout getting current user ID');
            return null;
          },
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            print('🔍 Current user ID not available yet or null');
            // Show both buttons as fallback
            return Container(
              margin: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Follow/Unfollow button
                  Expanded(
                    child: Container(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isFollowLoading.value ? null : () {
                          print('🔍 Follow/Unfollow button tapped (fallback)');
                          if (controller.isFollowing.value) {
                            // Show confirmation dialog for unfollow
                            Get.dialog(
                              AlertDialog(
                                title: Text('Unfollow User'),
                                content: Text('Are you sure you want to unfollow ${controller.userProfile['username']}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      controller.followUser();
                                    },
                                    child: Text('Unfollow', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            controller.followUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isFollowing.value ? Colors.grey[200] : Colors.blue,
                          foregroundColor: controller.isFollowing.value ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isFollowLoading.value 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  controller.isFollowing.value ? Colors.black : Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              controller.isFollowing.value ? 'Following' : 'Follow',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Message button
                  Expanded(
                    child: Container(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _startChatWithUser(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7D64FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final currentUserId = snapshot.data;
          print('🔍 Current user ID: $currentUserId');
          print('🔍 Profile user ID: ${controller.userProfile['user_id']}');
          
          if (controller.userProfile['user_id'].toString() == currentUserId) {
            print('🔍 Showing Edit Profile button (own profile)');
            return Container(
              margin: EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                child: Text('Edit Profile'),
              ),
            );
          }

          print('🔍 Showing Follow button for other user');
          return Container(
            margin: EdgeInsets.all(16),
            child: Row(
              children: [
                // Follow/Unfollow button
                Expanded(
                  child: Container(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isFollowLoading.value ? null : () {
                        print('🔍 Follow/Unfollow button tapped');
                        if (controller.isFollowing.value) {
                          // Show confirmation dialog for unfollow
                          Get.dialog(
                            AlertDialog(
                              title: Text('Unfollow User'),
                              content: Text('Are you sure you want to unfollow ${controller.userProfile['username']}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.followUser();
                                  },
                                  child: Text('Unfollow', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        } else {
                          controller.followUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isFollowing.value ? Colors.grey[200] : Colors.blue,
                        foregroundColor: controller.isFollowing.value ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isFollowLoading.value 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                controller.isFollowing.value ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            controller.isFollowing.value ? 'Following' : 'Follow',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Message button
                Expanded(
                  child: Container(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _startChatWithUser(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7D64FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildBio(UserProfileController controller) {
    final bio = controller.userProfile['bio'];
    final website = controller.userProfile['website'];
    
    if (bio == null && website == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bio != null && bio.isNotEmpty) ...[
            Text(
              bio,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
          ],
          if (website != null && website.isNotEmpty) ...[
            Text(
              website,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildPostsGrid(UserProfileController controller) {
    if (controller.isPrivate.value) {
      return Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'This Account is Private',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Follow this account to see their posts',
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

    if (controller.userPosts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Posts Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: controller.userPosts.length,
        itemBuilder: (context, index) {
          final post = controller.userPosts[index];
          return GestureDetector(
            onTap: () => controller.onPostTap(post),
            child: CachedNetworkImage(
              imageUrl: post['media_url'] ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }
} 