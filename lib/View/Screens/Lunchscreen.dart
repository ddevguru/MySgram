import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/auth_service.dart';
import 'Signinpage.dart';
import 'Signuppage.dart';
import 'Bottombar.dart';

class Lunchscreen extends StatelessWidget {
  const Lunchscreen({super.key});

  Future<void> _handleGoogleSignIn() async {
    try {
      // For google_sign_in 6.x - use constructor
      final googleSignIn = GoogleSignIn(
        serverClientId: '1028002440504-ft3ono2iier6oceh5che9e8u1j5o8d9m.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // Sign out existing session
      if (await googleSignIn.isSignedIn()) {
        print('🔍 Signing out existing Google session');
        await googleSignIn.signOut();
      }

      // Trigger Google Sign-In using signIn() for v6.x
      print('🔍 Initiating Google Sign-In (v6.x)');
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('ℹ️ Google Sign-In cancelled by user');
        return; // Don't show error for user cancellation
      }

      // Get authentication tokens
      print('🔍 Retrieving Google authentication tokens');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print('❌ Failed to get Google ID token');
        Get.snackbar(
          'Error',
          'Failed to get authentication token',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      print('🔍 Google User: ${googleUser.email}');
      print('🔍 ID Token (first 20 chars): ${idToken.substring(0, 20)}...');

      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        barrierDismissible: false,
      );

      // Call AuthService with idToken
      final result = await AuthService.googleLogin(idToken: idToken);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('🔍 AuthService Result: $result');

      if (result['success'] == true || result.containsKey('token')) {
        print('✅ Google login successful, navigating to Bottombar');
        Get.snackbar(
          'Success',
          'Signed in successfully!',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => Bottombar());
      } else {
        print('❌ Google login failed: ${result['message']}');
        Get.snackbar(
          'Login Failed',
          result['message'] ?? 'Google login failed',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Check for cancellation
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('cancel') ||
          errorString.contains('user') ||
          errorString.contains('12501')) {
        print('ℹ️ User cancelled Google Sign-In');
        return;
      }

      // Check for network errors
      if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('7')) {
        print('❌ Network Error: $e');
        Get.snackbar(
          'Network Error',
          'Please check your internet connection',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Generic error
      print('❌ Google Sign-In Error: $e\n$stackTrace');
      Get.snackbar(
        'Error',
        'Google sign-in failed. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9B86FF),
              Color(0xFF535AF4),
              Color(0xFF535AF4),
              Color(0xFF9B86FF),
            ],
            stops: [0.0, 0.33, 0.67, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              children: [
                SizedBox(height: height * 0.03),
                Image.asset(
                  'assets/openapplogo.png',
                  width: width * 0.85,
                  height: height * 0.35,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: height * 0.02),
                const Text(
                  'Sign up to see photos and videos from your friends.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.08),
                Container(
                  width: width * 0.84,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Get.to(() => Signinpage()),
                      child: const Center(
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Color(0xFF535AF4),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                GestureDetector(
                  onTap: () => Get.to(() => Signuppage()),
                  child: const Text(
                    'Sign Up With Phone or Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                Container(
                  width: width * 0.84,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _handleGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.g_mobiledata,
                              color: Colors.red[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Color(0xFF535AF4),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                // GestureDetector(
                //   onTap: () async {
                //     final prefs = await SharedPreferences.getInstance();
                //     await prefs.setBool('is_guest_user', true);
                //     Get.offAll(() => Bottombar());
                //   },
                //   child: Text(
                //     'Continue as Guest',
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(0.8),
                //       fontSize: 14,
                //       fontWeight: FontWeight.w500,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: height * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an Account? ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => Signinpage()),
                        child: const Text(
                          'Sign In.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
        ),
      ),
    );
  }
}