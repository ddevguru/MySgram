import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../Controller/Stroriespostpagecontroller.dart';
import '../../Model/Storiespostdatamodel.dart';
import 'StoryViewerPage.dart';
import 'NotificationPage.dart';
import 'ChatPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysgram/services/auth_service.dart';
import 'package:mysgram/services/notification_service.dart';
import 'package:mysgram/View/Screens/UserProfilePage.dart';
import 'dart:io';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class Storiespostpage extends StatefulWidget {
  const Storiespostpage({super.key});

  @override
  State<Storiespostpage> createState() => _StoriespostpageState();
}

class _StoriespostpageState extends State<Storiespostpage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh stories when app becomes visible again
      try {
        final controller = Get.find<StoriesController>();
        controller.loadStories();
      } catch (e) {
        print('⚠️ Could not refresh stories: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    
    // Use Get.find() to get existing controller or create new one
    StoriesController controller;
    try {
      controller = Get.find<StoriesController>();
      print('🔍 Found existing StoriesController');
    } catch (e) {
      controller = Get.put(StoriesController());
      print('🔍 Created new StoriesController');
    }

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
                Color(0xFF7D64FF), // Purple color from left
                Color(0xFFFFFFFF), // White color to right
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => _showStoryUploadDialog(context, controller),
              child: Icon(
                Icons.camera_alt,
                color: Color(0xFFE9497E),
                size: 28,
              ),
            ),
            title: Image.asset(
              'assets/Mysgramappbarname.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            actions: [
              // Chat Button
              GestureDetector(
                onTap: () {
                  Get.to(() => ChatPage());
                },
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFFE9497E),
                    size: 28,
                  ),
                ),
              ),
              // Notifications Button
              GestureDetector(
                onTap: () {
                  Get.to(() => NotificationPage());
                },
                child: Stack(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Color(0xFFE9497E),
                      size: 28,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: FutureBuilder<int>(
                        future: _getUnreadNotificationCount(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data! > 0) {
                            return Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                snapshot.data! > 99 ? '99+' : snapshot.data!.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9497E)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading feed...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          color: Color(0xFFE9497E),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Stories Section
                Container(
                  height: 120,
                  child: Column(
                    children: [
                      // Stories list
                      Expanded(
                        child: Obx(() {
                          print('🔍 Stories Section - Stories count: ${controller.stories.length}');
                          print('🔍 Stories Section - Stories data: ${controller.stories}');
                          
                          return controller.stories.isEmpty
                              ? Row(
                                  children: [
                                    // Add story button when no stories
                                    GestureDetector(
                                      onTap: () => controller.addStory(),
                                      child: Container(
                                        margin: EdgeInsets.only(right: 15),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade300,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.grey.shade600,
                                                size: 30,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Add Story',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Empty state message
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No stories available',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.stories.length + 1, // +1 for add story button
                                  itemBuilder: (context, index) {
                                    // Add story button at the beginning
                                    if (index == 0) {
                                      return GestureDetector(
                                        onTap: () => controller.addStory(),
                                        child: Container(
                                          margin: EdgeInsets.only(right: 15),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey.shade300,
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.grey.shade600,
                                                  size: 30,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Add Story',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    // User stories
                                    final story = controller.stories[index - 1];
                                    print('🔍 Building story at index ${index - 1}: ${story.username}');
                                    return GestureDetector(
                                      onTap: () {
                                        if (story.hasStory && story.allStories.isNotEmpty) {
                                          // Add user info to each story
                                          final storiesWithUserInfo = story.allStories.map<Map<String, dynamic>>((storyData) {
                                            return {
                                              ...storyData,
                                              'username': story.username,
                                              'profile_picture': story.profileImage,
                                              'user_id': story.id,
                                            };
                                          }).toList();
                                          
                                          Get.to(() => StoryViewerPage(
                                            stories: storiesWithUserInfo,
                                            initialIndex: 0, // Always start with first story
                                          ))?.then((_) {
                                            // Refresh stories when returning to update circle colors
                                            controller.loadStories();
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 15),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: story.hasUnviewedStory ? Colors.red : Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey.shade300,
                                                ),
                                                child: ClipOval(
                                                  child: story.profileImage.startsWith('http')
                                                      ? CachedNetworkImage(
                                                          imageUrl: story.profileImage,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context, url) => Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          errorWidget: (context, url, error) => Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          story.profileImage,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) => Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              story.username,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                        }),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),

                // Posts Section
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.posts.length,
                  itemBuilder: (context, index) {
                    final post = controller.posts[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
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
                                      color: Colors.grey.shade300,
                                    ),
                                    child: ClipOval(
                                      child: post.profileImage.startsWith('http')
                                          ? CachedNetworkImage(
                                              imageUrl: post.profileImage,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Icon(
                                                Icons.person,
                                                size: 20,
                                                color: Colors.grey.shade600,
                                              ),
                                              errorWidget: (context, url, error) => Icon(
                                                Icons.person,
                                                size: 20,
                                                color: Colors.grey.shade600,
                                              ),
                                            )
                                          : Image.asset(
                                              post.profileImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                Icons.person,
                                                size: 20,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: post.userId != null
                                      ? GestureDetector(
                                          onTap: () async {
                                            // Debug logging
                                            print('🔍 Username tapped: ${post.username}');
                                            print('🔍 Post userId: ${post.userId}');
                                            print('🔍 Post data: $post');
                                            
                                            // Navigate to the profile of the user who created this post
                                            try {
                                              String targetUserId;
                                              
                                              // Check if we have userId in the post data
                                              if (post.userId != null && post.userId!.isNotEmpty) {
                                                targetUserId = post.userId!;
                                                print('🔍 Using userId from post: $targetUserId');
                                              } else {
                                                // If no userId, find it by username
                                                print('🔍 No userId in post, searching by username: ${post.username}');
                                                final foundUserId = await AuthService.getUserIdByUsername(post.username);
                                                
                                                if (foundUserId != null && foundUserId.isNotEmpty) {
                                                  targetUserId = foundUserId;
                                                  print('🔍 Found userId by username: $targetUserId');
                                                } else {
                                                  print('❌ Could not find userId for username: ${post.username}');
                                                  Get.snackbar(
                                                    'Error',
                                                    'Could not find profile for ${post.username}',
                                                    snackPosition: SnackPosition.BOTTOM,
                                                  );
                                                  return;
                                                }
                                              }
                                              
                                              print('🔍 Opening profile for user: ${post.username} (ID: $targetUserId)');
                                              
                                              // Navigate to the user's profile
                                              Get.to(() => UserProfilePage(userId: targetUserId));
                                              
                                            } catch (e) {
                                              print('❌ Error opening profile: $e');
                                              Get.snackbar(
                                                'Error',
                                                'Failed to open profile: ${e.toString()}',
                                                snackPosition: SnackPosition.BOTTOM,
                                              );
                                            }
                                          },
                                          child: Text(
                                            post.username,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.blue, // Make it look clickable
                                            ),
                                          ),
                                        )
                                      : Text(
                                          post.username,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black, // Not clickable
                                          ),
                                        ),
                                ),
                                Icon(
                                  Icons.more_horiz,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),

                          // Post Image with Double Tap Like
                          GestureDetector(
                            onDoubleTap: () {
                              controller.likePost(post.postId);
                              _showLikeAnimation(context);
                            },
                            child: Container(
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  post.postImage.startsWith('http')
                                      ? _buildMediaContent(post.postImage)
                                      : Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.width,
                                          color: Colors.grey.shade200,
                                          child: Image.asset(
                                            post.postImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: MediaQuery.of(context).size.width,
                                            errorBuilder: (context, error, stackTrace) => Center(
                                              child: Icon(
                                                Icons.error,
                                                size: 50,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        ),
                                  // Like animation overlay
                                  Positioned.fill(
                                    child: Center(
                                      child: AnimatedOpacity(
                                        opacity: 0.0,
                                        duration: Duration(milliseconds: 500),
                                        child: Icon(
                                          Icons.favorite,
                                          size: 100,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Post Actions
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => controller.likePost(post.postId),
                                  child: Icon(
                                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 28,
                                    color: post.isLiked ? Colors.red : null,
                                  ),
                                ),
                                SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () => _showCommentsDialog(context, post),
                                  child: Icon(Icons.chat_bubble_outline, size: 26),
                                ),
                                SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () => _showShareDialog(context, post),
                                  child: Icon(Icons.send, size: 26),
                                ),
                                Spacer(),
                                Icon(Icons.bookmark_border, size: 26),
                              ],
                            ),
                          ),

                          // Post Details
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${post.likes} likes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                if (post.caption.isNotEmpty)
                                  post.userId != null
                                      ? GestureDetector(
                                          onTap: () async {
                                            // Debug logging
                                            print('🔍 Caption username tapped: ${post.username}');
                                            print('🔍 Caption post userId: ${post.userId}');
                                            print('🔍 Caption post data: $post');
                                            
                                            // Navigate to the profile of the user who created this post
                                            try {
                                              String targetUserId;
                                              
                                              // Check if we have userId in the post data
                                              if (post.userId != null && post.userId!.isNotEmpty) {
                                                targetUserId = post.userId!;
                                                print('🔍 Using userId from post: $targetUserId');
                                              } else {
                                                // If no userId, find it by username
                                                print('🔍 No userId in post, searching by username: ${post.username}');
                                                final foundUserId = await AuthService.getUserIdByUsername(post.username);
                                                
                                                if (foundUserId != null && foundUserId.isNotEmpty) {
                                                  targetUserId = foundUserId;
                                                  print('🔍 Found userId by username: $targetUserId');
                                                } else {
                                                  print('❌ Could not find userId for username: ${post.username}');
                                                  Get.snackbar(
                                                    'Error',
                                                    'Could not find profile for ${post.username}',
                                                    snackPosition: SnackPosition.BOTTOM,
                                                  );
                                                  return;
                                                }
                                              }
                                              
                                              print('🔍 Opening profile for user: ${post.username} (ID: $targetUserId)');
                                              
                                              // Navigate to the user's profile
                                              Get.to(() => UserProfilePage(userId: targetUserId));
                                              
                                            } catch (e) {
                                              print('❌ Error opening profile: $e');
                                              Get.snackbar(
                                                'Error',
                                                'Failed to open profile: ${e.toString()}',
                                                snackPosition: SnackPosition.BOTTOM,
                                              );
                                            }
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: post.username,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue, // Make it look clickable
                                                  ),
                                                ),
                                                TextSpan(text: " ${post.caption}"),
                                              ],
                                            ),
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: post.username,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black, // Not clickable
                                                ),
                                              ),
                                              TextSpan(text: " ${post.caption}"),
                                            ],
                                          ),
                                        ),
                                SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () => _showCommentsDialog(context, post),
                                  child: Text(
                                    "View all ${post.commentCount ?? 0} comments",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  post.timeAgo,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMediaContent(String url) {
    // Check if URL contains video file extensions
    final lowerUrl = url.toLowerCase();
    final isVideo = lowerUrl.contains('.mp4') || lowerUrl.contains('.mov') || 
                    lowerUrl.contains('.avi') || lowerUrl.contains('.wmv') || 
                    lowerUrl.contains('.flv') || lowerUrl.contains('.webm');

    if (isVideo) {
      // For video files, show a video placeholder with play icon
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                'Video Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Tap to play',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // For images, use CachedNetworkImage
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: MediaQuery.of(context).size.width,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width,
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9497E)),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('❌ Error loading image: $url - $error');
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load media',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (isVideo)
                    Text(
                      'Video file detected',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showLikeAnimation(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    
    Future.delayed(Duration(milliseconds: 500), () {
      Get.back();
    });
  }

  void _showStoryUploadDialog(BuildContext context, StoriesController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Add to Story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: Color(0xFFE9497E)),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                _pickImageFromCamera(controller);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFFE9497E)),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImageFromGallery(controller);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: Color(0xFFE9497E)),
              title: Text('Video Story'),
              onTap: () {
                Get.back();
                _pickVideoFromGallery(controller);
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Color(0xFFE9497E)),
              title: Text('Reel'),
              onTap: () {
                Get.back();
                _pickReelFromGallery(controller);
              },
            ),
          ],
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

  Future<void> _pickImageFromCamera(StoriesController controller) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadStory(image.path, controller);
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

  Future<void> _pickImageFromGallery(StoriesController controller) async {
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
        
        await _uploadStory(image.path, controller);
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

  Future<void> _pickVideoFromGallery(StoriesController controller) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10), // Max video duration
      );

      if (video != null) {
        final file = File(video.path);
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
        
        await _uploadStory(video.path, controller);
      }
    } catch (e) {
      print('❌ Error picking video from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick video from gallery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Pick reel from gallery
  Future<void> _pickReelFromGallery(StoriesController controller) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 15), // 15 minutes for reels
      );

      if (video != null) {
        // Check file size (1GB limit)
        final file = File(video.path);
        final fileSize = await file.length();
        final maxSize = 1024 * 1024 * 1024; // 1GB

        if (fileSize > maxSize) {
          Get.snackbar(
            'Error',
            'Video file is too large. Maximum size is 1GB.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Show loading dialog
        Get.dialog(
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9497E)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Uploading reel...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        // Upload as reel
        await _uploadReel(video.path, controller);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error picking video: $e');
    }
  }

  // Upload reel
  Future<void> _uploadReel(String filePath, StoriesController controller) async {
    try {
      final result = await AuthService.uploadReel(
        filePath: filePath,
        caption: 'Reel from MySgram! 🎬',
      );

      Get.back(); // Close loading dialog

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          'Reel uploaded successfully! 🎉',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Refresh stories
        await controller.loadStories();
      } else {
        Get.snackbar(
          'Error',
          'Failed to upload reel. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to upload reel: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Upload reel error: $e');
    }
  }

  Future<void> _uploadStory(String filePath, StoriesController controller) async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9497E)),
                ),
                SizedBox(height: 16),
                Text('Uploading story...'),
              ],
            ),
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
          duration: Duration(seconds: 2),
        );
        
        // Refresh stories
        await controller.refreshFeed();
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to upload story: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _showStoryViewer(BuildContext context, dynamic story) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          width: double.infinity,
          height: 400,
          child: Column(
            children: [
              // Story header
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: story.profileImage.startsWith('http')
                          ? CachedNetworkImageProvider(story.profileImage)
                          : AssetImage(story.profileImage) as ImageProvider,
                    ),
                    SizedBox(width: 10),
                    Text(
                      story.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Story content
              Expanded(
                child: Center(
                  child: Text(
                    'Story Viewer\n(Coming Soon)',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, dynamic post) {
    final TextEditingController commentController = TextEditingController();
    final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
    final RxBool isLoadingComments = false.obs;
    final RxInt replyingToCommentId = (-1).obs;

    // Load comments
    Future<void> loadComments() async {
      try {
        isLoadingComments.value = true;
        final result = await AuthService.getComments(int.parse(post.postId));
        if (result['comments'] != null) {
          comments.value = List<Map<String, dynamic>>.from(result['comments']);
        }
      } catch (e) {
        print('❌ Error loading comments: $e');
        Get.snackbar(
          'Error',
          'Failed to load comments',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoadingComments.value = false;
      }
    }

    // Add comment
    Future<void> addComment() async {
      // Check for guest mode first
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('is_guest_user') ?? false;
      
      if (isGuest) {
        Get.snackbar(
          'Sign Up Required',
          'Please sign up to comment on posts',
          backgroundColor: Color(0xFF535AF4),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (commentController.text.trim().isEmpty) return;
      
      try {
        Map<String, dynamic> result;
        
        if (replyingToCommentId.value > 0) {
          // Add reply
          result = await AuthService.addReply(
            postId: int.parse(post.postId),
            parentCommentId: replyingToCommentId.value,
            replyText: commentController.text.trim(),
          );
        } else {
          // Add regular comment
          result = await AuthService.addComment(
            int.parse(post.postId),
            commentController.text.trim(),
          );
        }
        
        if (result['success'] == true) {
          commentController.clear();
          replyingToCommentId.value = -1;
          // Reload comments
          await loadComments();
          // Update post comment count
          final controller = Get.find<StoriesController>();
          await controller.refreshFeed();
        }
      } catch (e) {
        print('❌ Error adding comment: $e');
        Get.snackbar(
          'Error',
          'Failed to add comment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    // Load comments initially
    loadComments();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
              ),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
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
            
            // Comments list
            Expanded(
              child: Obx(() {
                if (isLoadingComments.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9497E)),
                    ),
                  );
                }
                
                if (comments.isEmpty) {
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
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _buildCommentItem(comment, replyingToCommentId, commentController, addComment);
                  },
                );
              }),
            ),
            
            // Reply indicator
            Obx(() {
              if (replyingToCommentId.value > 0) {
                final replyingToComment = comments.firstWhereOrNull(
                  (c) => c['id'] == replyingToCommentId.value
                );
                if (replyingToComment != null) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: Colors.grey.shade600),
                        SizedBox(width: 8),
                        Expanded(
                          child: replyingToComment['user_id'] != null
                              ? GestureDetector(
                                  onTap: () {
                                    // Navigate to user profile
                                    Get.to(() => UserProfilePage(userId: replyingToComment['user_id'].toString()));
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(text: 'Replying to '),
                                        TextSpan(
                                          text: replyingToComment['username'],
                                          style: TextStyle(
                                            color: Colors.blue, // Make it look clickable
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(text: 'Replying to '),
                                      TextSpan(
                                        text: replyingToComment['username'],
                                        style: TextStyle(
                                          color: Colors.grey.shade600, // Not clickable
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 16),
                          onPressed: () {
                            replyingToCommentId.value = -1;
                            commentController.clear();
                          },
                        ),
                      ],
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            }),
            
            // Comment input
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: replyingToCommentId.value > 0 ? 'Write a reply...' : 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: addComment,
                    icon: Icon(Icons.send, color: Color(0xFFE9497E)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment, RxInt replyingToCommentId, TextEditingController commentController, Function addComment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main comment
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: ClipOval(
                  child: comment['profile_picture']?.toString().startsWith('http') == true
                      ? CachedNetworkImage(
                          imageUrl: comment['profile_picture'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                ),
              ),
              SizedBox(width: 12),
              
              // Comment content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    comment['user_id'] != null
                        ? GestureDetector(
                            onTap: () {
                              // Navigate to user profile
                              Get.to(() => UserProfilePage(userId: comment['user_id'].toString()));
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: comment['username'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue, // Make it look clickable
                                    ),
                                  ),
                                  TextSpan(text: ' ${comment['comment'] ?? ''}'),
                                ],
                              ),
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: comment['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Not clickable
                                  ),
                                ),
                                TextSpan(text: ' ${comment['comment'] ?? ''}'),
                              ],
                            ),
                          ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getTimeAgo(comment['created_at'] ?? ''),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            replyingToCommentId.value = comment['id'];
                            commentController.clear();
                          },
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Replies
          if (comment['replies'] != null && (comment['replies'] as List).isNotEmpty)
            Container(
              margin: EdgeInsets.only(left: 44, top: 8),
              child: Column(
                children: (comment['replies'] as List).map<Widget>((reply) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reply profile picture
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: ClipOval(
                            child: reply['profile_picture']?.toString().startsWith('http') == true
                                ? CachedNetworkImage(
                                    imageUrl: reply['profile_picture'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                          ),
                        ),
                        SizedBox(width: 8),
                        
                        // Reply content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              reply['user_id'] != null
                                  ? GestureDetector(
                                      onTap: () {
                                        // Navigate to user profile
                                        Get.to(() => UserProfilePage(userId: reply['user_id'].toString()));
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: reply['username'] ?? 'Unknown',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue, // Make it look clickable
                                              ),
                                            ),
                                            TextSpan(text: ' ${reply['comment'] ?? ''}'),
                                          ],
                                        ),
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: reply['username'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // Not clickable
                                            ),
                                          ),
                                          TextSpan(text: ' ${reply['comment'] ?? ''}'),
                                        ],
                                      ),
                                    ),
                              SizedBox(height: 2),
                              Text(
                                _getTimeAgo(reply['created_at'] ?? ''),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
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
      return 'now';
    }
  }

  void _showShareDialog(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'WhatsApp', Colors.green, () => _shareToWhatsApp(post)),
                _buildShareOption(Icons.message, 'Message', Colors.blue, () => _shareViaDirectMessage(post)),
                _buildShareOption(Icons.copy, 'Copy Link', Colors.grey, () => _copyPostLink(post)),
                _buildShareOption(Icons.share, 'More', Colors.orange, () => _shareMore(post)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.facebook, 'Facebook', Colors.blue, () => _shareToFacebook(post)),
                _buildShareOption(Icons.camera_alt, 'Instagram', Colors.purple, () => _shareToInstagram(post)),
                _buildShareOption(Icons.flutter_dash, 'Twitter', Colors.lightBlue, () => _shareToTwitter(post)),
                _buildShareOption(Icons.email, 'Email', Colors.orange, () => _shareViaEmail(post)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Share to WhatsApp
  void _shareToWhatsApp(dynamic post) {
    try {
      final caption = post.caption ?? 'Check out this post from MySgram!';
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final shareText = '$caption\n\n$mediaUrl\n\nShared from MySgram';
      
      final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(shareText)}';
      
      launchUrl(Uri.parse(whatsappUrl)).then((_) {
        Get.back();
        Get.snackbar(
          'Shared!',
          'Post shared to WhatsApp',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }).catchError((e) {
        Get.snackbar(
          'Error',
          'WhatsApp not installed or failed to open',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('❌ Error sharing to WhatsApp: $e');
      Get.snackbar(
        'Error',
        'Failed to share to WhatsApp',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share to Instagram
  void _shareToInstagram(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      
      // Instagram sharing via URL scheme
      final instagramUrl = 'instagram://library?AssetPath=$mediaUrl';
      
      launchUrl(Uri.parse(instagramUrl)).then((_) {
        Get.back();
        Get.snackbar(
          'Shared!',
          'Post opened in Instagram',
          backgroundColor: Colors.purple,
          colorText: Colors.white,
        );
      }).catchError((e) {
        Get.snackbar(
          'Error',
          'Instagram not installed or failed to open',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('❌ Error sharing to Instagram: $e');
      Get.snackbar(
        'Error',
        'Failed to share to Instagram',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share to Facebook
  void _shareToFacebook(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      
      final facebookUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(mediaUrl)}&quote=${Uri.encodeComponent(caption)}';
      
      launchUrl(Uri.parse(facebookUrl), mode: LaunchMode.externalApplication).then((_) {
        Get.back();
        Get.snackbar(
          'Shared!',
          'Post shared to Facebook',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }).catchError((e) {
        Get.snackbar(
          'Error',
          'Failed to share to Facebook',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('❌ Error sharing to Facebook: $e');
      Get.snackbar(
        'Error',
        'Failed to share to Facebook',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share to Twitter
  void _shareToTwitter(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      
      final twitterUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(caption)}&url=${Uri.encodeComponent(mediaUrl)}';
      
      launchUrl(Uri.parse(twitterUrl), mode: LaunchMode.externalApplication).then((_) {
        Get.back();
        Get.snackbar(
          'Shared!',
          'Post shared to Twitter',
          backgroundColor: Colors.lightBlue,
          colorText: Colors.white,
        );
      }).catchError((e) {
        Get.snackbar(
          'Error',
          'Failed to share to Twitter',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('❌ Error sharing to Twitter: $e');
      Get.snackbar(
        'Error',
        'Failed to share to Twitter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Copy post link
  void _copyPostLink(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      final postLink = '$mediaUrl\n\n$caption\n\nShared from MySgram';
      
      // Copy to clipboard
      Clipboard.setData(ClipboardData(text: postLink));
      
      Get.back();
      Get.snackbar(
        'Copied!',
        'Post link copied to clipboard',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error copying post link: $e');
      Get.snackbar(
        'Error',
        'Failed to copy post link',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share via direct message
  void _shareViaDirectMessage(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      final shareText = '$caption\n\n$mediaUrl\n\nShared from MySgram';
      
      // Use system share
      Share.share(shareText, subject: 'Check out this post!');
      
      Get.back();
      Get.snackbar(
        'Shared!',
        'Post shared via message',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error sharing via message: $e');
      Get.snackbar(
        'Error',
        'Failed to share via message',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share via email
  void _shareViaEmail(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      final subject = 'Check out this post from MySgram!';
      final body = '$caption\n\n$mediaUrl\n\nShared from MySgram';
      
      final emailUrl = 'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
      
      launchUrl(Uri.parse(emailUrl)).then((_) {
        Get.back();
        Get.snackbar(
          'Shared!',
          'Post shared via email',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }).catchError((e) {
        Get.snackbar(
          'Error',
          'Failed to share via email',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('❌ Error sharing via email: $e');
      Get.snackbar(
        'Error',
        'Failed to share via email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share more options
  void _shareMore(dynamic post) {
    try {
      final mediaUrl = post.postImage ?? ''; // Use postImage instead of mediaUrl
      final caption = post.caption ?? 'Check out this post from MySgram!';
      final shareText = '$caption\n\n$mediaUrl\n\nShared from MySgram';
      
      // Use system share with more options
      Share.share(shareText, subject: 'Check out this post!');
      
      Get.back();
      Get.snackbar(
        'Shared!',
        'Post shared via system share',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error sharing more: $e');
      Get.snackbar(
        'Error',
        'Failed to share post',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get unread notification count
  Future<int> _getUnreadNotificationCount() async {
    try {
      return await NotificationService.getUnreadCount();
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
      return 0;
    }
  }
}
