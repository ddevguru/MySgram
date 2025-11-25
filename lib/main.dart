import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysgram/View/Screens/Activesearchpage.dart';
import 'package:mysgram/View/Screens/Bottombar.dart';
import 'package:mysgram/View/Screens/Camera/Camerapage.dart';
import 'package:mysgram/View/Screens/Camera/Camerasettings.dart';
import 'package:mysgram/View/Screens/Explore.dart';
import 'package:mysgram/View/Screens/Lunchscreen.dart';
import 'package:mysgram/View/Screens/Openappmain.dart';
import 'package:mysgram/View/Screens/Openappsplashscreen.dart';
import 'package:mysgram/View/Screens/Personaldatapage.dart';
import 'package:mysgram/View/Screens/Profilepage.dart';
import 'package:mysgram/View/Screens/Settings.dart';
import 'package:mysgram/View/Screens/Signinpage.dart';
import 'package:mysgram/View/Screens/Signuppage.dart';
import 'package:mysgram/View/Screens/Storiespostpage.dart';
import 'package:mysgram/View/Screens/Yourcativity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Flutter Demo',
      home: Openappsplashscreen(),
    );
  }
}
