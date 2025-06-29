import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/views/widget/custom_animated_column.dart';
import 'package:gesturetalk1/config/routes/auth_checker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showText = false;

  @override
  void initState() {
    super.initState();

    // Show animated text after 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() => showText = true);
    });

    // Navigate to AuthChecker after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Get.off(() => const AuthChecker());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSplashBackgroundColor,
      body: Center(
        child: AnimatedColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 18,
          children: [
            // Replaced Lottie with GIF image
            Image.asset(
              'assets/images/splash.gif',
              height: 250,
              fit: BoxFit.contain,
            ),

            // Animated app name using Typewriter effect
            if (showText)
              SizedBox(
                height: 40,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Gesture Talk',
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      speed: Duration(milliseconds: 100),
                      cursor: '|',
                    ),
                  ],
                  isRepeatingAnimation: false,
                  totalRepeatCount: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
