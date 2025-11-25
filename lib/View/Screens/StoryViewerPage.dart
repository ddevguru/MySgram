import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // Added for Share
import 'package:share_plus/share_plus.dart'; // Added for Share.share

class StoryViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewerPage({
    Key? key,
    required this.stories,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _StoryViewerPageState createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  Set<int> _viewedStories = {};
  Timer? _autoSwipeTimer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentUserIndex);
    _progressController = AnimationController(
      duration: Duration(seconds: 45), // 45 seconds auto-swipe
      vsync: this,
    );
    
    _markCurrentStoryAsViewed();
    _startAutoSwipeTimer();
    _initializeVideo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _videoController?.dispose();
    _autoSwipeTimer?.cancel();
    super.dispose();
  }

  void _startAutoSwipeTimer() {
    _autoSwipeTimer?.cancel();
    _autoSwipeTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isPaused && mounted) {
        _progressController.forward();
        if (_progressController.value >= 1.0) {
          _nextStory();
        }
      }
    });
  }

  void _pauseTimer() {
    _isPaused = true;
    _autoSwipeTimer?.cancel();
  }

  void _resumeTimer() {
    _isPaused = false;
    _startAutoSwipeTimer();
  }

  void _nextStory() {
    if (_currentUserIndex < widget.stories.length - 1) {
      _currentUserIndex++;
      _currentStoryIndex = 0;
      _pageController.animateToPage(
        _currentUserIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back(); // Close when all stories are viewed
    }
    _resetProgress();
    _markCurrentStoryAsViewed();
    _initializeVideo();
  }

  void _previousStory() {
    if (_currentUserIndex > 0) {
      _currentUserIndex--;
      _currentStoryIndex = 0;
      _pageController.animateToPage(
        _currentUserIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _resetProgress();
    _markCurrentStoryAsViewed();
    _initializeVideo();
  }

  void _resetProgress() {
    _progressController.reset();
    _startAutoSwipeTimer();
  }

  void _initializeVideo() {
    print('🔍 === VIDEO INITIALIZATION START ===');
    
    if (_videoController != null) {
      print('🔍 Disposing previous video controller');
      _videoController!.dispose();
    }
    _isVideoInitialized = false;

    try {
      if (widget.stories.isEmpty) {
        print('❌ No stories available');
        return;
      }
      
      if (_currentUserIndex >= widget.stories.length) {
        print('❌ Current user index out of bounds: $_currentUserIndex >= ${widget.stories.length}');
        return;
      }
      
      final currentStory = widget.stories[_currentUserIndex];
      print('🔍 Current story data: $currentStory');
      print('🔍 Media URL: ${currentStory['media_url']}');
      print('🔍 Media type: ${currentStory['media_type']}');
      
      if (currentStory['media_type'] == 'video') {
        print('🔍 Creating video controller for URL: ${currentStory['media_url']}');
        
        // Create video controller
        _videoController = VideoPlayerController.network(currentStory['media_url']);
        
        // Add error listener
        _videoController!.addListener(() {
          if (_videoController!.value.hasError) {
            print('❌ Video controller error: ${_videoController!.value.errorDescription}');
          }
        });
        
        // Initialize video
        _videoController!.initialize().then((_) {
          print('✅ Video initialized successfully');
          print('🔍 Video duration: ${_videoController!.value.duration}');
          print('🔍 Video size: ${_videoController!.value.size}');
          
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            
            // Force play the video
            print('🔍 Starting video playback...');
            _videoController!.play();
            _videoController!.setLooping(true);
            
            // Add listener to track play state
            _videoController!.addListener(() {
              if (mounted) {
                setState(() {
                  // Force rebuild to update UI
                });
              }
            });
            
            print('✅ Video started playing');
          } else {
            print('❌ Widget not mounted, skipping play');
          }
        }).catchError((e) {
          print('❌ Error initializing video: $e');
          print('❌ Error stack trace: ${StackTrace.current}');
        });
      } else {
        print('🔍 Not a video story, skipping video initialization');
        print('🔍 Media type was: ${currentStory['media_type']}');
      }
    } catch (e) {
      print('❌ Error in _initializeVideo: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
    }
    
    print('🔍 === VIDEO INITIALIZATION END ===');
  }

  void _markCurrentStoryAsViewed() {
    try {
      if (widget.stories.isEmpty || 
          _currentUserIndex >= widget.stories.length) {
        return;
      }
      
      final currentStory = widget.stories[_currentUserIndex];
      final storyId = int.tryParse(currentStory['id'].toString());
      
      if (storyId != null && !_viewedStories.contains(storyId)) {
        _viewedStories.add(storyId);
        AuthService.markStoryViewed(storyId).catchError((e) {
          print('❌ Error marking story as viewed: $e');
        });
      }
    } catch (e) {
      print('❌ Error in _markCurrentStoryAsViewed: $e');
    }
  }

  void _showStoryViews() {
    try {
      if (widget.stories.isEmpty || 
          _currentUserIndex >= widget.stories.length) {
        return;
      }
      
      final currentStory = widget.stories[_currentUserIndex];
      final storyId = int.tryParse(currentStory['id'].toString());
      
      if (storyId != null) {
        AuthService.getStoryViews(storyId).then((result) {
          if (result['views'] != null) {
            final views = result['views'] as List;
            Get.dialog(
              AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Story Views (${views.length})'),
                  ],
                ),
                content: Container(
                  width: double.maxFinite,
                  height: 400,
                  child: Column(
                    children: [
                      // View count summary
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${views.length} views',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Story posted ${_getTimeAgo(currentStory['created_at'])}',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Views list
                      Expanded(
                        child: views.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.visibility_off,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No views yet',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Your story will appear here once someone views it',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: views.length,
                                itemBuilder: (context, index) {
                                  final view = views[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: view['profile_picture'] != null && view['profile_picture'].toString().isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  view['profile_picture'],
                                                )
                                              : null,
                                          backgroundColor: Colors.grey.shade300,
                                          child: view['profile_picture'] == null || view['profile_picture'].toString().isEmpty
                                              ? Icon(Icons.person, color: Colors.grey.shade600)
                                              : null,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                view['full_name'] ?? view['username'] ?? 'Unknown User',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '@${view['username'] ?? 'unknown'}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              view['time_ago'] ?? '',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.visibility,
                                                    size: 12,
                                                    color: Colors.green.shade700,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Viewed',
                                                    style: TextStyle(
                                                      color: Colors.green.shade700,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                  ),
                ],
              ),
            );
          }
        }).catchError((e) {
          print('❌ Error getting story views: $e');
          Get.snackbar(
            'Error',
            'Failed to load story views',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
      }
    } catch (e) {
      print('❌ Error in _showStoryViews: $e');
    }
  }

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);
      
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

  Widget _buildImageStory(Map<String, dynamic> story) {
    print('🔍 Building image story for: ${story['media_url']}');
    
    // Check if URL is valid
    final mediaUrl = story['media_url'] ?? '';
    if (mediaUrl.isEmpty || mediaUrl.contains('mysgram.com')) {
      // Show placeholder for invalid URLs
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Story Image Unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This story image could not be loaded',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('❌ Error loading image: $error for URL: $url');
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'URL: ${story['media_url']}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoStory(Map<String, dynamic> story) {
    print('🔍 Building video story for: ${story['media_url']}');
    print('🔍 Video controller: $_videoController');
    print('🔍 Is video initialized: $_isVideoInitialized');
    
    if (_videoController == null) {
      print('❌ Video controller is null');
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Video not available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isVideoInitialized) {
      print('❌ Video not initialized yet');
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'URL: ${story['media_url']}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_videoController!.value.hasError) {
      print('❌ Video has error: ${_videoController!.value.errorDescription}');
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Error loading video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _videoController!.value.errorDescription ?? 'Unknown error',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    print('✅ Building video player widget');
    return GestureDetector(
      onTap: () {
        if (_videoController != null && _isVideoInitialized) {
          if (_videoController!.value.isPlaying) {
            print('🔍 Pausing video');
            _videoController!.pause();
          } else {
            print('🔍 Playing video');
            _videoController!.play();
          }
        }
      },
      child: Stack(
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          // Auto-play indicator (temporary)
          if (!_videoController!.value.isPlaying)
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to play',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserStories(Map<String, dynamic> userStories, int userIndex) {
    try {
      // Since we're passing individual stories, not grouped stories
      final currentStory = userStories;
      
      return GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final tapY = details.globalPosition.dy;
          final tapX = details.globalPosition.dx;
          
          // Swipe up to see views (top 20% of screen)
          if (tapY < screenHeight * 0.2) {
            _showStoryViews();
            return;
          }
          
          // Left/right navigation (Instagram-like)
          if (tapX < screenWidth / 3) {
            // Left third: previous story
            _previousStory();
          } else if (tapX > screenWidth * 2 / 3) {
            // Right third: next story
            _nextStory();
          }
          // Middle third: do nothing (pause/resume timer)
        },
        onLongPressStart: (details) {
          _pauseTimer();
        },
        onLongPressEnd: (details) {
          _resumeTimer();
        },
        onVerticalDragEnd: (details) {
          // Swipe up to see views (Instagram-like)
          if (details.primaryVelocity! < -500) { // Swipe up
            _showStoryViews();
          }
        },
        child: Stack(
          children: [
            // Story content
            Container(
              width: double.infinity,
              height: double.infinity,
              child: currentStory['media_type'] == 'video'
                  ? _buildVideoStory(currentStory)
                  : _buildImageStory(currentStory),
            ),

            // Progress bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Progress indicators
                    Row(
                      children: List.generate(
                        widget.stories.length,
                        (index) => Expanded(
                          child: Container(
                            height: 2,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index == userIndex ? Colors.white : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // User info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: CachedNetworkImageProvider(
                            currentStory['profile_picture'] ?? '',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStory['username'] ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getTimeAgo(currentStory['created_at']),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Removed view button for cleaner Instagram-like experience
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Caption
            if (currentStory['caption'] != null && currentStory['caption'].toString().isNotEmpty)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentStory['caption'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Swipe up indicator (only for story owner)
            if (currentStory['user_id'] == '1') // Replace with actual current user ID
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Swipe up to see views',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Swipe up to see views (Instagram-like)
            if (currentStory['user_id'] == '2') // Show for story owner
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Swipe up to see views',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Error in _buildUserStories: $e');
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Error loading story',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }
  }

  void _showReplyDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Reply to Story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reply functionality coming soon!'),
            SizedBox(height: 16),
            Text(
              'You will be able to reply to stories with text, images, or videos.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    try {
      final currentStory = widget.stories[widget.initialIndex];
      final caption = currentStory['caption'] ?? 'Check out this story from MySgram!';
      final mediaUrl = currentStory['media_url'] ?? '';
      final shareText = '$caption\n\n$mediaUrl\n\nShared from MySgram';
      
      // Use system share
      Share.share(shareText, subject: 'Check out this story!');
      
      Get.back();
      Get.snackbar(
        'Shared!',
        'Story shared successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error sharing story: $e');
      Get.snackbar(
        'Error',
        'Failed to share story',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No stories available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentUserIndex = index;
            _currentStoryIndex = 0;
          });
          _resetProgress();
          _markCurrentStoryAsViewed();
          _initializeVideo();
        },
        itemCount: widget.stories.length,
        itemBuilder: (context, index) {
          return _buildUserStories(widget.stories[index], index);
        },
      ),
    );
  }
} 