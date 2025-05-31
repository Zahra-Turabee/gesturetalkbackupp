import 'package:flutter/material.dart';
import 'package:gesturetalk1/views/screen/home/profilescreen.dart';
import 'talk_screen.dart';
import 'image_to_gesture_screen.dart';
import 'offline_mode_screen.dart';
import 'entertainment_screen.dart';
import 'sos_system_screen.dart';
import 'flashlight_alarm_screen.dart';
import 'package:gesturetalk1/constants/app_colors.dart'; // Import custom color file

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

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
    {'title': 'SOS System', 'icon': Icons.emergency_share, 'screen': SosApp()},
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
      appBar: AppBar(
        title: Text('Gesture Talk', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white), // Always white
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Banner image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.asset(
              'assets/images/g1.jpg',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          // Grid view of feature cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: _cards.length,
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
                          decoration: BoxDecoration(
                            color: kPrimaryColor, // Background purple
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            card['icon'],
                            size: 36,
                            color: Colors.white, // ICON FIX: white icon
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
          ),
        ],
      ),
    );
  }
}
