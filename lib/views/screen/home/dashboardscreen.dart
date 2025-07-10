/*import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/controller/theme_controller.dart';
import 'package:gesturetalk1/controller/profile_controller.dart';
import 'package:gesturetalk1/views/screen/home/profilescreen.dart';

import 'talk_screen.dart';
import 'image_to_gesture_screen.dart';
import 'offline_mode_screen.dart';
import 'entertainment_screen.dart';
import 'sos_system_screen.dart';
import 'flashlight_alarm_screen.dart';
import 'howtouse_screen.dart';

class DashboardScreen extends GetView<ThemeController> {
  DashboardScreen({super.key});

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Talk',
      'imagePath': 'assets/images/talk_icon.png',
      'screen': GestureTalkScreen(),
    },
    {
      'title': 'Image to Gesture',
      'imagePath': 'assets/images/ocr_icon.png',
      'screen': ImageToGestureScreen(),
    },
    {
      'title': 'Offline Mode',
      'imagePath': 'assets/images/offline_icon.png',
      'screen': OfflineModeScreen(),
    },
    {
      'title': 'Entertainment',
      'imagePath': 'assets/images/entertainment_icon.png',
      'screen': EntertainmentScreen(),
    },
    {
      'title': 'SOS System',
      'imagePath': 'assets/images/sos_icon.png',
      'screen': SosScreen(),
    },
    {
      'title': 'Flashlight Alarm',
      'imagePath': 'assets/images/alarm_icon.png',
      'screen': FlashlightAlarmScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? kPrimaryColor.withOpacity(0.8) : kPrimaryColor,
              ),
              child: GetX<ProfileController>(
                builder: (controller) {
                  final name = controller.name.value;
                  final imagePath = controller.imagePath.value;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            imagePath != null
                                ? FileImage(File(imagePath))
                                : null,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child:
                            imagePath == null
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome, $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            Obx(() {
              final isDark = controller.isDarkMode.value;
              return ListTile(
                leading: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                title: Text(
                  isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => controller.toggleTheme(),
                  activeColor: kPrimaryColor,
                ),
                onTap: () => controller.toggleTheme(),
              );
            }),
            ListTile(
              leading: const Icon(Icons.ondemand_video),
              title: const Text('How to Use'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowToUseScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Get.defaultDialog(
                  title: "About App",
                  middleText:
                      "Gesture Talk\nAn accessibility app for deaf and mute users.",
                  textConfirm: "OK",
                  confirmTextColor: Colors.white,
                  buttonColor: kPrimaryColor,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Gesture Talk',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: DashboardBody(cards: _cards),
    );
  }
}

class DashboardBody extends StatefulWidget {
  final List<Map<String, dynamic>> cards;

  const DashboardBody({super.key, required this.cards});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  final List<String> _slideImages = [
    'assets/images/dh1.png',
    'assets/images/dh2.png',
    'assets/images/dh3.png',
    'assets/images/dh4.png',
    'assets/images/dh5.png',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _slideImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Image.asset(
              _slideImages[_currentIndex],
              key: ValueKey<String>(_slideImages[_currentIndex]),
              width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: widget.cards.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final card = widget.cards[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => card['screen']),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimaryColor.withOpacity(0.4),
                                kPrimaryColor.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 67,
                                  height: 67,
                                  child: Image.asset(
                                    card['imagePath'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  card['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black45,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                               ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}*/

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/controller/theme_controller.dart';
import 'package:gesturetalk1/controller/profile_controller.dart';
import 'package:gesturetalk1/views/screen/home/profilescreen.dart';

import 'talk_screen.dart';
import 'image_to_gesture_screen.dart';
import 'offline_mode_screen.dart';
import 'entertainment_screen.dart';
import 'sos_system_screen.dart';
import 'flashlight_alarm_screen.dart';
import 'howtouse_screen.dart';

class DashboardScreen extends GetView<ThemeController> {
  DashboardScreen({super.key});

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Talk',
      'imagePath': 'assets/images/talk_icon.png',
      'screen': GestureTalkScreen(),
    },
    {
      'title': 'Image to Gesture',
      'imagePath': 'assets/images/ocr_icon.png',
      'screen': ImageToGestureScreen(),
    },
    {
      'title': 'Offline Mode',
      'imagePath': 'assets/images/offline_icon.png',
      'screen': OfflineModeScreen(),
    },
    {
      'title': 'Entertainment',
      'imagePath': 'assets/images/entertainment_icon.png',
      'screen': EntertainmentScreen(),
    },
    {
      'title': 'SOS System',
      'imagePath': 'assets/images/sos_icon.png',
      'screen': SosScreen(),
    },
    {
      'title': 'Flashlight Alarm',
      'imagePath': 'assets/images/alarm_icon.png',
      'screen': FlashlightAlarmScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? kPrimaryColor.withOpacity(0.8) : kPrimaryColor,
              ),
              child: GetX<ProfileController>(
                builder: (controller) {
                  final name = controller.name.value;
                  final imagePath = controller.imagePath.value;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            imagePath != null
                                ? FileImage(File(imagePath))
                                : null,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child:
                            imagePath == null
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome, $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            Obx(() {
              final isDark = controller.isDarkMode.value;
              return ListTile(
                leading: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                title: Text(
                  isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => controller.toggleTheme(),
                  activeColor: kPrimaryColor,
                ),
                onTap: () => controller.toggleTheme(),
              );
            }),
            ListTile(
              leading: const Icon(Icons.ondemand_video),
              title: const Text('How to Use'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowToUseScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Get.defaultDialog(
                  title: "About App",
                  middleText:
                      "Gesture Talk\nAn accessibility app for deaf and mute users.",
                  textConfirm: "OK",
                  confirmTextColor: Colors.white,
                  buttonColor: kPrimaryColor,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Gesture Talk',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: DashboardBody(cards: _cards),
    );
  }
}

class DashboardBody extends StatefulWidget {
  final List<Map<String, dynamic>> cards;

  const DashboardBody({super.key, required this.cards});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  final List<String> _slideImages = [
    'assets/images/dh1.png',
    'assets/images/dh2.png',
    'assets/images/dh3.png',
    'assets/images/dh4.png',
    'assets/images/dh5.png',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _slideImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.asset(
                  _slideImages[_currentIndex],
                  key: ValueKey<String>(_slideImages[_currentIndex]),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                itemCount: widget.cards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final card = widget.cards[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => card['screen']),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.grey[850]
                                : kPrimaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.grey[700]!
                                  : kPrimaryColor.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                card['imagePath'],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            card['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
