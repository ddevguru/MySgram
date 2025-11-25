import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/auth_service.dart';
import '../../Utils/media_utils.dart';
import 'UserProfilePage.dart';
import 'ChatPage.dart'; // Added import for ChatPage
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'gift_service_simple.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<Map<String, dynamic>> allPosts;
  final int initialIndex;
  
  const PostDetailPage({
    Key? key, 
    required this.post, 
    required this.allPosts, 
    required this.initialIndex
  }) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<int, VideoPlayerController?> _videoControllers = {};
  Map<int, bool> _isVideoInitialized = {};
  Map<int, bool> _isLiked = {};
  Map<int, bool> _isSaved = {};
  Map<int, int> _likeCounts = {};
  Map<int, int> _commentCounts = {};
  Map<int, List<Map<String, dynamic>>> _comments = {};
  Map<int, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize data for all posts
    for (int i = 0; i < widget.allPosts.length; i++) {
      final post = widget.allPosts[i];
      _likeCounts[i] = int.tryParse(post['likes_count']?.toString() ?? '0') ?? 0;
      _commentCounts[i] = int.tryParse(post['comments_count']?.toString() ?? '0') ?? 0;
      _isLiked[i] = false; // Will be updated from backend
      _isSaved[i] = false;
      _commentControllers[i] = TextEditingController();
      
      if (post['media_type'] == 'video') {
        _initializeVideo(i, post['media_url']);
      }
    }
    
    // Load comments for all posts
    for (int i = 0; i < widget.allPosts.length; i++) {
      _loadComments(i);
    }
  }

  Future<void> _initializeVideo(int index, String videoUrl) async {
    try {
      print('🔍 Initializing video for index $index: $videoUrl');
      
      if (_videoControllers[index] != null) {
        _videoControllers[index]!.dispose();
      }
      
      _videoControllers[index] = VideoPlayerController.network(videoUrl);
      
      // Add error listener
      _videoControllers[index]!.addListener(() {
        if (_videoControllers[index]!.value.hasError) {
          print('❌ Video error for index $index: ${_videoControllers[index]!.value.errorDescription}');
        }
      });
      
      await _videoControllers[index]!.initialize();
      
      setState(() {
        _isVideoInitialized[index] = true;
      });
      
      print('✅ Video initialized successfully for index $index');
      
      // Auto-play ALL videos immediately after initialization with better error handling
      if (_videoControllers[index] != null && _videoControllers[index]!.value.isInitialized) {
        try {
          await _videoControllers[index]!.play();
          print('🎬 Auto-playing video for index $index');
          
          // Set looping for continuous playback
          _videoControllers[index]!.setLooping(true);
          
          // Set volume to ensure it plays (some devices have silent mode)
          _videoControllers[index]!.setVolume(1.0);
          
        } catch (playError) {
          print('❌ Error playing video for index $index: $playError');
          // Try again after a short delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (_videoControllers[index] != null && _videoControllers[index]!.value.isInitialized) {
              _videoControllers[index]!.play();
            }
          });
        }
      }
      
    } catch (e) {
      print('❌ Error initializing video for index $index: $e');
      setState(() {
        _isVideoInitialized[index] = false;
      });
    }
  }

  @override
  void dispose() {
    _videoControllers.values.forEach((controller) => controller?.dispose());
    _commentControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadComments(int index) async {
    try {
      final post = widget.allPosts[index];
      final result = await AuthService.getComments(int.parse(post['id'].toString()));
      setState(() {
        _comments[index] = List<Map<String, dynamic>>.from(result['comments'] ?? []);
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _comments[index] = [];
      });
    }
  }

  Future<void> _toggleLike(int index) async {
    try {
      final post = widget.allPosts[index];
      final result = await AuthService.toggleLike(int.parse(post['id'].toString()));
      
      setState(() {
        _isLiked[index] = result['is_liked'];
        _likeCounts[index] = result['likes_count'];
      });
      
      Get.snackbar(
        result['is_liked'] ? 'Liked!' : 'Unliked',
        result['is_liked'] ? 'Post added to your likes' : 'Post removed from your likes',
        backgroundColor: result['is_liked'] ? Colors.red : Colors.grey,
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update like: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showComments(int index) {
    final post = widget.allPosts[index];
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
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
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Comments list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _comments[index]?.length ?? 0,
                itemBuilder: (context, commentIndex) {
                  final comment = _comments[index]![commentIndex];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            comment['profile_picture'] ?? 'https://via.placeholder.com/32',
                          ),
                        ),
                        SizedBox(width: 12),
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
                                          style: TextStyle(color: Colors.black, fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: '${comment['username']} ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue, // Make it look clickable
                                              ),
                                            ),
                                            TextSpan(text: comment['comment_text']),
                                          ],
                                        ),
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.black, fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: '${comment['username']} ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black, // Not clickable
                                            ),
                                          ),
                                          TextSpan(text: comment['comment_text']),
                                        ],
                                      ),
                                    ),
                              SizedBox(height: 4),
                              Text(
                                _formatTimestamp(comment['created_at']),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.favorite_border, size: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Add comment
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      post['profile_picture'] ?? 'https://via.placeholder.com/32',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _addComment(index),
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addComment(int index) async {
    final commentText = _commentControllers[index]?.text.trim() ?? '';
    if (commentText.isEmpty) return;

    try {
      final post = widget.allPosts[index];
      final result = await AuthService.addComment(
        int.parse(post['id'].toString()),
        commentText,
      );
      
      // Clear text field
      _commentControllers[index]?.clear();
      
      // Update comments list
      setState(() {
        _comments[index]?.insert(0, result['comment']);
        _commentCounts[index] = result['comments_count'];
      });
      
      Get.snackbar(
        'Comment Posted!',
        'Your comment has been added',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error adding comment: $e');
      Get.snackbar(
        'Error',
        'Failed to post comment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _sharePost(int index) {
    final post = widget.allPosts[index];
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Text(
                    'Share to',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.all(16),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildShareOption('WhatsApp', Icons.message, Colors.green, () => _shareToWhatsApp(post)),
                  _buildShareOption('Instagram', Icons.camera_alt, Colors.purple, () => _shareToInstagram(post)),
                  _buildShareOption('Facebook', Icons.facebook, Colors.blue, () => _shareToFacebook(post)),
                  _buildShareOption('Twitter', Icons.flutter_dash, Colors.lightBlue, () => _shareToTwitter(post)),
                  _buildShareOption('Copy Link', Icons.link, Colors.grey, () => _copyPostLink(post)),
                  _buildShareOption('Message', Icons.message, Colors.blue, () => _shareViaDirectMessage(post)),
                  _buildShareOption('Share via Chat', Icons.chat_bubble, Color(0xFF7D64FF), () => _shareViaChat(post)),
                  _buildShareOption('Email', Icons.email, Colors.orange, () => _shareViaEmail(post)),
                  _buildShareOption('More', Icons.more_horiz, Colors.grey, () => _shareMore(post)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Share to WhatsApp
  void _shareToWhatsApp(dynamic post) {
    try {
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
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
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
      
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
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
      
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
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
      
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
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
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
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
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
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
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

  // Share via chat
  void _shareViaChat(dynamic post) {
    // Navigate to chat page with post data
    Get.to(() => ChatPage(), arguments: {
      'share_post': true,
      'post_data': post,
    });
    
    Get.snackbar(
      'Share via Chat',
      'Select a user to share this post with',
      backgroundColor: Color(0xFF7D64FF),
      colorText: Colors.white,
    );
  }

  // Share more options
  void _shareMore(dynamic post) {
    try {
      final mediaUrl = post['media_url'] ?? post['postImage'] ?? ''; // Try both properties
      final caption = post['caption'] ?? 'Check out this post from MySgram!';
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

  // Add this method to handle page changes
  void _onPageChanged(int index) {
    // Pause all other videos
    for (int i = 0; i < widget.allPosts.length; i++) {
      if (i != index && _videoControllers[i] != null && _videoControllers[i]!.value.isPlaying) {
        _videoControllers[i]!.pause();
      }
    }
    
    // Play the current video
    if (_videoControllers[index] != null && 
        _videoControllers[index]!.value.isInitialized && 
        !_videoControllers[index]!.value.isPlaying) {
      _videoControllers[index]!.play();
    }
    
    setState(() {
      // This will trigger rebuild with new post data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Posts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  // Show current post number
                  Text(
                    '${widget.initialIndex + 1} of ${widget.allPosts.length}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Posts with PageView for better swipe
            Expanded(
              child: PageView.builder(
                controller: PageController(initialPage: widget.initialIndex),
                itemCount: widget.allPosts.length,
                scrollDirection: Axis.horizontal,
                pageSnapping: true,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final post = widget.allPosts[index];
                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Post Header
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  post['profile_picture'] ?? 'https://via.placeholder.com/32',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    post['user_id'] != null
                                        ? GestureDetector(
                                            onTap: () {
                                              // Navigate to user profile
                                              Get.to(() => UserProfilePage(userId: post['user_id'].toString()));
                                            },
                                            child: Text(
                                              post['username'] ?? 'Unknown',
                                              style: TextStyle(
                                                color: Colors.blue, // Make it look clickable
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            post['username'] ?? 'Unknown',
                                            style: TextStyle(
                                              color: Colors.white, // Not clickable
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                    if (post['location'] != null && post['location'].toString().isNotEmpty)
                                      Text(
                                        post['location'].toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.more_vert, color: Colors.white, size: 24),
                              ),
                            ],
                          ),
                        ),

                        // Media Content
                        Container(
                          width: double.infinity,
                          child: post['media_type'] == 'video'
                              ? _buildVideoContent(index)
                              : _buildImageContent(post),
                        ),

                        // Actions and Caption
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Action buttons
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _toggleLike(index),
                                    icon: Icon(
                                      _isLiked[index] == true ? Icons.favorite : Icons.favorite_border,
                                      color: _isLiked[index] == true ? Colors.red : Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _showComments(index),
                                    icon: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                                  ),
                                  IconButton(
                                    onPressed: () => _sharePost(index),
                                    icon: Icon(Icons.send, color: Colors.white, size: 28),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isSaved[index] = !(_isSaved[index] ?? false);
                                      });
                                      Get.snackbar(
                                        _isSaved[index] == true ? 'Saved!' : 'Removed from saved',
                                        _isSaved[index] == true ? 'Post saved to your collection' : 'Post removed from saved',
                                        backgroundColor: _isSaved[index] == true ? Colors.blue : Colors.grey,
                                        colorText: Colors.white,
                                        duration: Duration(seconds: 1),
                                      );
                                    },
                                    icon: Icon(
                                      _isSaved[index] == true ? Icons.bookmark : Icons.bookmark_border,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),

                              // Likes count
                              Padding(
                                padding: EdgeInsets.only(left: 16, top: 8),
                                child: Text(
                                  '${_likeCounts[index] ?? 0} likes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Caption
                              if (post['caption'] != null && post['caption'].toString().isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 16, top: 8, right: 16),
                                  child: post['user_id'] != null
                                      ? GestureDetector(
                                          onTap: () {
                                            // Navigate to user profile
                                            Get.to(() => UserProfilePage(userId: post['user_id'].toString()));
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(color: Colors.white, fontSize: 14),
                                              children: [
                                                TextSpan(
                                                  text: '${post['username']} ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue, // Make it look clickable
                                                  ),
                                                ),
                                                TextSpan(text: post['caption'] ?? ''),
                                              ],
                                            ),
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                            children: [
                                              TextSpan(
                                                text: '${post['username']} ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white, // Not clickable
                                                ),
                                              ),
                                              TextSpan(text: post['caption'] ?? ''),
                                            ],
                                          ),
                                        ),
                                ),

                              // Comments count
                              GestureDetector(
                                onTap: () => _showComments(index),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16, top: 8),
                                  child: Text(
                                    'View all ${_commentCounts[index] ?? 0} comments',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              // Timestamp
                              Padding(
                                padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                                child: Text(
                                  _formatTimestamp(post['created_at']),
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              
                              // Add extra bottom padding for better spacing
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(Map<String, dynamic> post) {
    final mediaUrl = post['media_url'] ?? post['postImage'] ?? '';
    final mediaType = post['media_type'] ?? MediaUtils.getMediaType(mediaUrl);
    
    // Check if it's a video
    if (mediaType == 'video' || MediaUtils.isVideoFile(mediaUrl)) {
      // Find the index of this post
      final index = widget.allPosts.indexWhere((p) => p['id'] == post['id']);
      if (index != -1) {
        return _buildVideoContent(index);
      }
    }
    
    // Handle as image
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width, // Make it square
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover, // Changed from contain to cover for better display
        placeholder: (context, url) => Container(
          color: Colors.grey.shade800,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('❌ Error loading image: $url - $error');
          return Container(
            color: Colors.grey.shade900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load media',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (MediaUtils.isVideoFile(mediaUrl))
                    Text(
                      'Video file detected',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Helper method to detect media type from URL
  String _getMediaTypeFromUrl(String url) {
    if (url.isEmpty) return 'image';
    
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.mp4') || lowerUrl.contains('.mov') || lowerUrl.contains('.avi') || lowerUrl.contains('.mkv')) {
      return 'video';
    }
    if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg') || lowerUrl.contains('.png') || lowerUrl.contains('.gif') || lowerUrl.contains('.webp')) {
      return 'image';
    }
    
    // Default to image if we can't determine
    return 'image';
  }
  
  // Helper method to check if file is video
  bool _isVideoFile(String url) {
    if (url.isEmpty) return false;
    
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') || lowerUrl.contains('.mov') || lowerUrl.contains('.avi') || lowerUrl.contains('.mkv');
  }

  Widget _buildVideoContent(int index) {
    if (!(_isVideoInitialized[index] == true) || _videoControllers[index] == null) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.width, // Make it square like images
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Ensure video is playing when widget is built
    if (_videoControllers[index] != null && 
        _videoControllers[index]!.value.isInitialized && 
        !_videoControllers[index]!.value.isPlaying) {
      // Auto-play if not already playing
      _videoControllers[index]!.play();
    }

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width, // Make it square like images
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoControllers[index]!.value.aspectRatio,
            child: VideoPlayer(_videoControllers[index]!),
          ),
          // Play/Pause overlay
          GestureDetector(
            onTap: () {
              setState(() {
                if (_videoControllers[index]!.value.isPlaying) {
                  _videoControllers[index]!.pause();
                } else {
                  _videoControllers[index]!.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _videoControllers[index]!.value.isPlaying ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _videoControllers[index]!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
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
      return '';
    }
  }
} 