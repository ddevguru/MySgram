import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysgram/services/auth_service.dart';
import 'package:mysgram/View/Screens/Profilepage.dart';
import 'package:mysgram/View/Screens/Bottombar.dart';
import 'dart:io';
import 'package:flutter/services.dart';

// Camera Controller
class CameraController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final RxBool isCameraMode = true.obs;
  final RxBool isVideoMode = false.obs;
  final RxBool isReelMode = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isCameraInitialized = false.obs;
  
  // Store XFile instead of File for better compatibility
  var selectedImage = Rx<XFile?>(null);
  var selectedVideo = Rx<XFile?>(null);
  var videoController = Rx<VideoPlayerController?>(null);
  
  // Caption controller for post text
  final TextEditingController captionController = TextEditingController();

  @override
  void onClose() {
    videoController.value?.dispose();
    super.onClose();
  }

  // Toggle camera mode
  void toggleCameraMode() {
    isCameraMode.value = !isCameraMode.value;
    isVideoMode.value = false;
    isReelMode.value = false;
  }

  // Toggle video mode
  void toggleVideoMode() {
    isVideoMode.value = !isVideoMode.value;
    isCameraMode.value = false;
    isReelMode.value = false;
  }

  // Toggle reel mode
  void toggleReelMode() {
    isReelMode.value = !isReelMode.value;
    isCameraMode.value = false;
    isVideoMode.value = false;
  }

  // Toggle flash
  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
  }

  // Toggle camera direction
  void toggleCameraDirection() {
    isFrontCamera.value = !isFrontCamera.value;
  }

  // Take photo
  Future<void> takePhoto() async {
    try {
      isProcessing.value = true;
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: isFrontCamera.value ? CameraDevice.front : CameraDevice.rear,
      );
      
      if (image != null) {
        selectedImage.value = image;
        selectedVideo.value = null;
        videoController.value?.dispose();
        videoController.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      isProcessing.value = true;
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedImage.value = image;
        selectedVideo.value = null;
        videoController.value?.dispose();
        videoController.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Record video
  Future<void> recordVideo() async {
    try {
      isProcessing.value = true;
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(minutes: 15), // 15 minutes for videos
        preferredCameraDevice: isFrontCamera.value ? CameraDevice.front : CameraDevice.rear,
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

        print('🔍 Video recorded: ${video.path}');
        selectedVideo.value = video;
        selectedImage.value = null;
        
        // Initialize video controller
        print('🔍 Initializing video controller...');
        videoController.value?.dispose();
        videoController.value = VideoPlayerController.file(file);
        
        await videoController.value!.initialize();
        print('🔍 Video controller initialized');
        
        // Auto-play video
        print('🔍 Starting video playback...');
        videoController.value!.play();
        // Loop video
        videoController.value!.setLooping(true);
        
        // Add listener to track play state
        videoController.value!.addListener(() {
          // Force UI update when video state changes
        });
        
        print('🔍 Video started playing');
      }
    } catch (e) {
      print('❌ Error recording video: $e');
      Get.snackbar(
        'Error',
        'Failed to record video: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Pick video from gallery
  Future<void> pickVideoFromGallery() async {
    try {
      isProcessing.value = true;
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 15), // 15 minutes for videos
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

        print('🔍 Video selected: ${video.path}');
        selectedVideo.value = video;
        selectedImage.value = null;
        
        // Initialize video controller
        print('🔍 Initializing video controller...');
        videoController.value?.dispose();
        videoController.value = VideoPlayerController.file(file);
        
        await videoController.value!.initialize();
        print('🔍 Video controller initialized');
        
        // Auto-play video
        print('🔍 Starting video playback...');
        videoController.value!.play();
        // Loop video
        videoController.value!.setLooping(true);
        print('🔍 Video started playing');
      }
    } catch (e) {
      print('❌ Error picking video: $e');
      Get.snackbar(
        'Error',
        'Failed to pick video: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Post media (image or video)
  Future<void> postMedia() async {
    // Check for guest mode first
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest_user') ?? false;
    
    if (isGuest) {
      Get.snackbar(
        'Sign Up Required',
        'Please sign up to create and share posts',
        backgroundColor: Color(0xFF535AF4),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

    if (selectedImage.value == null && selectedVideo.value == null) {
      Get.snackbar(
        'Error',
        'Please select an image or video first',
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
                'Uploading...',
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

    try {
      String caption = captionController.text.trim();
      
      if (selectedVideo.value != null) {
        // Handle video upload (reel)
        final xfile = selectedVideo.value!;
        print('🔍 Uploading video reel...');
        print('🔍 File path: ${xfile.path}');
        
        // Check if file exists
        final file = File(xfile.path);
        print('🔍 File exists: ${await file.exists()}');
        print('🔍 File size: ${await file.length()} bytes');

        // Step 1: Upload video as reel
        final uploadResult = await AuthService.uploadReel(
          filePath: xfile.path,
          caption: caption.isNotEmpty ? caption : 'Posted from MySgram! 🎬',
        );
        print('🔍 Upload result: $uploadResult');

        // Step 2: Create post
        final result = await AuthService.createPost(
          mediaUrl: uploadResult['media_url'],
          mediaType: uploadResult['file_type'] ?? 'video', // Use file_type instead of media_type
          caption: caption.isNotEmpty ? caption : 'Posted from MySgram! 🎬',
        );

        print('🔍 Create post result: $result');
      } else if (selectedImage.value != null) {
        // Handle image upload
        final xfile = selectedImage.value!;
        print('🔍 Uploading image...');
        print('🔍 File path: ${xfile.path}');
        
        // Check if file exists
        final file = File(xfile.path);
        print('🔍 File exists: ${await file.exists()}');
        print('🔍 File size: ${await file.length()} bytes');

        // Step 1: Upload file - pass XFile directly
        final uploadResult = await AuthService.uploadFile(xfile);
        print('🔍 Upload result: $uploadResult');

        // Step 2: Create post
        final result = await AuthService.createPost(
          mediaUrl: uploadResult['media_url'],
          mediaType: uploadResult['file_type'] ?? 'image', // Use file_type instead of media_type
          caption: caption.isNotEmpty ? caption : 'Posted from MySgram! 📸',
        );

        print('🔍 Create post result: $result');
      }

      // Close dialog
      Get.back();
      
      Get.snackbar(
        'Success',
        'Post uploaded successfully! 🎉',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      
      // Navigate to profile page after success
      Future.delayed(Duration(seconds: 2), () {
        Get.offAll(() => Bottombar());
      });
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar(
        'Error',
        'Failed to post media. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Post error: $e');
    }
  }

  // Clear selected media
  void clearMedia() {
    selectedImage.value = null;
    selectedVideo.value = null;
    videoController.value?.dispose();
    videoController.value = null;
  }
}

class Photopage extends StatelessWidget {
  const Photopage({super.key});

  @override
  Widget build(BuildContext context) {
    final CameraController controller = Get.put(CameraController());
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  Text(
                    'New Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(() => TextButton(
                    onPressed: (controller.selectedImage.value != null || controller.selectedVideo.value != null)
                        ? controller.postMedia
                        : null,
                    child: Text(
                      'Share',
                      style: TextStyle(
                        color: (controller.selectedImage.value != null || controller.selectedVideo.value != null)
                            ? Colors.blue
                            : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // Mode Selector
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeButton(
                    'Photo',
                    Icons.camera_alt,
                    controller.isCameraMode,
                    controller.toggleCameraMode,
                  ),
                  _buildModeButton(
                    'Video',
                    Icons.videocam,
                    controller.isVideoMode,
                    controller.toggleVideoMode,
                  ),
                  _buildModeButton(
                    'Reel',
                    Icons.music_note,
                    controller.isReelMode,
                    controller.toggleReelMode,
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.selectedImage.value != null) {
                  return _buildImagePreview(controller);
                } else if (controller.selectedVideo.value != null) {
                  return _buildVideoPreview(controller);
                } else {
                  return _buildCameraInterface(controller);
                }
              }),
            ),

            // Bottom Controls
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  IconButton(
                    onPressed: controller.pickImageFromGallery,
                    icon: Icon(Icons.photo_library, color: Colors.white, size: 28),
                  ),
                  
                  // Capture Button
                  Obx(() => GestureDetector(
                    onTap: () {
                      if (controller.isCameraMode.value) {
                        controller.takePhoto();
                      } else if (controller.isVideoMode.value) {
                        controller.recordVideo();
                      } else {
                        controller.recordVideo();
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.transparent,
                      ),
                      child: Icon(
                        controller.isVideoMode.value ? Icons.fiber_manual_record : Icons.camera,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  )),
                  
                  // Camera Switch
                  IconButton(
                    onPressed: controller.toggleCameraDirection,
                    icon: Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String title, IconData icon, RxBool isActive, VoidCallback onTap) {
    return Obx(() => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive.value ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildCameraInterface(CameraController controller) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Select or Capture Media',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose from gallery or take a photo/video',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.pickImageFromGallery,
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.takePhoto,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Test Upload Configuration Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    controller.isProcessing.value = true;
                    final result = await AuthService.testUploadConfig();
                    Get.dialog(
                      AlertDialog(
                        title: Text('Upload Configuration Test'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Status: ${result['status']}'),
                              SizedBox(height: 10),
                              Text('PHP Config:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...(result['php_config'] as Map<String, dynamic>).entries.map((e) => 
                                Text('${e.key}: ${e.value}')
                              ),
                              SizedBox(height: 10),
                              Text('Directory Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...(result['dir_permissions'] as Map<String, dynamic>).entries.map((e) => 
                                Text('${e.key}: ${e.value}')
                              ),
                              SizedBox(height: 10),
                              Text('Test Write: ${result['test_write_success']}'),
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
                  } catch (e) {
                    Get.snackbar(
                      'Test Failed',
                      e.toString(),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } finally {
                    controller.isProcessing.value = false;
                  }
                },
                icon: Icon(Icons.bug_report),
                label: Text('Test Upload Config'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(CameraController controller) {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Image.file(
                  File(controller.selectedImage.value!.path),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: controller.clearMedia,
                    icon: Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Caption input
        Container(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: controller.captionController,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(CameraController controller) {
    return Column(
      children: [
        // Video preview
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Obx(() => controller.videoController.value != null
                    ? AspectRatio(
                        aspectRatio: controller.videoController.value!.value.aspectRatio,
                        child: VideoPlayer(controller.videoController.value!),
                      )
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_file, color: Colors.white, size: 80),
                              SizedBox(height: 16),
                              Text(
                                'Video Loading...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: controller.clearMedia,
                    icon: Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                // Play/Pause button (only show if video is not playing)
                Obx(() => controller.videoController.value != null && 
                         !controller.videoController.value!.value.isPlaying
                    ? Positioned(
                        bottom: 16,
                        left: 16,
                        child: IconButton(
                          onPressed: () {
                            if (controller.videoController.value != null) {
                              print('🔍 Playing video manually');
                              controller.videoController.value!.play();
                            }
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
              ],
            ),
          ),
        ),
        // Caption input
        Container(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: controller.captionController,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
