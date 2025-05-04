import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/views/screen/auth/loginscreen.dart';
import 'package:gesturetalk1/views/widget/custom_animated_column.dart'; // your widget path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Get.to(() => const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSplashBackgroundColor, // 💜 your correct color
      body: Center(
        child: const AnimatedColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20, // gives space between image and text
          children: [
            Image(image: AssetImage('assets/images/logo.png'), height: 80),
            Text(
              'Gesture Talk',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kTextWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
