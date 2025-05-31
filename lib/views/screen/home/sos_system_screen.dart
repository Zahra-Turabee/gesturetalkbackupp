// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:torch_light/torch_light.dart';
// import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart'; // ✅ Added for sound

// void main() {
//   runApp(const SosApp());
// }

// class SosApp extends StatelessWidget {
//   const SosApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SOS Feature',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         brightness: Brightness.dark,
//       ),
//       home: const SosScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class SosScreen extends StatefulWidget {
//   const SosScreen({super.key});

//   @override
//   State<SosScreen> createState() => _SosScreenState();
// }

// class _SosScreenState extends State<SosScreen> with WidgetsBindingObserver {
//   Timer? _flashTimer;
//   bool _isFlashing = false;

//   final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ Sound controller

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     _stopFlashing();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _stopFlashing();
//     }
//   }

//   void _sendMessage() {
//     print("Emergency message sent!");
//   }

//   void _sendLocation() {
//     print("Location sent!");
//   }

//   void _fakeCall() {
//     print("Fake call started!");
//   }

//   void _flashAlert() {
//     int countdown = 4;
//     Timer? countdownTimer;
//     bool isCancelled = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//           countdown--;
//           if (countdown == 0) {
//             timer.cancel();
//             Navigator.of(context).pop();
//             if (!isCancelled) {
//               _startFlashing();
//             }
//           } else {
//             (context as Element).markNeedsBuild();
//           }
//         });

//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               backgroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               content: SizedBox(
//                 width: 100,
//                 height: 150,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 80,
//                           height: 80,
//                           child: CircularProgressIndicator(
//                             value: countdown / 4,
//                             strokeWidth: 6,
//                             color: Colors.deepPurpleAccent,
//                           ),
//                         ),
//                         Text(
//                           "$countdown",
//                           style: const TextStyle(
//                             fontSize: 32,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         isCancelled = true;
//                         countdownTimer?.cancel();
//                         Navigator.of(context).pop();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         "Cancel",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _startFlashing() async {
//     bool isOn = false;
//     _isFlashing = true;

//     // ✅ Start playing sound in loop
//     await _audioPlayer.setReleaseMode(ReleaseMode.loop);
//     await _audioPlayer.play(AssetSource('offline_voices/sos.mp3'));

//     _flashTimer = Timer.periodic(const Duration(milliseconds: 400), (
//       timer,
//     ) async {
//       try {
//         if (!_isFlashing) {
//           timer.cancel();
//           await TorchLight.disableTorch();
//           return;
//         }

//         if (!await TorchLight.isTorchAvailable()) {
//           timer.cancel();
//           return;
//         }

//         if (isOn) {
//           await TorchLight.disableTorch();
//         } else {
//           await TorchLight.enableTorch();
//         }

//         isOn = !isOn;
//       } catch (_) {
//         timer.cancel();
//       }
//     });
//   }

//   void _stopFlashing() async {
//     _isFlashing = false;
//     _flashTimer?.cancel();

//     try {
//       await TorchLight.disableTorch();
//     } catch (_) {}

//     // ✅ Stop the sound
//     await _audioPlayer.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double buttonSize = 100.0;

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 156, 36, 146),
//       appBar: AppBar(
//         title: const Text(
//           'SOS Emergency',
//           style: TextStyle(letterSpacing: 1.2),
//         ),
//         backgroundColor: const Color.fromARGB(255, 160, 39, 152),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//         child: GridView.count(
//           crossAxisCount: 2,
//           crossAxisSpacing: 30,
//           mainAxisSpacing: 30,
//           children: [
//             _buildSosButton(
//               gifPath: 'assets/images/message.gif',
//               label: 'Send Message',
//               icon: Icons.message,
//               color: const Color.fromARGB(255, 37, 1, 26),
//               size: buttonSize,
//               onTap: _sendMessage,
//             ),
//             _buildSosButton(
//               gifPath: 'assets/images/location.gif',
//               label: 'Send Location',
//               icon: Icons.location_on,
//               color: const Color.fromARGB(255, 36, 1, 26),
//               size: buttonSize,
//               onTap: _sendLocation,
//             ),
//             _buildSosButton(
//               gifPath: 'assets/images/light.gif',
//               label: 'Flash Alert',
//               icon: Icons.flash_on,
//               color: const Color.fromARGB(255, 35, 1, 26),
//               size: buttonSize,
//               onTap: _flashAlert,
//             ),
//             _buildSosButton(
//               gifPath: 'assets/images/call.gif',
//               label: 'Fake Call',
//               icon: Icons.call,
//               color: const Color.fromARGB(255, 36, 1, 26),
//               size: buttonSize,
//               onTap: _fakeCall,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSosButton({
//     required String gifPath,
//     required String label,
//     required IconData icon,
//     required Color color,
//     required double size,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Flexible(
//             child: Container(
//               width: size + 50,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: color.withOpacity(0.6),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Image.asset(gifPath, fit: BoxFit.contain),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 color: const Color.fromARGB(255, 195, 14, 14).withOpacity(0.9),
//                 size: 20,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white.withOpacity(0.9),
//                   letterSpacing: 0.6,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'settings_sos_screen.dart'; // ✅ Added import

void main() {
  runApp(const SosApp());
}

class SosApp extends StatelessWidget {
  const SosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Feature',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const SosScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with WidgetsBindingObserver {
  Timer? _flashTimer;
  bool _isFlashing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _stopFlashing();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopFlashing();
    }
  }

  void _sendMessage() {
    print("Emergency message sent!");
  }

  void _sendLocation() {
    print("Location sent!");
  }

  void _fakeCall() {
    print("Fake call started!");
  }

  void _flashAlert() {
    int countdown = 4;
    Timer? countdownTimer;
    bool isCancelled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          countdown--;
          if (countdown == 0) {
            timer.cancel();
            Navigator.of(context).pop();
            if (!isCancelled) {
              _startFlashing();
            }
          } else {
            (context as Element).markNeedsBuild();
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SizedBox(
                width: 100,
                height: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: countdown / 4,
                            strokeWidth: 6,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        Text(
                          "$countdown",
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        isCancelled = true;
                        countdownTimer?.cancel();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startFlashing() async {
    bool isOn = false;
    _isFlashing = true;

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('offline_voices/sos.mp3'));

    _flashTimer = Timer.periodic(const Duration(milliseconds: 400), (
      timer,
    ) async {
      try {
        if (!_isFlashing) {
          timer.cancel();
          await TorchLight.disableTorch();
          return;
        }

        if (!await TorchLight.isTorchAvailable()) {
          timer.cancel();
          return;
        }

        if (isOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }

        isOn = !isOn;
      } catch (_) {
        timer.cancel();
      }
    });
  }

  void _stopFlashing() async {
    _isFlashing = false;
    _flashTimer?.cancel();

    try {
      await TorchLight.disableTorch();
    } catch (_) {}

    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = 100.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 156, 36, 146),
      appBar: AppBar(
        title: const Text(
          'SOS Emergency',
          style: TextStyle(letterSpacing: 1.2),
        ),
        backgroundColor: const Color.fromARGB(255, 160, 39, 152),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsSosScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          children: [
            _buildSosButton(
              gifPath: 'assets/images/message.gif',
              label: 'Send Message',
              icon: Icons.message,
              color: Color.fromARGB(255, 248, 245, 247),
              size: buttonSize,
              onTap: _sendMessage,
            ),
            _buildSosButton(
              gifPath: 'assets/images/location.gif',
              label: 'Send Location',
              icon: Icons.location_on,
              color: Color.fromARGB(255, 248, 245, 247),
              size: buttonSize,
              onTap: _sendLocation,
            ),
            _buildSosButton(
              gifPath: 'assets/images/light.gif',
              label: 'Flash Alert',
              icon: Icons.flash_on,
              color: Color.fromARGB(255, 248, 245, 247),
              size: buttonSize,
              onTap: _flashAlert,
            ),
            _buildSosButton(
              gifPath: 'assets/images/call.gif',
              label: 'Fake Call',
              icon: Icons.call,
              color: Color.fromARGB(255, 248, 245, 247),
              size: buttonSize,
              onTap: _fakeCall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton({
    required String gifPath,
    required String label,
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              width: size + 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(gifPath, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color.fromARGB(255, 195, 14, 14).withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
