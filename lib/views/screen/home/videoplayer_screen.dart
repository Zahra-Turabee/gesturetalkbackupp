import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:gesturetalk1/constants/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final List<Map<String, String>>? relatedVideos;

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.title,
    this.relatedVideos,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    // Lock to portrait by default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    )..addListener(_onFullScreenChange);
  }

  void _onFullScreenChange() {
    final isFull = _controller.value.isFullScreen;
    if (isFull != _isFullScreen) {
      setState(() {
        _isFullScreen = isFull;
      });

      if (isFull) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onFullScreenChange);
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: ProgressBarColors(
          playedColor: kPrimaryColor,
          handleColor: kPrimaryColorDark,
        ),
      ),
      builder:
          (context, player) => Scaffold(
            appBar:
                _isFullScreen
                    ? null
                    : AppBar(
                      title: Text(
                        widget.title,
                        style: TextStyle(
                          color: isDark ? kTextWhite : kTextPrimaryColor,
                        ),
                      ),
                      backgroundColor: isDark ? kBackgroundDark : kPrimaryColor,
                      iconTheme: IconThemeData(
                        color: isDark ? kTextWhite : Colors.white,
                      ),
                    ),
            body: Column(
              children: [
                // Video player
                player,

                // Related videos list
                if (!_isFullScreen &&
                    widget.relatedVideos != null &&
                    widget.relatedVideos!.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More Videos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? kTextWhite : kTextPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.relatedVideos!.length,
                              itemBuilder: (context, index) {
                                final vid = widget.relatedVideos![index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: ListTile(
                                    leading: Image.network(
                                      YoutubePlayer.getThumbnail(
                                        videoId: vid['videoId']!,
                                      ),
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      vid['title']!,
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? kTextWhite
                                                : kTextPrimaryColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => VideoPlayerScreen(
                                                videoId: vid['videoId']!,
                                                title: vid['title']!,
                                                relatedVideos:
                                                    widget.relatedVideos,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
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
  }
}
