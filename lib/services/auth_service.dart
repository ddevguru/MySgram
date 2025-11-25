import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class AuthService {
  static const String baseUrl = 'https://mysgram.com/auth';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Register user with email
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? profilePicture,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'profile_picture': profilePicture ?? '',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(data['token'], data['user']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Login with email
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(data['token'], data['user']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Google login
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
  }) async {
    try {
      print('🔍 Sending Google login request to backend...');
      print('🔍 URL: $baseUrl/google_signin.php');
      print('🔍 ID Token (first 20 chars): ${idToken.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$baseUrl/google_signin.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_token': idToken,
        }),
      );

      print('🔍 Backend Response Status: ${response.statusCode}');
      print('🔍 Backend Response Body: ${response.body}');

      String cleanResponse = response.body;

      if (response.statusCode == 301 || response.statusCode == 302) {
        print('⚠️ Redirect detected, trying to follow...');
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          print('🔍 Following redirect to: $redirectUrl');
          final redirectResponse = await http.post(
            Uri.parse(redirectUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'id_token': idToken,
            }),
          );
          cleanResponse = redirectResponse.body;
          print('🔍 Redirect Response Status: ${redirectResponse.statusCode}');
          print('🔍 Redirect Response Body: $cleanResponse');
        } else {
          throw Exception('Redirect detected but no location provided');
        }
      }

      if (cleanResponse.contains('<br />') || cleanResponse.contains('<b>') || cleanResponse.contains('<!DOCTYPE html>')) {
        int jsonStart = cleanResponse.indexOf('{');
        if (jsonStart != -1) {
          cleanResponse = cleanResponse.substring(jsonStart);
          print('🔍 Cleaned response: $cleanResponse');
        } else {
          throw Exception('No valid JSON found in response');
        }
      }

      final data = json.decode(cleanResponse);

      if (response.statusCode == 200 || (response.statusCode == 301 || response.statusCode == 302)) {
        print('✅ Backend authentication successful');
        await _saveAuthData(data['token'], data['user']);
        return data;
      } else {
        print('❌ Backend authentication failed');
        print('   Status Code: ${response.statusCode}');
        print('   Response Body: ${response.body}');
        print('   Parsed Data: $data');

        String errorMessage = 'Google login failed';
        if (data != null && data['message'] != null) {
          errorMessage = data['message'];
        } else if (response.statusCode == 301 || response.statusCode == 302) {
          errorMessage = 'Backend URL redirect detected. Please check configuration.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Backend endpoint not found. Please check URL: $baseUrl/google_signin.php';
        } else if (response.statusCode == 500) {
          errorMessage = 'Backend server error. Please try again later.';
        }

        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      print('❌ Network/Backend Error:');
      print('   Error Type: ${e.runtimeType}');
      print('   Error Message: $e');
      print('   Stack Trace: $stackTrace');
      throw Exception('Google login failed: $e');
    }
  }

  // Facebook login
  static Future<Map<String, dynamic>> facebookLogin({
    required String facebookToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/facebook_login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'facebook_token': facebookToken,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(data['token'], data['user']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Facebook login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Verify token
  static Future<Map<String, dynamic>> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/verify_token.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Token verification failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? fullName,
    String? profilePicture,
    String? bio,
    String? website,
    String? location,
    String? phone,
    String? gender,
    String? dateOfBirth,
    bool? isPrivate,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/update_profile.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
          if (username != null) 'username': username,
          if (fullName != null) 'full_name': fullName,
          if (profilePicture != null) 'profile_picture': profilePicture,
          if (bio != null) 'bio': bio,
          if (website != null) 'website': website,
          if (location != null) 'location': location,
          if (phone != null) 'phone': phone,
          if (gender != null) 'gender': gender,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
          if (isPrivate != null) 'is_private': isPrivate,
        }),
      );

      print('🔍 Update Profile Response Status: ${response.statusCode}');
      print('🔍 Update Profile Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await saveUserData(data['user']);
        return data;
      } else {
        print('❌ Profile update failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Password reset request failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Logout user
  static Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/logout.php'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          print('✅ Logout successful, online status updated');
        } else {
          print('⚠️ Logout API call failed, but continuing with local logout');
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      return true;
    } catch (e) {
      print('❌ Error during logout: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
      } catch (localError) {
        print('❌ Error clearing local storage: $localError');
      }
      return false;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final result = await verifyToken();
      return result != null;
    } catch (e) {
      print('Login check failed: $e');
      return false;
    }
  }

  // Save authentication data
  static Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, json.encode(user));
  }

  // Save user data only
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user));
  }

  // Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_profile_photo.php'),
      );

      request.fields['token'] = token;
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          imageFile.path,
        ),
      );

      print('🔍 Uploading profile photo...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Upload Profile Photo Response Status: ${response.statusCode}');
      print('🔍 Upload Profile Photo Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await saveUserData(data['user']);
        return data;
      } else {
        print('❌ Profile photo upload failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Profile photo upload failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload post media
  static Future<Map<String, dynamic>> uploadPostMedia(File mediaFile, String? caption) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_post.php'),
      );

      request.fields['token'] = token;
      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          mediaFile.path,
        ),
      );

      print('🔍 Uploading post media...');
      print('🔍 File path: ${mediaFile.path}');
      print('🔍 File exists: ${await mediaFile.exists()}');
      print('🔍 File size: ${await mediaFile.length()} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Upload Post Media Response Status: ${response.statusCode}');
      print('🔍 Upload Post Media Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        print('❌ Post media upload failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Post media upload failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload file to server
  static Future<Map<String, dynamic>> uploadFile(dynamic mediaFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_file.php'),
      );

      String filePath;
      if (mediaFile is File) {
        filePath = mediaFile.path;
      } else if (mediaFile is XFile) {
        filePath = mediaFile.path;
      } else {
        throw Exception('Invalid file type');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          filePath,
        ),
      );

      print('🔍 Uploading file...');
      print('🔍 File path: $filePath');
      print('🔍 File exists: ${await file.exists()}');
      print('🔍 File size: ${await file.length()} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Upload File Response Status: ${response.statusCode}');
      print('🔍 Upload File Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ File upload successful');
        return data;
      } else {
        print('❌ File upload failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'File upload failed');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Setup database tables
  static Future<Map<String, dynamic>> setupDatabase() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/setup_database.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Database Setup Response Status: ${response.statusCode}');
      print('🔍 Database Setup Response Body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Database setup error: $e');
    }
  }

  // Toggle like on post
  static Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/toggle_like.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
          'post_id': postId,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        try {
          final currentUser = await getCurrentUser();
          if (currentUser != null) {
            final postResponse = await http.get(
              Uri.parse('$baseUrl/get_post_owner.php?post_id=$postId'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );

            if (postResponse.statusCode == 200) {
              final postData = json.decode(postResponse.body);
              if (postData['success'] == true && postData['owner_id'] != currentUser['id'].toString()) {
                final isLiked = data['is_liked'] ?? false;
                if (isLiked) {
                  await NotificationService.notifyLike(
                    postData['owner_id'],
                    currentUser['id'].toString(),
                    postId.toString(),
                  );
                  print('✅ Like notification sent successfully');
                } else {
                  await NotificationService.notifyUnlike(
                    postData['owner_id'],
                    currentUser['id'].toString(),
                    postId.toString(),
                  );
                  print('✅ Unlike notification sent successfully');
                }
              }
            }
          }
        } catch (e) {
          print('❌ Error sending like notification: $e');
        }

        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to toggle like');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add comment to post
  static Future<Map<String, dynamic>> addComment(int postId, String commentText) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      print('🔍 Adding comment to post $postId: $commentText');

      final response = await http.post(
        Uri.parse('$baseUrl/add_comment.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
          'post_id': postId,
          'comment': commentText,
        }),
      );

      print('🔍 Add Comment Response Status: ${response.statusCode}');
      print('🔍 Add Comment Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        try {
          final currentUser = await getCurrentUser();
          if (currentUser != null) {
            final postResponse = await http.get(
              Uri.parse('$baseUrl/get_post_owner.php?post_id=$postId'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );

            if (postResponse.statusCode == 200) {
              final postData = json.decode(postResponse.body);
              if (postData['success'] == true && postData['owner_id'] != currentUser['id'].toString()) {
                await NotificationService.notifyComment(
                  postData['owner_id'],
                  currentUser['id'].toString(),
                  postId.toString(),
                  commentText,
                );
                print('✅ Comment notification sent successfully');
              }
            }
          }
        } catch (e) {
          print('❌ Error sending comment notification: $e');
        }

        return data;
      } else {
        print('❌ Add comment failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to add comment');
      }
    } catch (e) {
      print('❌ Add comment error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Add reply to comment
  static Future<Map<String, dynamic>> addReply({
    required int postId,
    required int parentCommentId,
    required String replyText,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add_reply.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
          'post_id': postId,
          'parent_comment_id': parentCommentId,
          'reply_text': replyText,
        }),
      );

      print('🔍 Add Reply Response Status: ${response.statusCode}');
      print('🔍 Add Reply Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        try {
          final currentUser = await getCurrentUser();
          if (currentUser != null) {
            final commentResponse = await http.get(
              Uri.parse('$baseUrl/get_comment_owner.php?comment_id=$parentCommentId'),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );

            if (commentResponse.statusCode == 200) {
              final commentData = json.decode(commentResponse.body);
              if (commentData['success'] == true && commentData['owner_id'] != currentUser['id'].toString()) {
                await NotificationService.notifyComment(
                  commentData['owner_id'],
                  currentUser['id'].toString(),
                  postId.toString(),
                  replyText,
                );
                print('✅ Reply notification sent successfully');
              }
            }
          }
        } catch (e) {
          print('❌ Error sending reply notification: $e');
        }

        return data;
      } else {
        print('❌ Add reply failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to add reply');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get comments for post
  static Future<Map<String, dynamic>> getComments(int postId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_comments.php?post_id=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get Comments Response Status: ${response.statusCode}');
      print('🔍 Get Comments Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        print('❌ Get comments failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to get comments');
      }
    } catch (e) {
      print('❌ Get comments error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Check and setup database tables
  static Future<Map<String, dynamic>> checkDatabase() async {
    try {
      try {
        final commentsResponse = await http.get(
          Uri.parse('$baseUrl/fix_comments_table.php'),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print('✅ Comments table fixed');
      } catch (e) {
        print('⚠️ Comments table fix failed: $e');
      }

      try {
        final storiesResponse = await http.get(
          Uri.parse('$baseUrl/create_stories_table.php'),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print('✅ Stories table created');
      } catch (e) {
        print('⚠️ Stories table creation failed: $e');
      }

      try {
        final streakResponse = await http.get(
          Uri.parse('$baseUrl/fix_streak_calculation.php'),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print('✅ Streak calculation fixed');
      } catch (e) {
        print('⚠️ Streak calculation fix failed: $e');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/test_all.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to check database');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Test streak display
  static Future<Map<String, dynamic>> testStreakDisplay() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test_streak_display.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to test streak display');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Debug profile data
  static Future<Map<String, dynamic>> debugProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/debug_profile.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to debug profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fix user streak
  static Future<Map<String, dynamic>> fixStreak() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/fix_streak.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fix streak');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Check user streak
  static Future<Map<String, dynamic>> checkStreak() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/check_streak.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
        }),
      );

      print('🔍 Check Streak Response Status: ${response.statusCode}');
      print('🔍 Check Streak Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        print('❌ Check streak failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Check streak failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Test database connection
  static Future<Map<String, dynamic>> testDatabase() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check_posts_table.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Database Test Response Status: ${response.statusCode}');
      print('🔍 Database Test Response Body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Database test error: $e');
    }
  }

  // Test file upload (for debugging)
  static Future<Map<String, dynamic>> testFileUpload(File mediaFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/test_upload.php'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          mediaFile.path,
        ),
      );

      print('🔍 Testing file upload...');
      print('🔍 File path: ${mediaFile.path}');
      print('🔍 File exists: ${await mediaFile.exists()}');
      print('🔍 File size: ${await mediaFile.length()} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Test Upload Response Status: ${response.statusCode}');
      print('🔍 Test Upload Response Body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Test upload error: $e');
    }
  }

  // Test simple upload
  static Future<Map<String, dynamic>> testSimpleUpload(dynamic file) async {
    try {
      print('🔍 Testing simple upload with file: ${file.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/simple_upload_test.php'),
      );

      if (file is XFile) {
        request.files.add(await http.MultipartFile.fromPath('test_file', file.path));
      } else if (file is File) {
        request.files.add(await http.MultipartFile.fromPath('test_file', file.path));
      }

      request.fields['test_field'] = 'test_value';
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      print('🔍 Sending simple upload request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Simple Upload Test Response Status: ${response.statusCode}');
      print('🔍 Simple Upload Test Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to test simple upload: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Simple upload test error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Upload reel
  static Future<Map<String, dynamic>> uploadReel({
    required String filePath,
    String? caption,
    int? duration,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_file.php'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      request.files.add(await http.MultipartFile.fromPath(
        'media',
        filePath,
      ));

      request.fields['caption'] = caption ?? '';
      request.fields['media_type'] = 'video';
      request.fields['post_type'] = 'reel';
      if (duration != null) {
        request.fields['duration'] = duration.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Upload Reel Response Status: ${response.statusCode}');
      print('🔍 Upload Reel Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Reel upload successful');
        return data;
      } else {
        print('❌ Upload reel failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Upload reel failed');
      }
    } catch (e) {
      print('❌ Upload reel error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Upload story
  static Future<Map<String, dynamic>> uploadStory({
    required String filePath,
    String? caption,
    String mediaType = 'image',
    int? duration,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_story.php'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      request.files.add(await http.MultipartFile.fromPath(
        'story_media',
        filePath,
      ));

      request.fields['caption'] = caption ?? '';
      request.fields['media_type'] = mediaType;
      if (duration != null) {
        request.fields['duration'] = duration.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Upload Story Response Status: ${response.statusCode}');
      print('🔍 Upload Story Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        print('❌ Upload story failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Upload story failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get stories
  static Future<Map<String, dynamic>> getStories() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var response = await http.get(
        Uri.parse('$baseUrl/get_stories.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get Stories Response Status: ${response.statusCode}');
      print('🔍 Get Stories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get stories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get stories error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get posts for feed
  static Future<Map<String, dynamic>> getPosts({int page = 1, int limit = 10}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_posts.php?token=$token&page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Get Posts Response Status: ${response.statusCode}');
      print('🔍 Get Posts Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        print('❌ Get posts failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to get posts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create simple post
  static Future<Map<String, dynamic>> createSimplePost({
    required String mediaUrl,
    required String mediaType,
    String? caption,
    String? thumbnailUrl,
    int? duration,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final userData = await getUserData();

      final response = await http.post(
        Uri.parse('$baseUrl/simple_post.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'media_url': mediaUrl,
          'media_type': mediaType,
          'caption': caption,
          'thumbnail_url': thumbnailUrl,
          'duration': duration,
          'user_id': userData?['id'] ?? '1',
          'username': userData?['username'] ?? 'user',
          'full_name': userData?['full_name'] ?? 'User',
          'profile_picture': userData?['profile_picture'] ?? '',
        }),
      );

      print('🔍 Create Simple Post Response Status: ${response.statusCode}');
      print('🔍 Create Simple Post Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        print('❌ Create simple post failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Create simple post failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create post (legacy method)
  static Future<Map<String, dynamic>> createPost({
    required String mediaUrl,
    required String mediaType,
    String? caption,
    String? thumbnailUrl,
    int? duration,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/create_post.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
          'media_url': mediaUrl,
          'media_type': mediaType,
          'caption': caption ?? '',
          'thumbnail_url': thumbnailUrl ?? mediaUrl,
          'duration': duration,
        }),
      );

      print('🔍 Create Post Response Status: ${response.statusCode}');
      print('🔍 Create Post Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        print('❌ Create post failed with status: ${response.statusCode}');
        print('❌ Error message: ${data['message']}');
        throw Exception(data['message'] ?? 'Create post failed');
      }
    } catch (e) {
      print('❌ Create post error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Test upload configuration
  static Future<Map<String, dynamic>> testUploadConfig() async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/test_upload_config.php'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Test Upload Config Response Status: ${response.statusCode}');
      print('🔍 Test Upload Config Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to test upload config: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Test upload config error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get public posts for explore page
  static Future<Map<String, dynamic>> getPublicPosts() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_public_posts.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Get Public Posts Response Status: ${response.statusCode}');
      print('🔍 Get Public Posts Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get public posts');
      }
    } catch (e) {
      print('❌ Error getting public posts: $e');
      throw Exception('Network error: $e');
    }
  }

  // Search users
  static Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/search_users.php?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Search Users Response Status: ${response.statusCode}');
      print('🔍 Search Users Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to search users');
      }
    } catch (e) {
      print('❌ Error searching users: $e');
      throw Exception('Network error: $e');
    }
  }

  // Search posts
  static Future<Map<String, dynamic>> searchPosts(String query) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/search_posts.php?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Search Posts Response Status: ${response.statusCode}');
      print('🔍 Search Posts Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to search posts');
      }
    } catch (e) {
      print('❌ Error searching posts: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get user ID by username
  static Future<String?> getUserIdByUsername(String username) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/search_users.php?query=$username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Search Users Response Status: ${response.statusCode}');
      print('🔍 Search Users Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['users'] != null) {
        final users = data['users'] as List;
        for (var user in users) {
          if (user['username'] == username) {
            return user['id'].toString();
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting user ID by username: $e');
      return null;
    }
  }

  // Get user profile by ID
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_user_profile.php?user_id=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Get User Profile Response Status: ${response.statusCode}');
      print('🔍 Get User Profile Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      print('❌ Error getting user profile: $e');
      throw Exception('Network error: $e');
    }
  }

  // Follow/Unfollow user
  static Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/follow_user.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'target_user_id': userId,
          'action': 'follow',
        }),
      );

      print('🔍 Follow User Response Status: ${response.statusCode}');
      print('🔍 Follow User Response Body: ${response.body}');

      final data = json.decode(response.body);
      print('🔍 Follow API response data: $data');

      if (response.statusCode == 200) {
        print('🔍 Follow successful, returning: $data');

        try {
          final currentUser = await getCurrentUser();
          if (currentUser != null) {
            await NotificationService.notifyFollow(
              userId,
              currentUser['id'].toString(),
            );
            print('✅ Follow notification sent successfully');
          }
        } catch (e) {
          print('❌ Error sending follow notification: $e');
        }

        return data;
      } else {
        final errorMessage = data['message'] ?? 'Failed to follow user';
        print('🔍 Follow failed with error: $errorMessage');

        if (errorMessage.contains('Already following this user')) {
          print('🔍 Handling "Already following" case gracefully');
          return {
            'success': true,
            'message': 'Already following this user',
            'is_following': true,
            'action': 'follow'
          };
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error following user: $e');
      throw Exception('Network error: $e');
    }
  }

  // Unfollow user
  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/follow_user.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'target_user_id': userId,
          'action': 'unfollow',
        }),
      );

      print('🔍 Unfollow User Response Status: ${response.statusCode}');
      print('🔍 Unfollow User Response Body: ${response.body}');

      final data = json.decode(response.body);
      print('🔍 Unfollow API response data: $data');

      if (response.statusCode == 200) {
        print('🔍 Unfollow successful, returning: $data');

        try {
          final currentUser = await getCurrentUser();
          if (currentUser != null) {
            await NotificationService.notifyUnfollow(
              userId,
              currentUser['id'].toString(),
            );
            print('✅ Unfollow notification sent successfully');
          }
        } catch (e) {
          print('❌ Error sending unfollow notification: $e');
        }

        return data;
      } else {
        final errorMessage = data['message'] ?? 'Failed to unfollow user';
        print('🔍 Unfollow failed with error: $errorMessage');

        if (errorMessage.contains('Not following this user')) {
          print('🔍 Handling "Not following" case gracefully');
          return {
            'success': true,
            'message': 'Not following this user',
            'is_following': false,
            'action': 'unfollow'
          };
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      throw Exception('Network error: $e');
    }
  }

  // Mark story as viewed
  static Future<Map<String, dynamic>> markStoryViewed(int storyId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var response = await http.post(
        Uri.parse('$baseUrl/mark_story_viewed.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'story_id': storyId,
        }),
      );

      print('🔍 Mark Story Viewed Response Status: ${response.statusCode}');
      print('🔍 Mark Story Viewed Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark story as viewed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Mark story viewed error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get story views
  static Future<Map<String, dynamic>> getStoryViews(int storyId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      var response = await http.get(
        Uri.parse('$baseUrl/get_story_views.php?story_id=$storyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get Story Views Response Status: ${response.statusCode}');
      print('🔍 Get Story Views Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get story views: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get story views error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Delete expired stories
  static Future<Map<String, dynamic>> deleteExpiredStories() async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/delete_expired_stories.php'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Delete Expired Stories Response Status: ${response.statusCode}');
      print('🔍 Delete Expired Stories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete expired stories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Delete expired stories error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userData = prefs.getString(userKey);
      if (userData != null) {
        final user = json.decode(userData);
        if (user['id'] != null) {
          print('🔍 Got user ID from stored user data: ${user['id']}');
          return user['id'].toString();
        }
      }

      final token = prefs.getString(tokenKey);
      if (token != null) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final resp = utf8.decode(base64Url.decode(normalized));
            final payloadMap = json.decode(resp);

            if (payloadMap['user_id'] != null) {
              print('🔍 Got user ID from JWT token: ${payloadMap['user_id']}');
              return payloadMap['user_id'].toString();
            }
          }
        } catch (e) {
          print('❌ Error decoding JWT token: $e');
        }
      }

      print('❌ No user ID found in stored data or token');
      return null;
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      return null;
    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(userKey);
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // Test backend connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test_connection.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Test Connection Response Status: ${response.statusCode}');
      print('🔍 Test Connection Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Test connection failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Test connection error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get notifications
  static Future<Map<String, dynamic>> getNotifications({String? type, int? limit, int? offset}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      String url = '$baseUrl/get_notifications.php';
      List<String> params = [];

      if (type != null && type != 'all') {
        params.add('type=$type');
      }
      if (limit != null) {
        params.add('limit=$limit');
      }
      if (offset != null) {
        params.add('offset=$offset');
      }

      if (params.isNotEmpty) {
        url += '?' + params.join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get Notifications Response Status: ${response.statusCode}');
      print('🔍 Get Notifications Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get notifications error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/mark_notification_read.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'notification_id': notificationId,
        }),
      );

      print('🔍 Mark Notification Read Response Status: ${response.statusCode}');
      print('🔍 Mark Notification Read Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Mark notification as read error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create notifications table
  static Future<Map<String, dynamic>> createNotificationsTable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/create_notifications_table.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Create Notifications Table Response Status: ${response.statusCode}');
      print('🔍 Create Notifications Table Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create notifications table: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Create notifications table error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Add sample notifications
  static Future<Map<String, dynamic>> addSampleNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/add_sample_notifications.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Add Sample Notifications Response Status: ${response.statusCode}');
      print('🔍 Add Sample Notifications Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add sample notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Add sample notifications error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Create stories table
  static Future<Map<String, dynamic>> createStoriesTable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/create_stories_table.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Create Stories Table Response Status: ${response.statusCode}');
      print('🔍 Create Stories Table Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create stories table: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Create stories table error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Add sample stories
  static Future<Map<String, dynamic>> addSampleStories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/add_sample_stories.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Add Sample Stories Response Status: ${response.statusCode}');
      print('🔍 Add Sample Stories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add sample stories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Add sample stories error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get followers list for a user
  static Future<Map<String, dynamic>> getFollowers(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_followers.php?user_id=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Get Followers Response Status: ${response.statusCode}');
      print('🔍 Get Followers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get followers: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get followers error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get following list for a user
  static Future<Map<String, dynamic>> getFollowing(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_following.php?user_id=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Get Following Response Status: ${response.statusCode}');
      print('🔍 Get Following Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get following: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get following error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get stories with view status
  static Future<Map<String, dynamic>> getStoriesWithViewStatus() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_stories_with_view_status.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 Get Stories with View Status Response Status: ${response.statusCode}');
      print('🔍 Get Stories with View Status Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get stories with view status');
      }
    } catch (e) {
      print('❌ Error getting stories with view status: $e');
      throw Exception('Network error: $e');
    }
  }
}