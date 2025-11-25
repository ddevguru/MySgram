import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysgram/View/Screens/Bottombar.dart';
import 'package:mysgram/View/Screens/Signuppage.dart';
import 'package:mysgram/View/Screens/Personaldatapage.dart';
import 'package:mysgram/services/auth_service.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing when keyboard appears
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9B86FF), // Light purple at top
              Color(0xFF535AF4), // Medium purple in middle
              Color(0xFF535AF4), // Continue medium purple
              Color(0xFF9B86FF), // Light purple at bottom
            ],
            stops: [0.0, 0.33, 0.67, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              children: [
                // Top spacing
                // SizedBox(height: height * 0.08),

                // App Logo
                Container(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/openapplogo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                // SizedBox(height: height * 0.03),

                // App Title

                SizedBox(height: height * 0.01),

                // Username/Email Field
                Container(
                  width: width * 0.84,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email Or Username',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // Password Field
                Container(
                  width: width * 0.84,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      suffixIcon: Icon(
                        Icons.visibility_off,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Log In Button
                Container(
                  width: width * 0.84,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter email and password',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          print('🚀 Starting email login...');
                          
                          final result = await AuthService.login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          
                          if (result != null) {
                            print('✅ Email login successful');
                            Get.snackbar(
                              'Success',
                              'Login successful!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                            
                            // Navigate to main app
                            Get.offAll(() => Bottombar());
                          } else {
                            print('❌ Email login failed');
                            Get.snackbar(
                              'Error',
                              'Login failed. Please check your credentials.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          print('❌ Email login error: $e');
                          Get.snackbar(
                            'Error',
                            'Login failed: ${e.toString()}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Forgot Password
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(text: 'Forget your login details? '),
                      TextSpan(
                        text: 'Get help Signing in.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.04),

                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.04),

                // Facebook Login
                
                

                SizedBox(
                    height: height *
                        0.02), // Extra spacing to ensure content visibility

                // Sign Up Text
                Padding(
                  padding: EdgeInsets.only(bottom: height * 0.04),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(text: "Don't have an Account? "),
                        TextSpan(
                          text: 'Sign Up.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(Signuppage());
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
      ),
    );
  }
}
