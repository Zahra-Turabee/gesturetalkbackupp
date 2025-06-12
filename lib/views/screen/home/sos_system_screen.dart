import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'settings_sos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialize karo
  await Hive.initFlutter();

  // Boxes open karo
  await Hive.openBox('emergency_contacts');
  await Hive.openBox('settings');
  print("opening Hive boxes:");

  runApp(SosApp());
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
    _audioPlayer.dispose();
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

  void _sendMessage() async {
    try {
      // Check if Hive boxes are available
      if (!Hive.isBoxOpen('emergency_contacts') ||
          !Hive.isBoxOpen('settings')) {
        _showConfirmationDialog(
          "Database not available. Please restart the app.",
        );
        return;
      }

      // Hive se contacts get karo
      final contactsBox = Hive.box('emergency_contacts');
      final settingsBox = Hive.box('settings');

      // Get contacts data from the proper format (same as settings screen)
      List<dynamic>? contactsData = contactsBox.get('contacts');
      List<String> phoneNumbers = [];

      if (contactsData != null && contactsData.isNotEmpty) {
        // Extract phone numbers from the contact objects
        for (var contact in contactsData) {
          if (contact is Map<String, dynamic>) {
            List<dynamic> phones = contact['phones'] ?? [];
            for (var phone in phones) {
              if (phone is Map<String, dynamic> && phone['value'] != null) {
                phoneNumbers.add(phone['value'].toString());
              }
            }
          }
        }
      }

      // If no contacts found, use default ones
      if (phoneNumbers.isEmpty) {
        phoneNumbers = ['112', '15'];
      }

      // Emergency message get karo
      String emergencyMessage = settingsBox.get(
        'emergency_message',
        defaultValue:
            "🚨 EMERGENCY! I need immediate help. Please contact me or send assistance to my location.",
      );

      print("Phone numbers found: $phoneNumbers"); // Debug
      print("Message: $emergencyMessage"); // Debug

      // Sab contacts ko comma se join kar do
      String allContacts = phoneNumbers.join(',');

      // Single SMS app open karo with predefined message
      String smsUrl =
          'sms:$allContacts?body=${Uri.encodeComponent(emergencyMessage)}';

      print("Opening SMS app with: $smsUrl"); // Debug

      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        await launchUrl(
          Uri.parse(smsUrl),
          mode: LaunchMode.externalApplication,
        );
        print("SMS app opened successfully"); // Debug
      } else {
        _showConfirmationDialog(
          "Could not open SMS app. Please check your messaging app.",
        );
      }
    } catch (e) {
      print("Error in _sendMessage: $e"); // Debug
      _showConfirmationDialog("Error opening SMS app: ${e.toString()}");
    }
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  "SOS Alert",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _fakeCall() {
    int countdown = 4;
    Timer? countdownTimer;
    bool isCancelled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            countdownTimer = Timer.periodic(const Duration(seconds: 1), (
              timer,
            ) {
              countdown--;
              if (countdown == 0) {
                timer.cancel();
                Navigator.of(dialogContext).pop();
                if (!isCancelled) {
                  _makeCall();
                }
              } else {
                if (mounted) {
                  setState(() {});
                }
              }
            });

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
                            color: const Color.fromARGB(255, 171, 65, 141),
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
                        Navigator.of(dialogContext).pop();
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

  List<String> _tempPhoneList = [];
  int _currentCallIndex = 0;

  void _makeCall() async {
    try {
      if (!Hive.isBoxOpen('emergency_contacts')) {
        print("Database not available for call");
        return;
      }

      // Load and prepare the phone numbers if temp list is empty
      if (_tempPhoneList.isEmpty) {
        final contactsBox = Hive.box('emergency_contacts');
        List<dynamic>? contactsData = contactsBox.get('contacts');

        if (contactsData != null && contactsData.isNotEmpty) {
          for (var contact in contactsData) {
            if (contact is Map<String, dynamic>) {
              List<dynamic> phones = contact['phones'] ?? [];
              for (var phone in phones) {
                if (phone is Map<String, dynamic> && phone['value'] != null) {
                  String cleaned = phone['value'].toString().replaceAll(
                    RegExp(r'[^\d+]'),
                    '',
                  );
                  _tempPhoneList.add(cleaned);
                }
              }
            }
          }
        }

        if (_tempPhoneList.isEmpty) {
          _tempPhoneList = ['15']; // Fallback numbers
        }

        _currentCallIndex = 0; // Reset index
      }

      // Wrap index if it goes beyond length
      if (_currentCallIndex >= _tempPhoneList.length) {
        _currentCallIndex = 0;
      }

      String numberToCall = _tempPhoneList[_currentCallIndex];
      print("Calling: $numberToCall");
      bool? result = await FlutterPhoneDirectCaller.callNumber(numberToCall);
      _currentCallIndex++;

      // Optional: If call fails, you can retry the next number by calling _makeCall() again
      if (result != true) {
        print("Call failed. Trying next number...");
        _makeCall();
      }
    } catch (e) {
      print("Error in _makeCall: $e");
      try {
        final fallback = 'tel:+923001234567';
        if (await canLaunchUrl(Uri.parse(fallback))) {
          await launchUrl(Uri.parse(fallback));
        }
      } catch (err) {
        print("Fallback also failed: $err");
      }
    }
  }

  void _flashAlert() {
    int countdown = 4;
    Timer? countdownTimer;
    bool isCancelled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            countdownTimer = Timer.periodic(const Duration(seconds: 1), (
              timer,
            ) {
              countdown--;
              if (countdown == 0) {
                timer.cancel();
                Navigator.of(dialogContext).pop();
                if (!isCancelled) {
                  _startFlashing();
                }
              } else {
                if (mounted) {
                  setState(() {});
                }
              }
            });

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
                            color: const Color.fromARGB(255, 83, 30, 74),
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
                        Navigator.of(dialogContext).pop();
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

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('offline_voices/sos.mp3'));
    } catch (e) {
      print("Error playing audio: $e");
    }

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
      } catch (e) {
        print("Error with torch: $e");
        timer.cancel();
      }
    });
  }

  void _stopFlashing() async {
    _isFlashing = false;
    _flashTimer?.cancel();

    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print("Error disabling torch: $e");
    }

    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 100.0;

    return WillPopScope(
      onWillPop: () async {
        // Stop flashing when back button is pressed
        if (_isFlashing) {
          _stopFlashing();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 156, 36, 146),
        appBar: AppBar(
          title: const Text(
            'SOS Emergency',
            style: TextStyle(letterSpacing: 1.2),
          ),
          backgroundColor: const Color.fromARGB(255, 160, 39, 152),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Stop flashing when back button is pressed
              if (_isFlashing) {
                _stopFlashing();
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Settings_Sos_Screen(),
                  ),
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
                gifPath: 'assets/images/light.gif',
                label: 'Flash Alert',
                icon: Icons.flash_on,
                color: const Color.fromARGB(255, 248, 245, 247),
                size: buttonSize,
                onTap: _flashAlert,
              ),
              _buildSosButton(
                gifPath: 'assets/images/call.gif',
                label: 'Call',
                icon: Icons.call,
                color: const Color.fromARGB(255, 248, 245, 247),
                size: buttonSize,
                onTap: _fakeCall,
              ),
            ],
          ),
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
                color: const Color.fromARGB(255, 231, 15, 15).withOpacity(0.9),
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
