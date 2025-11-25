import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';

class StoryUploadTest extends StatefulWidget {
  const StoryUploadTest({Key? key}) : super(key: key);

  @override
  State<StoryUploadTest> createState() => _StoryUploadTestState();
}

class _StoryUploadTestState extends State<StoryUploadTest> {
  File? _selectedImage;
  String? _uploadStatus;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _uploadStatus = 'Image selected: ${image.path}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error picking image: $e';
      });
      print('❌ Error picking image: $e');
    }
  }

  Future<void> _uploadStory() async {
    if (_selectedImage == null) {
      setState(() {
        _uploadStatus = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading story...';
    });

    try {
      print('🔍 Starting story upload...');
      print('🔍 File path: ${_selectedImage!.path}');
      print('🔍 File exists: ${await _selectedImage!.exists()}');
      print('🔍 File size: ${await _selectedImage!.length()} bytes');

      final result = await AuthService.uploadStory(
        filePath: _selectedImage!.path,
        mediaType: 'image',
        caption: 'Test story from MySgram! 📸',
      );

      print('🔍 Upload result: $result');

      setState(() {
        _uploadStatus = 'Story uploaded successfully! ID: ${result['story_id']}';
        _isUploading = false;
      });

      Get.snackbar(
        'Success',
        'Story uploaded successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error uploading story: $e');
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _isUploading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to upload story: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Upload Test'),
        backgroundColor: Color(0xFFE9497E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image picker button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('Pick Image from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE9497E),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Selected image preview
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
            
            // Upload button
            ElevatedButton.icon(
              onPressed: _isUploading || _selectedImage == null ? null : _uploadStory,
              icon: _isUploading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Story'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Status display
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Status:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _uploadStatus ?? 'No action taken yet',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Debug info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Information:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Make sure you are logged in\n'
                    '• Check internet connection\n'
                    '• Verify backend is running\n'
                    '• Check file size (max 1GB)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
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
} 