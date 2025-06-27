// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:gesturetalk1/constants/app_colors.dart';
// import 'package:gesturetalk1/controller/theme_controller.dart';
// import 'package:gesturetalk1/views/screen/home/profilescreen.dart';

// import 'talk_screen.dart';
// import 'image_to_gesture_screen.dart';
// import 'offline_mode_screen.dart';
// import 'entertainment_screen.dart';
// import 'sos_system_screen.dart';
// import 'flashlight_alarm_screen.dart';
// import 'howtouse_screen.dart';

// class DashboardScreen extends GetView<ThemeController> {
//   DashboardScreen({super.key});

//   final List<Map<String, dynamic>> _cards = [
//     {
//       'title': 'Talk',
//       'imagePath': 'assets/images/talk_icon.png',
//       'screen': TalkScreen(),
//     },
//     {
//       'title': 'Image to Gesture',
//       'imagePath': 'assets/images/ocr_icon.png',
//       'screen': ImageToGestureScreen(),
//     },
//     {
//       'title': 'Offline Mode',
//       'imagePath': 'assets/images/offline_icon.png',
//       'screen': OfflineModeScreen(),
//     },
//     {
//       'title': 'Entertainment',
//       'imagePath': 'assets/images/entertainment_icon.png',
//       'screen': EntertainmentScreen(),
//     },
//     {
//       'title': 'SOS System',
//       'imagePath': 'assets/images/sos_icon.png',
//       'screen': SosScreen(),
//     },
//     {
//       'title': 'Flashlight Alarm',
//       'imagePath': 'assets/images/alarm_icon.png',
//       'screen': FlashlightAlarmScreen(),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       drawer: Drawer(
//         backgroundColor: isDark ? Colors.grey[900] : Colors.white,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: isDark ? kPrimaryColor.withOpacity(0.8) : kPrimaryColor,
//               ),
//               child: FutureBuilder(
//                 future: Future.value(Supabase.instance.client.auth.currentUser),
//                 builder: (context, snapshot) {
//                   final user = snapshot.data;
//                   final metadata = user?.userMetadata ?? {};
//                   final name = metadata['name'] ?? 'User';

//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.account_circle,
//                         size: 60,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Welcome, $name',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_box),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                 );
//               },
//             ),
//             Obx(() {
//               final isDark = controller.isDarkMode.value;
//               return ListTile(
//                 leading: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
//                 title: Text(
//                   isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
//                 ),
//                 trailing: Switch(
//                   value: isDark,
//                   onChanged: (_) => controller.toggleTheme(),
//                   activeColor: kPrimaryColor,
//                 ),
//                 onTap: () => controller.toggleTheme(),
//               );
//             }),
//             ListTile(
//               leading: const Icon(Icons.ondemand_video),
//               title: const Text('How to Use'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const HowToUseScreen()),
//                 );
//               },
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.info_outline),
//               title: const Text('About'),
//               onTap: () {
//                 Get.defaultDialog(
//                   title: "About App",
//                   middleText:
//                       "Gesture Talk\nAn accessibility app for deaf and mute users.",
//                   textConfirm: "OK",
//                   confirmTextColor: Colors.white,
//                   buttonColor: kPrimaryColor,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         title: const Text(
//           'Gesture Talk',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         centerTitle: true,
//         elevation: 4,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ProfileScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: DashboardBody(cards: _cards),
//     );
//   }
// }

// class DashboardBody extends StatefulWidget {
//   final List<Map<String, dynamic>> cards;

//   const DashboardBody({super.key, required this.cards});

//   @override
//   State<DashboardBody> createState() => _DashboardBodyState();
// }

// class _DashboardBodyState extends State<DashboardBody> {
//   final List<String> _slideImages = [
//     'assets/images/dh1.png',
//     'assets/images/dh2.png',
//     'assets/images/dh3.png',
//     'assets/images/dh4.png',
//     'assets/images/dh5.png',
//   ];

//   int _currentIndex = 0;
//   bool _isPlaying = true;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startSlideshow();
//   }

//   void _startSlideshow() {
//     _timer?.cancel();
//     if (_isPlaying) {
//       _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//         setState(() {
//           _currentIndex = (_currentIndex + 1) % _slideImages.length;
//         });
//       });
//     }
//   }

//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//       _startSlideshow();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(seconds: 1),
//                 child: Image.asset(
//                   _slideImages[_currentIndex],
//                   key: ValueKey<String>(_slideImages[_currentIndex]),
//                   width: double.infinity,
//                   height: 220,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Positioned(
//                 bottom: 10,
//                 right: 10,
//                 child: CircleAvatar(
//                   radius: 14,
//                   backgroundColor: Colors.black.withOpacity(0.5),
//                   child: IconButton(
//                     iconSize: 10,
//                     icon: Icon(
//                       _isPlaying ? Icons.pause : Icons.play_arrow,
//                       color: Colors.white,
//                     ),
//                     onPressed: _togglePlayPause,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: GridView.builder(
//               itemCount: widget.cards.length,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 24,
//                 crossAxisSpacing: 16,
//                 childAspectRatio: 1.0,
//               ),
//               itemBuilder: (context, index) {
//                 final card = widget.cards[index];

//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => card['screen']),
//                     );
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 kPrimaryColor.withOpacity(0.4),
//                                 kPrimaryColor.withOpacity(0.9),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: kPrimaryColor.withOpacity(0.6),
//                                 blurRadius: 15,
//                                 spreadRadius: 1,
//                                 offset: const Offset(0, 6),
//                               ),
//                             ],
//                           ),
//                         ),
//                         BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                           child: Container(
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.05),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.1),
//                               ),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 SizedBox(
//                                   width: 67,
//                                   height: 67,
//                                   child: Image.asset(
//                                     card['imagePath'],
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 14),
//                                 Text(
//                                   card['title'],
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     shadows: [
//                                       Shadow(
//                                         blurRadius: 2,
//                                         color: Colors.black45,
//                                         offset: Offset(1, 1),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:ui';
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

class DashboardScreen extends GetView<ThemeController> {
  DashboardScreen({super.key});

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Talk',
      'imagePath': 'assets/images/talk_icon.png',
      'screen': TalkScreen(),
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
  bool _isPlaying = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer?.cancel();
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _slideImages.length;
        });
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _startSlideshow();
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
          Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: Image.asset(
                  _slideImages[_currentIndex],
                  key: ValueKey<String>(_slideImages[_currentIndex]),
                  width: double.infinity,
                  height: 200, // <- chhoti aur fixed height
                  fit: BoxFit.contain, // <- contain for uniform size
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    iconSize: 10,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
            ],
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
}
