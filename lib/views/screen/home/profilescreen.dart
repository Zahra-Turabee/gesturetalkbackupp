import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gesturetalk1/controller/theme_controller.dart';
import 'package:gesturetalk1/constants/app_colors.dart'; // For AppThemeColors

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final String userEmail = user?.email ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout user and navigate to login screen
              await Supabase.instance.client.auth.signOut();
              Get.offAllNamed(
                '/login',
              ); // Clear all previous screens and go to login
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Email: $userEmail',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value:
                        _themeController
                            .isDarkMode
                            .value, // Directly using the isDarkMode observable
                    onChanged: (value) => _themeController.toggleTheme(),
                    activeColor: kPrimaryColor,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
