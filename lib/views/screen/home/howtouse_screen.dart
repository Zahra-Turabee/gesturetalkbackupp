import 'package:flutter/material.dart';
import 'package:gesturetalk1/constants/app_colors.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStepTile(
            context,
            icon: Icons.touch_app,
            title: 'Talk Feature',
            description:
                'Tap on "Talk" to convert text into gestures for communication.',
          ),
          _buildStepTile(
            context,
            icon: Icons.image_search,
            title: 'Image to Gesture',
            description:
                'Capture any real-world image with text (e.g. "No Parking") to detect and show the matching gesture.',
          ),
          _buildStepTile(
            context,
            icon: Icons.signal_wifi_off,
            title: 'Offline Mode',
            description:
                'Use gesture communication without internet connection in offline situations.',
          ),
          _buildStepTile(
            context,
            icon: Icons.movie,
            title: 'Entertainment',
            description:
                'Watch videos with subtitles, facial expressions, or sign language to enjoy and learn.',
          ),
          _buildStepTile(
            context,
            icon: Icons.emergency_share,
            title: 'SOS System',
            description:
                'Tap SOS in emergencies to notify trusted contacts with location and alert.',
          ),
          _buildStepTile(
            context,
            icon: Icons.flashlight_on,
            title: 'Flashlight Alarm',
            description:
                'Set alarms with blinking flashlight + vibration for deaf/mute users.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: kPrimaryColor,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
