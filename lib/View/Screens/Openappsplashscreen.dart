import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysgram/View/Screens/Lunchscreen.dart';
import 'package:mysgram/View/Screens/Bottombar.dart';
import 'package:mysgram/services/auth_service.dart';

class Openappsplashscreen extends StatefulWidget {
  const Openappsplashscreen({super.key});

  @override
  State<Openappsplashscreen> createState() => _OpenappsplashscreenState();
}

class _OpenappsplashscreenState extends State<Openappsplashscreen>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _scaleController;
  late Animation<double> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Color animation controller
    _colorController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Color animation
    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _colorController.forward();
    _scaleController.forward();

    // Check for auto-login and navigate accordingly
    Future.delayed(Duration(seconds: 3), () async {
      try {
        final isLoggedIn = await AuthService.isLoggedIn();
        if (isLoggedIn) {
          print('✅ Auto-login successful, navigating to main app');
          Get.offAll(() => Bottombar());
        } else {
          // Check for guest mode
          final prefs = await SharedPreferences.getInstance();
          final isGuest = prefs.getBool('is_guest_user') ?? false;
          if (isGuest) {
            print('✅ Guest mode active, navigating to main app');
            Get.offAll(() => Bottombar());
          } else {
            print('❌ No valid login found, navigating to login screen');
            Get.offAll(() => Lunchscreen());
          }
        }
      } catch (e) {
        print('❌ Auto-login check failed: $e');
        Get.offAll(() => Lunchscreen());
      }
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_colorAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.23, 0.37, 0.63, 1.0],
                colors: [
                  // Animated color transition from white to gradient
                  Color.lerp(Color(0xFFFFFFFF), Color(0xFF6B4DFF),
                      _colorAnimation.value)!,
                  Color.lerp(Color(0xFFFFFFFF), Color(0xFF8C75FF),
                      _colorAnimation.value)!,
                  Color.lerp(Color(0xFFFFFFFF), Color(0xFFA08DFF),
                      _colorAnimation.value)!,
                  Color.lerp(Color(0xFFFFFFFF), Color(0xFFC6BBFF),
                      _colorAnimation.value)!,
                  Color.lerp(Color(0xFFFFFFFF), Color(0xFFFCFDFF),
                      _colorAnimation.value)!,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Image.asset(
                      'assets/openapplogo.png',
                      width: width * 0.8,
                      height: height * 0.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
