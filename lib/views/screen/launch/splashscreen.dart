import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/views/widget/custom_animated_column.dart';
import 'package:gesturetalk1/config/routes/auth_checker.dart'; // ✅ import auth checker

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
      Get.off(() => const AuthChecker()); // ✅ navigate to AuthChecker
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kSplashBackgroundColor,
      body: Center(
        child: AnimatedColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
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
