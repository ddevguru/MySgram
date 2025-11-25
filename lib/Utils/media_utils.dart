import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class MediaUtils {
  /// Check if a URL points to a video file
  static bool isVideoFile(String url) {
    if (url.isEmpty) return false;
    
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') || 
           lowerUrl.contains('.mov') || 
           lowerUrl.contains('.avi') || 
           lowerUrl.contains('.wmv') || 
           lowerUrl.contains('.flv') || 
           lowerUrl.contains('.webm') ||
           lowerUrl.contains('.mkv') ||
           lowerUrl.contains('.3gp') ||
           lowerUrl.contains('.m4v');
  }
  
  /// Check if a URL points to an image file
  static bool isImageFile(String url) {
    if (url.isEmpty) return false;
    
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') || 
           lowerUrl.contains('.jpeg') || 
           lowerUrl.contains('.png') || 
           lowerUrl.contains('.gif') || 
           lowerUrl.contains('.webp') ||
           lowerUrl.contains('.bmp') ||
           lowerUrl.contains('.tiff');
  }
  
  /// Get media type from URL
  static String getMediaType(String url) {
    if (isVideoFile(url)) return 'video';
    if (isImageFile(url)) return 'image';
    return 'unknown';
  }
  
  /// Build appropriate media widget based on URL
  static Widget buildMediaWidget({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    VoidCallback? onTap,
    bool autoPlay = true, // Changed default to true for auto-play
  }) {
    if (isVideoFile(url)) {
      return _buildVideoWidget(
        url: url,
        width: width,
        height: height,
        onTap: onTap,
        autoPlay: autoPlay,
      );
    } else {
      return _buildImageWidget(
        url: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }
  }
  
  /// Build actual video widget with auto-play support
  static Widget _buildVideoWidget({
    required String url,
    required double width,
    required double height,
    VoidCallback? onTap,
    bool autoPlay = true,
  }) {
    return _VideoPlayerWidget(
      url: url,
      width: width,
      height: height,
      onTap: onTap,
      autoPlay: autoPlay,
    );
  }
  
  /// Build image widget with error handling
  static Widget _buildImageWidget({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder ?? (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      errorWidget: errorWidget ?? (context, url, error) {
        print('❌ Error loading image: $url - $error');
        return Container(
          width: width,
          height: height,
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
                if (isVideoFile(url))
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

/// Video player widget with auto-play support
class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool autoPlay;

  const _VideoPlayerWidget({
    required this.url,
    required this.width,
    required this.height,
    this.onTap,
    this.autoPlay = true,
  });

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print(' Initializing video: ${widget.url}');
      
      _controller = VideoPlayerController.network(widget.url);
      
      // Add error listener
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          print('❌ Video error: ${_controller!.value.errorDescription}');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        }
      });
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Auto-play if enabled
        if (widget.autoPlay) {
          await _controller!.play();
          _controller!.setLooping(true);
          _controller!.setVolume(1.0);
          print(' Auto-playing video: ${widget.url}');
        }
      }
    } catch (e) {
      print('❌ Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Video player
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
            // Play/Pause overlay
            if (widget.autoPlay)
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                    setState(() {});
                  },
                  child: AnimatedOpacity(
                    opacity: _controller!.value.isPlaying ? 0.0 : 0.7,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            // Video indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade800,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 