import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysgram/View/Screens/SettingsPage.dart';
import 'package:mysgram/View/Screens/Camera/Camerapage.dart';
import 'package:mysgram/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysgram/View/Screens/PostDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'FollowersFollowingPage.dart';

// Profile Controller
class ProfileController extends GetxController {
  final RxString username = ''.obs;
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString profilePicture = ''.obs;
  final RxString profession = 'Designer/Artist'.obs;
  final RxString bio = 'Add a bio to tell people more about yourself.'.obs;
  final RxString link = ''.obs;
  final RxString location = 'Add location'.obs;
  final RxInt postsCount = 0.obs;
  final RxString followersCount = '0'.obs;
  final RxInt followingCount = 0.obs;
  final RxInt streakCount = 0.obs;
  final RxBool isFollowing = false.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isPostExpanded = false.obs;
  final RxInt expandedPostIndex = (-1).obs;
  final RxBool isLoading = true.obs;
  final RxBool isEditing = false.obs;
  final RxBool showEditDialog = false.obs;

  // Story-related variables
  final RxList<String> stories = <String>[].obs;
  final RxBool hasStories = false.obs;

  final RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;
  
  // Text editing controllers for edit profile dialog
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      
      // Check for guest mode first
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('is_guest_user') ?? false;
      
      if (isGuest) {
        // Set guest user data
        username.value = 'Guest User';
        fullName.value = 'Guest User';
        email.value = 'guest@mysgram.com';
        profilePicture.value = '';
        bio.value = 'You are browsing as a guest. Sign up to create posts and interact!';
        link.value = '';
        location.value = '';
        postsCount.value = 0;
        followersCount.value = '0';
        followingCount.value = 0;
        streakCount.value = 0;
        isLoading.value = false;
        return;
      }
      
      // Check and setup database tables first
      try {
        await AuthService.checkDatabase();
        print('✅ Database tables checked/setup');
      } catch (e) {
        print('⚠️ Database check failed: $e');
      }
      
      // Force refresh user data from backend instead of SharedPreferences
      await refreshUserData();
      
      // Get user data from SharedPreferences using AuthService
      final userData = await AuthService.getUserData();
      
      if (userData != null) {
        // Update profile data
        username.value = userData['username'] ?? '';
        fullName.value = userData['full_name'] ?? '';
        email.value = userData['email'] ?? '';
        profilePicture.value = userData['profile_picture'] ?? '';
        
        // Set default values if empty
        bio.value = userData['bio'] ?? 'Add a bio to tell people more about yourself.';
        link.value = userData['website'] ?? '';
        location.value = userData['location'] ?? 'Add location';
        
        // Handle type conversion for numeric fields
        try {
          postsCount.value = int.tryParse(userData['posts_count']?.toString() ?? '0') ?? 0;
          followersCount.value = (int.tryParse(userData['followers_count']?.toString() ?? '0') ?? 0).toString();
          followingCount.value = int.tryParse(userData['following_count']?.toString() ?? '0') ?? 0;
          streakCount.value = int.tryParse(userData['streak_count']?.toString() ?? '0') ?? 0;
        } catch (e) {
          print('Error parsing numeric fields: $e');
          postsCount.value = 0;
          followersCount.value = '0';
          followingCount.value = 0;
          streakCount.value = 0;
        }
        
        // Check if user has stories (for now, always false)
        hasStories.value = false;
        
        // Load user's posts
        await loadUserPosts();
        
        // Update posts count from actual posts loaded
        postsCount.value = posts.length;
        
        // Force refresh counts from backend one more time
        await refreshUserData();
        
        // Test streak display
        try {
          final testResult = await AuthService.testStreakDisplay();
          // print('🔍 Test Streak Result: $testResult');
          
          if (testResult['streak_raw'] != null) {
            // print('🔍 Raw Streak: ${testResult['streak_raw']}');
            // print('🔍 Int Streak: ${testResult['streak_int']}');
            // print('🔍 String Streak: ${testResult['streak_string']}');
            // print('🔍 Streak Type: ${testResult['streak_type']}');
            
            // Update streak from test data
            streakCount.value = testResult['streak_int'];
            // print('🔍 Updated Streak from Test: ${testResult['streak_int']}');
          }
        } catch (e) {
          // print('⚠️ Test streak failed: $e');
        }
        
        // Debug profile data
        try {
          final debugResult = await AuthService.debugProfile();
         
          if (debugResult['user_data'] != null) {
            final debugUserData = debugResult['user_data'];
            print('🔍 Database Streak: ${debugUserData['streak_count']}');
            print('🔍 Database Posts: ${debugUserData['posts_count']}');
            
            // Update streak from debug data
            final dbStreak = int.tryParse(debugUserData['streak_count']?.toString() ?? '0') ?? 0;
            streakCount.value = dbStreak;
            print('🔍 Updated Streak from DB: $dbStreak');
          }
        } catch (e) {
          print('⚠️ Debug failed: $e');
        }
        
        // Check and fix streak
        try {
          final streakResult = await AuthService.checkStreak();
          if (streakResult['current_streak'] != null) {
            streakCount.value = int.tryParse(streakResult['current_streak'].toString()) ?? 0;
          }
          
          // If streak is 0 but user has posts, fix it
          if (streakCount.value == 0 && postsCount.value > 0) {
            final fixResult = await AuthService.fixStreak();
            if (fixResult['new_streak'] != null) {
              streakCount.value = int.tryParse(fixResult['new_streak'].toString()) ?? 0;
            }
          }
        } catch (e) {
          print('⚠️ Streak check failed: $e');
        }
        
        print('✅ Profile loaded: ${username.value}');
        print('📊 Posts count: ${postsCount.value}');
        print('🔥 Streak count: ${streakCount.value}');
      } else {
        print('❌ No user data found');
        // Try to get user data from backend
        await refreshUserData();
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      // Set default values on error
      username.value = '';
      fullName.value = '';
      email.value = '';
      profilePicture.value = '';
      bio.value = 'Add a bio to tell people more about yourself.';
      link.value = '';
      location.value = 'Add location';
      postsCount.value = 0;
      followersCount.value = '0';
      followingCount.value = 0;
      hasStories.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserData() async {
    try {
      // Force refresh from backend
      final result = await AuthService.verifyToken();
      if (result != null && result['user'] != null) {
        final userData = result['user'];
        
        username.value = userData['username'] ?? '';
        fullName.value = userData['full_name'] ?? '';
        email.value = userData['email'] ?? '';
        profilePicture.value = userData['profile_picture'] ?? '';
        bio.value = userData['bio'] ?? 'Add a bio to tell people more about yourself.';
        link.value = userData['website'] ?? '';
        location.value = userData['location'] ?? 'Add location';
        
        // Handle type conversion for numeric fields - ensure proper conversion
        try {
          // Get actual counts from database - ensure they are integers
          final posts = userData['posts_count'];
          postsCount.value = posts != null ? (int.tryParse(posts.toString()) ?? 0) : 0;
          
          // Ensure followers_count is properly converted
          final followers = userData['followers_count'];
          if (followers != null) {
            final followersInt = int.tryParse(followers.toString()) ?? 0;
            followersCount.value = followersInt.toString();
          } else {
            followersCount.value = '0';
          }
          
          final following = userData['following_count'];
          followingCount.value = following != null ? (int.tryParse(following.toString()) ?? 0) : 0;
          
          final streak = userData['streak_count'];
          streakCount.value = streak != null ? (int.tryParse(streak.toString()) ?? 0) : 0;
          
          print('📊 Counts updated - Posts: ${postsCount.value}, Followers: ${followersCount.value}, Following: ${followingCount.value}, Streak: ${streakCount.value}');
          print('📊 Raw data - Posts: ${userData['posts_count']}, Followers: ${userData['followers_count']}, Following: ${userData['following_count']}, Streak: ${userData['streak_count']}');
        } catch (e) {
          print('Error parsing numeric fields: $e');
          postsCount.value = 0;
          followersCount.value = '0';
          followingCount.value = 0;
          streakCount.value = 0;
        }
        
        // Save updated data using AuthService
        await AuthService.saveUserData(userData);
        
        // Reload posts to update posts count
        await loadUserPosts();
        postsCount.value = posts.length;
        
        // Check and update streak
        try {
          final streakResult = await AuthService.checkStreak();
          if (streakResult['current_streak'] != null) {
            streakCount.value = int.tryParse(streakResult['current_streak'].toString()) ?? 0;
            print('🔥 Streak updated: ${streakCount.value}');
          }
        } catch (e) {
          print('⚠️ Streak check failed: $e');
        }
        
        print('✅ User data refreshed from backend');
      }
    } catch (e) {
      print('❌ Error refreshing user data: $e');
      // Set default values on error
      username.value = '';
      fullName.value = '';
      email.value = '';
      profilePicture.value = '';
      bio.value = 'Add a bio to tell people more about yourself.';
      link.value = '';
      location.value = 'Add location';
      postsCount.value = 0;
      followersCount.value = '0';
      followingCount.value = 0;
      streakCount.value = 0;
    }
  }

  void toggleFollow() {
    isFollowing.value = !isFollowing.value;
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  void expandPost(int index) {
    isPostExpanded.value = true;
    expandedPostIndex.value = index;
  }

  void collapsePost() {
    isPostExpanded.value = false;
    expandedPostIndex.value = -1;
  }

  void toggleEdit() {
    // Initialize controllers with current values
    nameController.text = fullName.value;
    usernameController.text = username.value;
    bioController.text = bio.value;
    websiteController.text = link.value;
    locationController.text = location.value;
    showEditDialog.value = true;
  }

  void closeEditDialog() {
    showEditDialog.value = false;
  }
  
  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    websiteController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void addStory() {
    // Show story upload dialog
    _showStoryUploadDialog();
  }

  void _showStoryUploadDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Add to Story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                _pickStoryFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                _pickStoryFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStoryFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadStory(image.path);
      }
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image from camera',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickStoryFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Check file size
        final file = File(image.path);
        final fileSize = await file.length();
        final maxSize = 1024 * 1024 * 1024; // 1GB
        
        if (fileSize > maxSize) {
          Get.snackbar(
            'File Too Large',
            'Please select a file smaller than 1GB.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        await _uploadStory(image.path);
      }
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadStory(String filePath) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9497E)),
          ),
        ),
        barrierDismissible: false,
      );

      final result = await AuthService.uploadStory(filePath: filePath);
      
      Get.back(); // Close loading dialog
      
      if (result['story_id'] != null) {
        Get.snackbar(
          'Success',
          'Story uploaded successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Refresh user data to update story status
        await refreshUserData();
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to upload story: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void shareProfile() {
    // Share profile functionality
    Get.snackbar(
      'Share Profile',
      'Profile sharing feature coming soon!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> updateProfile({
    String? newUsername,
    String? newFullName,
    String? newBio,
    String? newLocation,
    String? newProfilePicture,
  }) async {
    try {
      final result = await AuthService.updateProfile(
        username: newUsername,
        fullName: newFullName,
        profilePicture: newProfilePicture,
      );
      
      if (result != null) {
        // Update local values
        if (newUsername != null) username.value = newUsername;
        if (newFullName != null) fullName.value = newFullName;
        if (newBio != null) bio.value = newBio;
        if (newLocation != null) location.value = newLocation;
        if (newProfilePicture != null) profilePicture.value = newProfilePicture;
        
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        isEditing.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
                }
    }

        // Load user's posts
    Future<void> loadUserPosts() async {
      try {
        print('🔍 Loading posts for user: ${username.value}');
        final result = await AuthService.getPosts(page: 1, limit: 20);
        print('🔍 Posts result: $result');
        
        if (result['posts'] != null) {
          final allPosts = result['posts'] as List;
          print('🔍 Total posts found: ${allPosts.length}');
          
          final userPosts = allPosts.where((post) => 
            post['username'] == username.value
          ).cast<Map<String, dynamic>>().toList();
          
          print('🔍 User posts found: ${userPosts.length}');
          posts.value = userPosts;
        } else {
          print('🔍 No posts in result');
          posts.value = [];
        }
      } catch (e) {
        print('❌ Error loading posts: $e');
        posts.value = [];
      }
    }
  }

  class Profilepage extends StatelessWidget {
  const Profilepage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7D64FF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 22,
            ),
            title: Obx(() => Text(
                  controller.username.value.isEmpty ? 'Profile' : controller.username.value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () {
                  Get.to(SettingsPage());
                },
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
              ),
            )
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    controller.isLoading.value = true;
                    await controller.loadUserProfile();
                    controller.isLoading.value = false;
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Section
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Profile Picture with Story Circle
                            Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: controller.hasStories.value ? Colors.red : Colors.grey.shade400,
                                      width: controller.hasStories.value ? 3 : 1,
                                    ),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(controller.hasStories.value ? 3 : 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: controller.profilePicture.value.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(controller.profilePicture.value),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: controller.profilePicture.value.isEmpty
                                          ? Colors.grey.shade300
                                          : null,
                                    ),
                                    child: controller.profilePicture.value.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey.shade600,
                                          )
                                        : null,
                                  ),
                                ),
                                // Add Story Button (when no stories)
                                if (!controller.hasStories.value)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: controller.addStory,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF7D64FF),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 20),
                            // Stats Section
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(
                                    controller.postsCount.value.toString(),
                                    'Posts',
                                    null,
                                  ),
                                  _buildStatColumn(
                                    controller.followersCount.value,
                                    'Followers',
                                    () => _showFollowersList(controller),
                                  ),
                                  _buildStatColumn(
                                    controller.followingCount.value.toString(),
                                    'Following',
                                    () => _showFollowingList(controller),
                                  ),
                                  _buildStatColumn(
                                    controller.streakCount.value.toString(),
                                    'Streak 🔥',
                                    null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Profile Info Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.fullName.value.isNotEmpty 
                                  ? controller.fullName.value 
                                  : controller.username.value,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              controller.profession.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              controller.bio.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (controller.link.value.isNotEmpty)
                              Text(
                                controller.link.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            if (controller.link.value.isNotEmpty) SizedBox(height: 4),
                            Text(
                              controller.location.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Action Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.toggleEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.shareProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Text(
                                  'Share Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.person_add_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Posts Grid
                      controller.posts.isEmpty
                          ? Container(
                              height: 300, // Increased height to fix overflow
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No Posts Yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'When you share photos and videos,\nthey\'ll appear on your profile.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to camera page
                                        Get.to(() => Photopage());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF7D64FF),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: Text('Share Your First Photo'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                                childAspectRatio: 1,
                              ),
                              itemCount: controller.posts.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => PostDetailPage(
                                      post: controller.posts[index],
                                      allPosts: controller.posts,
                                      initialIndex: index,
                                    ));
                                  },
                                  onLongPress: () {
                                    // Show delete option for own posts
                                    _showDeletePostDialog(controller, index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                    ),
                                    child: _buildPostThumbnail(controller.posts[index]),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                  ),
                ),

                // Expanded Post Overlay
                controller.isPostExpanded.value
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.9),
                        child: Center(
                          child: Container(
                            width: width * 0.9,
                            height: height * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                children: [
                                  // Post header
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: controller.profilePicture.value.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(controller.profilePicture.value),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                              color: controller.profilePicture.value.isEmpty
                                                  ? Colors.grey.shade300
                                                  : null,
                                            ),
                                            child: controller.profilePicture.value.isEmpty
                                                ? Icon(
                                                    Icons.person,
                                                    size: 16,
                                                    color: Colors.grey.shade600,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          controller.username.value,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.more_horiz),
                                      ],
                                    ),
                                  ),

                                  // Post image
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: Image.asset(
                                        'assets/${controller.posts[controller.expandedPostIndex.value]}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade300,
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey.shade500,
                                              size: 80,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  // Post actions
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.favorite_border, size: 24),
                                        SizedBox(width: 16),
                                        Icon(Icons.chat_bubble_outline, size: 24),
                                        SizedBox(width: 16),
                                        Icon(Icons.send, size: 24),
                                        Spacer(),
                                        Icon(Icons.bookmark_border, size: 24),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),

                // Edit Profile Dialog
                Obx(() => controller.showEditDialog.value
                    ? Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            width: width * 0.9,
                            height: height * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Dialog Header
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: controller.closeEditDialog,
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            print('🔄 Updating profile...');
                                            print('Username: ${controller.username.value}');
                                            print('Full Name: ${controller.fullName.value}');
                                            print('Bio: ${controller.bio.value}');
                                            print('Website: ${controller.link.value}');
                                            print('Location: ${controller.location.value}');
                                            
                                            // Update values from controllers
                                            controller.fullName.value = controller.nameController.text;
                                            controller.username.value = controller.usernameController.text;
                                            controller.bio.value = controller.bioController.text;
                                            controller.link.value = controller.websiteController.text;
                                            controller.location.value = controller.locationController.text;
                                            
                                            // Save profile changes to backend
                                            final result = await AuthService.updateProfile(
                                              username: controller.username.value,
                                              fullName: controller.fullName.value,
                                              bio: controller.bio.value,
                                              website: controller.link.value,
                                              location: controller.location.value,
                                            );
                                            
                                            print('✅ Profile update result: $result');
                                            
                                            controller.closeEditDialog();
                                            Get.snackbar(
                                              'Success',
                                              'Profile updated successfully!',
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                            );
                                          } catch (e) {
                                            print('❌ Profile update error: $e');
                                            Get.snackbar(
                                              'Error',
                                              'Failed to update profile: ${e.toString()}',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Done',
                                          style: TextStyle(
                                            color: Color(0xFF7D64FF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Dialog Content
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        // Profile Picture Section
                                        Center(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: controller.profilePicture.value.isNotEmpty
                                                      ? DecorationImage(
                                                          image: NetworkImage(controller.profilePicture.value),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                  color: controller.profilePicture.value.isEmpty
                                                      ? Colors.grey.shade300
                                                      : null,
                                                ),
                                                child: controller.profilePicture.value.isEmpty
                                                    ? Icon(
                                                        Icons.person,
                                                        size: 40,
                                                        color: Colors.grey.shade600,
                                                      )
                                                    : null,
                                              ),
                                                                                          SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () async {
                                                try {
                                                  // Show source selection dialog
                                                  await Get.dialog(
                                                    AlertDialog(
                                                      title: Text('Select Photo Source'),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            leading: Icon(Icons.camera_alt),
                                                            title: Text('Camera'),
                                                                                                                         onTap: () async {
                                                               Get.back();
                                                               await _pickImage(ImageSource.camera, controller);
                                                             },
                                                          ),
                                                          ListTile(
                                                            leading: Icon(Icons.photo_library),
                                                            title: Text('Gallery'),
                                                                                                                         onTap: () async {
                                                               Get.back();
                                                               await _pickImage(ImageSource.gallery, controller);
                                                             },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  Get.snackbar(
                                                    'Error',
                                                    'Failed to select photo source: ${e.toString()}',
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Change Profile Photo',
                                                style: TextStyle(
                                                  color: Color(0xFF7D64FF),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 24),

                                        // Edit Fields
                                        _buildEditFieldWithController(
                                          label: 'Name',
                                          controller: controller.nameController,
                                          onChanged: (value) {
                                            controller.fullName.value = value;
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        _buildEditFieldWithController(
                                          label: 'Username',
                                          controller: controller.usernameController,
                                          onChanged: (value) {
                                            controller.username.value = value;
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        _buildEditFieldWithController(
                                          label: 'Bio',
                                          controller: controller.bioController,
                                          onChanged: (value) {
                                            controller.bio.value = value;
                                          },
                                          maxLines: 3,
                                        ),
                                        SizedBox(height: 16),
                                        _buildEditFieldWithController(
                                          label: 'Website',
                                          controller: controller.websiteController,
                                          onChanged: (value) {
                                            controller.link.value = value;
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        _buildEditFieldWithController(
                                          label: 'Location',
                                          controller: controller.locationController,
                                          onChanged: (value) {
                                            controller.location.value = value;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
              ],
            )),
    );
  }

  Widget _buildEditFieldWithController({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF7D64FF)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String count, String label, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowersList(ProfileController controller) async {
    // Get current user ID from AuthService
    final currentUserId = await AuthService.getCurrentUserId();
    if (currentUserId != null) {
      Get.to(() => FollowersFollowingPage(
        userId: currentUserId,
        username: controller.username.value,
        type: 'followers',
      ));
    } else {
      Get.snackbar(
        'Error',
        'Could not get user ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showFollowingList(ProfileController controller) async {
    // Get current user ID from AuthService
    final currentUserId = await AuthService.getCurrentUserId();
    if (currentUserId != null) {
      Get.to(() => FollowersFollowingPage(
        userId: currentUserId,
        username: controller.username.value,
        type: 'following',
      ));
    } else {
      Get.snackbar(
        'Error',
        'Could not get user ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Build post thumbnail widget
  Widget _buildPostThumbnail(Map<String, dynamic> post) {
    final mediaType = post['media_type'] ?? 'image';
    final mediaUrl = post['media_url'] ?? '';
    final thumbnailUrl = post['thumbnail_url'] ?? '';
    
    // Only show video icon if it's actually a video
    if (mediaType == 'video' || mediaType == 'reel') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            thumbnailUrl.isNotEmpty ? thumbnailUrl : mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image,
                  color: Colors.grey.shade500,
                  size: 40,
                ),
              );
            },
          ),
          Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 32,
          ),
        ],
      );
    } else {
      // Regular image post
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: Icon(
              Icons.image,
              color: Colors.grey.shade500,
              size: 40,
            ),
          );
        },
      );
    }
  }

  // Show delete post dialog
  Future<void> _showDeletePostDialog(ProfileController controller, int postIndex) async {
    final post = controller.posts[postIndex];
    
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Show loading
        Get.dialog(
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
            ),
          ),
          barrierDismissible: false,
        );

        // Delete post
        await AuthService.deletePost(int.parse(post['id'].toString()));
        
        // Remove from list
        controller.posts.removeAt(postIndex);
        controller.postsCount.value = controller.posts.length;
        
        // Refresh user data to update counts
        await controller.refreshUserData();
        
        Get.back(); // Close loading dialog
        
        Get.snackbar(
          'Success',
          'Post deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Failed to delete post: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Helper method to pick and upload image
  Future<void> _pickImage(ImageSource source, ProfileController controller) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 60, // Reduced quality to make file smaller
        maxWidth: 800, // Limit width
        maxHeight: 800, // Limit height
      );
      
      if (image != null) {
        // Show loading dialog
        Get.dialog(
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D64FF)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Uploading profile photo...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
        
        // Upload to backend
        final result = await AuthService.uploadProfilePhoto(File(image.path));
        
        // Close loading dialog
        Get.back();
        
        // Update profile picture in UI
        controller.profilePicture.value = result['profile_picture'];
        
        // Refresh user data to get updated profile
        await controller.refreshUserData();
        
        Get.snackbar(
          'Success',
          'Profile photo updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog if open
      Get.snackbar(
        'Error',
        'Failed to upload profile photo: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
