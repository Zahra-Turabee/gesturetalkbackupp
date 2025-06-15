import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:gesturetalk1/controller/theme_controller.dart';
import 'package:gesturetalk1/views/screen/home/profilescreen.dart';
import 'talk_screen.dart';
import 'image_to_gesture_screen.dart';
import 'offline_mode_screen.dart';
import 'entertainment_screen.dart';
import 'sos_system_screen.dart';
import 'flashlight_alarm_screen.dart';
import 'howtouse_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ThemeController themeController = Get.find();

  final List<Map<String, dynamic>> _cards = [
    {'title': 'Talk', 'icon': Icons.chat, 'screen': const TalkScreen()},
    {
      'title': 'Image to Gesture',
      'icon': Icons.image_search,
      'screen': const ImageToGestureScreen(),
    },
    {
      'title': 'Offline Mode',
      'icon': Icons.signal_wifi_off,
      'screen': OfflineModeScreen(),
    },
    {
      'title': 'Entertainment',
      'icon': Icons.movie,
      'screen': const EntertainmentScreen(),
    },
    {
      'title': 'SOS System',
      'icon': Icons.emergency_share,
      'screen': const SosScreen(),
    },
    {
      'title': 'Flashlight Alarm',
      'icon': Icons.flashlight_on,
      'screen': const FlashlightAlarmScreen(),
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
              child: FutureBuilder(
                future: Future.value(Supabase.instance.client.auth.currentUser),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final metadata = user?.userMetadata ?? {};
                  final name = metadata['name'] ?? 'User';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome, $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
              final isDark = themeController.isDarkMode.value;
              return ListTile(
                leading: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
                title: Text(
                  isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => themeController.toggleTheme(),
                  activeColor: kPrimaryColor,
                ),
                onTap: () => themeController.toggleTheme(),
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
        title: Text('Gesture Talk', style: theme.appBarTheme.titleTextStyle),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/g1.jpg',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: _cards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => card['screen']),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            card['icon'],
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          card['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
