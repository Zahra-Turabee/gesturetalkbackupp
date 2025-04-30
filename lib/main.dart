import 'package:flutter/material.dart';
//import 'package:gesturetalk1/pages/dashboardscreen.dart';
import 'package:gesturetalk1/pages/splashscreen.dart';
//import 'package:gesturetalk1/pages/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gesturetalk1/pages/loginscreen.dart'; // Import the login screen

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmaG9yem9yY3RzamdycWVleGt0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2OTE4NDcsImV4cCI6MjA2MTI2Nzg0N30.8Z2yiVATZQG4lfLJW17VhUZXepGSvmJD3f4VpVeg0hM",
    url: "https://ffhorzorctsjgrqeexkt.supabase.co",
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Default theme is light

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load the saved theme from SharedPreferences
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default to light
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GestureTalk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode, // Use the theme mode (light or dark)
      home: SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(), // Add the login route here
      },
    );
  }
}
