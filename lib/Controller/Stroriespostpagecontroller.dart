import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysgram/Model/Storiespostdatamodel.dart';
import 'package:mysgram/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class StoriesController extends GetxController {
  var stories = <StoryModel>[].obs;
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;
  var currentUserUsername = ''.obs;
  var currentUserProfilePicture = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
    loadRealData();
  }

  Future<void> loadCurrentUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null) {
        currentUserUsername.value = userData['username'] ?? '';
        currentUserProfilePicture.value = userData['profile_picture'] ?? '';
      }
    } catch (e) {
      print('❌ Error loading current user data: $e');
    }
  }

  Future<void> loadRealData() async {
    try {
      isLoading.value = true;
      
      // Load stories
      await loadStories();
      
      // Load posts
      await loadPosts();
      
    } catch (e) {
      print('❌ Error loading real data: $e');
      // Don't load dummy data, just handle the error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStories() async {
    try {
      print('🔄 Starting to load stories...');
      
      // First, ensure stories table exists
      try {
        await AuthService.createStoriesTable();
        print('✅ Stories table checked/created');
      } catch (e) {
        print('⚠️ Stories table check failed: $e');
      }
      
      // Use the new API that includes view status
      print('🔍 Calling getStoriesWithViewStatus...');
      final result = await AuthService.getStoriesWithViewStatus();
      print('🔍 Stories with view status API result: $result');
      
      if (result['stories'] != null) {
        final storiesData = List<Map<String, dynamic>>.from(result['stories']);
        
        // Group stories by user
        Map<String, List<Map<String, dynamic>>> userStoriesMap = {};
        
        for (var storyData in storiesData) {
          final userId = storyData['user_id'].toString();
          if (!userStoriesMap.containsKey(userId)) {
            userStoriesMap[userId] = [];
          }
          userStoriesMap[userId]!.add(storyData);
        }
        
        // Convert to StoryModel format
        stories.clear();
        for (var entry in userStoriesMap.entries) {
          final userId = entry.key;
          final userStories = entry.value;
          
          if (userStories.isNotEmpty) {
            // Check if any story is unviewed
            final hasUnviewedStory = userStories.any((story) => story['is_viewed'] == false);
            
            // Use the first story for the circle display
            final firstStory = userStories[0];
            stories.add(StoryModel(
              id: userId,
              username: firstStory['username'] ?? '',
              profileImage: firstStory['profile_picture'] ?? '',
              hasStory: true,
              storyCount: userStories.length,
              allStories: userStories,
              hasUnviewedStory: hasUnviewedStory, // Add this field
            ));
          }
        }
        
        print('✅ Stories loaded: ${stories.length} (unique)');
        print('🔍 Stories with unviewed content: ${stories.where((s) => s.hasUnviewedStory).length}');
        
        // Debug each story's view status
        for (int i = 0; i < stories.length; i++) {
          final story = stories[i];
          print('🔍 Story $i: ${story.username} - hasUnviewedStory: ${story.hasUnviewedStory}');
        }
        
        // If no stories, add sample ones for testing
        if (stories.isEmpty) {
          try {
            await AuthService.addSampleStories();
            // Fetch stories again after adding samples
            await loadStories(); // Recursive call to reload
            return;
          } catch (e) {
            print('❌ Error adding sample stories: $e');
          }
        }
      } else {
        print('⚠️ No stories data in response');
      }
    } catch (e) {
      print('❌ Error loading stories: $e');
      // Try to load from old API as fallback
      try {
        final result = await AuthService.getStories();
        print('🔍 Fallback to old stories API');
        
        if (result['stories'] != null) {
          final storiesData = List<Map<String, dynamic>>.from(result['stories']);
          
          // Convert to StoryModel format (without view status)
          stories.clear();
          for (var storyData in storiesData) {
            if (storyData['stories'] != null) {
              final userStories = List<Map<String, dynamic>>.from(storyData['stories']);
              
              if (userStories.isNotEmpty) {
                final firstStory = userStories[0];
                stories.add(StoryModel(
                  id: storyData['user_id'].toString(),
                  username: storyData['username'] ?? '',
                  profileImage: storyData['profile_picture'] ?? '',
                  hasStory: true,
                  storyCount: userStories.length,
                  allStories: userStories,
                  hasUnviewedStory: true, // Default to true for fallback
                ));
              }
            }
          }
        }
      } catch (fallbackError) {
        print('❌ Fallback stories API also failed: $fallbackError');
      }
    }
  }

  Future<void> loadPosts() async {
    try {
      final result = await AuthService.getPosts();
      print('🔍 Raw API result: $result');
      if (result['posts'] != null) {
        final postsData = List<Map<String, dynamic>>.from(result['posts']);
        print('🔍 Raw posts data: $postsData');
        
        final realPosts = postsData.map((post) {
          // Debug logging for each post
          print('🔍 Processing post: ${post['id']}');
          print('🔍 Post user_id: ${post['user_id']}');
          print('🔍 Post username: ${post['username']}');
          
          return PostModel(
            postId: (post['id'] ?? 0).toString(),
            userId: post['user_id']?.toString(), // Handle nullable user_id
            username: post['username'] ?? 'Unknown',
            profileImage: post['profile_picture'] ?? "assets/profile1.jpg",
            postImage: post['media_url'] ?? "assets/Postimage.png",
            likes: (post['likes_count'] ?? 0).toString(),
            caption: post['caption'] ?? '',
            timeAgo: _getTimeAgo(post['created_at'] ?? ''),
            isLiked: post['is_liked'] ?? false,
            commentCount: (post['comments_count'] ?? 0).toString(),
          );
        }).toList();
        
        posts.value = realPosts;
        
        // Debug logging for posts
        print('🔍 Total posts loaded: ${realPosts.length}');
        for (int i = 0; i < realPosts.length; i++) {
          final post = realPosts[i];
          print('🔍 Post $i: id=${post.postId}, userId=${post.userId}, username=${post.username}');
          print('🔍 Post $i full data: $post');
        }
      }
    } catch (e) {
      print('❌ Error loading posts: $e');
      // Load dummy posts as fallback
      // loadDummyPosts(); // Removed dummy data
    }
  }

  String _getTimeAgo(String createdAt) {
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return '2h'; // Default fallback
    }
  }

  Future<void> refreshFeed() async {
    await loadRealData();
  }

  Future<void> likePost(String postId) async {
    try {
      // Check for guest mode first
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('is_guest_user') ?? false;
      
      if (isGuest) {
        Get.snackbar(
          'Sign Up Required',
          'Please sign up to like posts',
          backgroundColor: Color(0xFF535AF4),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Convert postId to integer safely
      final int? postIdInt = int.tryParse(postId);
      if (postIdInt == null) {
        print('❌ Invalid post ID: $postId');
        return;
      }
      
      // Find the post index
      final postIndex = posts.indexWhere((post) => post.postId == postId);
      if (postIndex == -1) {
        print('❌ Post not found: $postId');
        return;
      }
      
      // Optimistically update UI first
      final currentPost = posts[postIndex];
      final newLikeCount = currentPost.isLiked 
          ? (int.tryParse(currentPost.likes) ?? 0) - 1 
          : (int.tryParse(currentPost.likes) ?? 0) + 1;
      
      final updatedPost = PostModel(
        postId: currentPost.postId,
        userId: currentPost.userId,
        username: currentPost.username,
        profileImage: currentPost.profileImage,
        postImage: currentPost.postImage,
        likes: newLikeCount.toString(),
        caption: currentPost.caption,
        timeAgo: currentPost.timeAgo,
        isLiked: !currentPost.isLiked,
        commentCount: currentPost.commentCount,
      );
      
      posts[postIndex] = updatedPost;
      
      // Make API call
      final result = await AuthService.toggleLike(postIdInt);
      
      if (result['success'] == true) {
        // Update with server response
        final serverLikeCount = result['likes_count']?.toString() ?? newLikeCount.toString();
        final serverIsLiked = result['is_liked'] ?? !currentPost.isLiked;
        
        final finalPost = PostModel(
          postId: currentPost.postId,
          userId: currentPost.userId,
          username: currentPost.username,
          profileImage: currentPost.profileImage,
          postImage: currentPost.postImage,
          likes: serverLikeCount,
          caption: currentPost.caption,
          timeAgo: currentPost.timeAgo,
          isLiked: serverIsLiked,
          commentCount: currentPost.commentCount,
        );
        
        posts[postIndex] = finalPost;
        print('✅ Post liked successfully: $postId');
      } else {
        // Revert on failure
        posts[postIndex] = currentPost;
        print('❌ Like failed for post: $postId');
      }
    } catch (e) {
      print('❌ Error liking post: $e');
      // Revert on error
      final postIndex = posts.indexWhere((post) => post.postId == postId);
      if (postIndex != -1) {
        // Refresh the post data
        await loadPosts();
      }
    }
  }

  // Add story method
  void addStory() {
    // Show story upload dialog
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
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        await _uploadStory(image.path, 'image');
      }
    } catch (e) {
      print('❌ Error picking story from camera: $e');
      Get.snackbar('Error', 'Failed to pick image from camera');
    }
  }

  Future<void> _pickStoryFromGallery() async {
    try {
      print('🔄 Starting gallery story pick...');
      final ImagePicker picker = ImagePicker();
      
      print('🔍 Requesting image from gallery...');
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('✅ Image selected from gallery: ${image.path}');
        print('🔍 Image size: ${await image.length()} bytes');
        await _uploadStory(image.path, 'image');
      } else {
        print('⚠️ No image selected from gallery');
        Get.snackbar('Info', 'No image selected');
      }
    } catch (e) {
      print('❌ Error picking story from gallery: $e');
      print('🔍 Error details: ${e.toString()}');
      Get.snackbar('Error', 'Failed to pick image from gallery: ${e.toString()}');
    }
  }

  Future<void> _uploadStory(String filePath, String mediaType) async {
    try {
      final result = await AuthService.uploadStory(
        filePath: filePath, 
        mediaType: mediaType,
      );
      
      if (result['message']?.contains('successfully') == true || result['story_id'] != null) {
        Get.snackbar('Success', 'Story uploaded successfully!');
        // Refresh stories
        await loadStories();
      } else {
        Get.snackbar('Error', 'Failed to upload story');
      }
    } catch (e) {
      print('❌ Error uploading story: $e');
      Get.snackbar('Error', 'Failed to upload story: ${e.toString()}');
    }
  }

  // Remove all dummy data methods - we only want real data
}
