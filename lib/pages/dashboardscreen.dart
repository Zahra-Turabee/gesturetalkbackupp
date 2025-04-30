import 'package:flutter/material.dart';
import 'package:gesturetalk1/pages/profilescreen.dart';
import 'talk_screen.dart';
import 'image_to_gesture_screen.dart';
import 'offline_mode_screen.dart';
import 'entertainment_screen.dart';
import 'sos_system_screen.dart';
import 'flashlight_alarm_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        'screen': const OfflineModeScreen(),
      },
      {
        'title': 'Entertainment',
        'icon': Icons.movie,
        'screen': const EntertainmentScreen(),
      },
      {
        'title': 'SOS System',
        'icon': Icons.emergency_share,
        'screen': const SOSSystemScreen(),
      },
      {
        'title': 'Flashlight Alarm',
        'icon': Icons.flashlight_on,
        'screen': const FlashlightAlarmScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Gesture Talk',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 142, 38, 160),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white, // Profile icon color set to white
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add spacing between AppBar and image
          const SizedBox(height: 20),

          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.asset(
              'lib/assets/images/g1.jpg', // 👈 YOUR IMAGE IS HERE (Check path)
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Added space below the image to avoid overlap with grid
          const SizedBox(height: 30),

          // Grid Menu (screens)
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
                        // Circle with icon
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 142, 38, 160),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            card['icon'],
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Text below the icon
                        Text(
                          card['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
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
