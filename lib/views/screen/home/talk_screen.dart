// 📦 Required imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class TalkScreen extends StatefulWidget {
  const TalkScreen({super.key});

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(model: "assets/models/model.tflite");
  }

  Future<void> pickImageAndPredict() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      var recognitions = await Tflite.runModelOnImage(
        path: picked.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 1,
        threshold: 0.5,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        String detectedWord = recognitions[0]['label'];
        setState(() {
          messages.add({'type': 'output', 'text': detectedWord});
        });
      } else {
        showError("Gesture not recognized.");
      }
    }
  }

  void fetchVideo(String label) async {
    try {
      final response =
          await supabase
              .from('gestureimages')
              .select()
              .eq('label', label.toLowerCase())
              .maybeSingle();

      setState(() {
        messages.add({'type': 'input', 'text': label});
      });

      final videoUrl =
          response != null ? response['image_url'] as String? : null;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        setState(() {
          messages.add({'type': 'video', 'url': videoUrl});
        });
      } else {
        setState(() {
          messages.add({
            'type': 'notfound',
            'text': "⚠️ Gesture for '$label' not found",
          });
        });
      }
    } catch (e) {
      showError("Error fetching gesture: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Gesture Talk"),
        backgroundColor: const Color.fromARGB(255, 134, 58, 169),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                if (msg['type'] == 'input') {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 181, 57, 181),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else if (msg['type'] == 'output') {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                } else if (msg['type'] == 'video') {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 250,
                      height: 200,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: VideoWidget(videoUrl: msg['url']!),
                    ),
                  );
                } else if (msg['type'] == 'notfound') {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a word...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 153, 56, 183),
                  ),
                  onPressed: () {
                    final label = _controller.text.trim();
                    if (label.isNotEmpty) {
                      fetchVideo(label);
                      _controller.clear();
                    }
                  },
                  child: const Text(
                    "Send",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: pickImageAndPredict,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Gesture"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
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

class VideoWidget extends StatefulWidget {
  final String videoUrl;
  const VideoWidget({super.key, required this.videoUrl});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final encodedUrl = Uri.encodeFull(widget.videoUrl);
    _controller = VideoPlayerController.network(encodedUrl)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              _controller.setLooping(true);
              _controller.play();
            }
          })
          .catchError((e) {
            debugPrint("Video initialization failed: $e");
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
        : const Center(child: CircularProgressIndicator());
  }
}
