import 'package:flutter/material.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:video_player/video_player.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  late VideoPlayerController _talkController;
  late VideoPlayerController _imageToGestureController;
  late VideoPlayerController _offlineModeController;
  late VideoPlayerController _entertainmentController;
  late VideoPlayerController _sosController;
  late VideoPlayerController _flashlightController;

  @override
  void initState() {
    super.initState();

    _talkController = VideoPlayerController.asset('assets/videos/talk.mp4')
      ..initialize().then((_) => setState(() {}));

    _imageToGestureController = VideoPlayerController.asset(
      'assets/videos/imagetogesture.mp4',
    )..initialize().then((_) => setState(() {}));

    _offlineModeController = VideoPlayerController.asset(
      'assets/videos/offlinemode.mp4',
    )..initialize().then((_) => setState(() {}));

    _entertainmentController = VideoPlayerController.asset(
      'assets/videos/entertainment.mp4',
    )..initialize().then((_) => setState(() {}));

    _sosController = VideoPlayerController.asset('assets/videos/sossystem.mp4')
      ..initialize().then((_) => setState(() {}));

    _flashlightController = VideoPlayerController.asset(
      'assets/videos/flashlightalarm.mp4',
    )..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _talkController.dispose();
    _imageToGestureController.dispose();
    _offlineModeController.dispose();
    _entertainmentController.dispose();
    _sosController.dispose();
    _flashlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use'),
        backgroundColor: isDark ? Colors.black : kPrimaryColor,
        foregroundColor: Colors.white,
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
            child: _buildVideoPlayer(_talkController),
          ),
          _buildStepTile(
            context,
            icon: Icons.image_search,
            title: 'Image to Gesture',
            description:
                'Capture any real-world image with text to detect and show the matching gesture.',
            child: _buildVideoPlayer(_imageToGestureController),
          ),
          _buildStepTile(
            context,
            icon: Icons.signal_wifi_off,
            title: 'Offline Mode',
            description:
                'Use gesture communication without internet connection.',
            child: _buildVideoPlayer(_offlineModeController),
          ),
          _buildStepTile(
            context,
            icon: Icons.movie,
            title: 'Entertainment',
            description:
                'Watch videos with subtitles, facial expressions, or sign language.',
            child: _buildVideoPlayer(_entertainmentController),
          ),
          _buildStepTile(
            context,
            icon: Icons.emergency_share,
            title: 'SOS System',
            description:
                'Tap SOS to notify trusted contacts with location and alert.',
            child: _buildVideoPlayer(_sosController),
          ),
          _buildStepTile(
            context,
            icon: Icons.flashlight_on,
            title: 'Flashlight Alarm',
            description:
                'Set alarms with blinking flashlight + vibration for deaf/mute users.',
            child: _buildVideoPlayer(_flashlightController),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController controller) {
    if (!controller.value.isInitialized) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VideoPlayer(controller),
            ),
            VideoProgressIndicator(controller, allowScrubbing: true),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  });
                },
                child: Center(
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 56,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    Widget? child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryColor,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          if (child != null) child,
        ],
      ),
    );
  }
}
