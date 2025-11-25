import 'package:flutter/material.dart';

class Openappmain extends StatelessWidget {
  const Openappmain({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.23, 0.37, 0.63, 1.0],
            colors: [
              Color(0xFF6B4DFF), // Top color
              Color(0xFF8C75FF), // 23% stop
              Color(0xFFA08DFF), // 37% stop
              Color(0xFFC6BBFF), // 63% stop
              Color(0xFFFCFDFF), // Bottom color (almost white)
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/openapplogo.png',
                width: width * 0.8,
                height: height * 0.6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
