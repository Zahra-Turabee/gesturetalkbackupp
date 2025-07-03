// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'dart:io';

// import 'package:gesturetalk1/constants/app_colors.dart';

// class ImageToGestureScreen extends StatefulWidget {
//   const ImageToGestureScreen({Key? key}) : super(key: key);

//   @override
//   State<ImageToGestureScreen> createState() => _ImageToGestureScreenState();
// }

// class _ImageToGestureScreenState extends State<ImageToGestureScreen> {
//   final ImagePicker _picker = ImagePicker();
//   final ScrollController _scrollController =
//       ScrollController(); // ✅ Add scroll controller

//   List<Map<String, dynamic>> chatList = [];

//   Future<void> pickImageFromCamera() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       File imageFile = File(pickedFile.path);

//       // Add image bubble on right and show loader
//       setState(() {
//         chatList.add({"type": "image", "data": imageFile});
//         chatList.add({"type": "loading"});
//       });
//       _scrollToBottom(); // ✅ Scroll after adding image + loader

//       // Start text recognition
//       final inputImage = InputImage.fromFile(imageFile);
//       final textRecognizer = TextRecognizer(
//         script: TextRecognitionScript.latin,
//       );
//       final RecognizedText recognizedText = await textRecognizer.processImage(
//         inputImage,
//       );
//       await textRecognizer.close();

//       // Combine extracted text
//       String extractedText = recognizedText.text.trim();
//       if (extractedText.isEmpty) {
//         extractedText = "No text found!";
//       }

//       // Replace loader with extracted text on left
//       setState(() {
//         int loadingIndex = chatList.indexWhere(
//           (item) => item["type"] == "loading",
//         );
//         if (loadingIndex != -1) {
//           chatList[loadingIndex] = {"type": "text", "data": extractedText};
//         }
//       });
//       _scrollToBottom(); // ✅ Scroll after showing text
//     }
//   }

//   // ✅ Scroll to bottom method
//   void _scrollToBottom() {
//     Future.delayed(Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget buildChatBubble(Map<String, dynamic> item) {
//     if (item["type"] == "image") {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.file(
//               item["data"],
//               height: 120,
//               width: 120,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ],
//       );
//     } else if (item["type"] == "loading") {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: const [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 10),
//             child: CircularProgressIndicator(),
//           ),
//         ],
//       );
//     } else {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.symmetric(vertical: 4),
//               decoration: BoxDecoration(
//                 color: kPrimaryColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 item["data"],
//                 style: const TextStyle(color: Colors.white, fontSize: 15),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? kBackgroundDark : kBackgroundColor,
//       appBar: AppBar(
//         title: const Text('Image to Gesture'),
//         backgroundColor: kPrimaryColor,
//         foregroundColor: kTextWhite,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
//             child: ListView.builder(
//               controller: _scrollController, // ✅ Attach controller
//               itemCount: chatList.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: buildChatBubble(chatList[index]),
//                 );
//               },
//             ),
//           ),

//           // Camera Button
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: pickImageFromCamera,
//               backgroundColor: kButtonPurple,
//               shape: const CircleBorder(),
//               child: const Icon(Icons.camera_alt, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'package:gesturetalk1/constants/app_colors.dart';

class ImageToGestureScreen extends StatefulWidget {
  const ImageToGestureScreen({Key? key}) : super(key: key);

  @override
  State<ImageToGestureScreen> createState() => _ImageToGestureScreenState();
}

class _ImageToGestureScreenState extends State<ImageToGestureScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> chatList = [];

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Add image bubble and loader
      setState(() {
        chatList.add({"type": "image", "data": imageFile});
        chatList.add({"type": "loading"});
      });
      _scrollToBottom();

      // Start text recognition
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      // Combine extracted text
      String extractedText = recognizedText.text.trim();
      if (extractedText.isEmpty) {
        // No text found
        setState(() {
          chatList.removeWhere((item) => item["type"] == "loading");
          chatList.add({
            'type': 'notfound',
            'data': "⚠️ No text found in image",
          });
        });
        _scrollToBottom();
        return;
      }

      // Remove loader before fetching video
      setState(() {
        chatList.removeWhere((item) => item["type"] == "loading");
      });

      // Fetch video
      await fetchSingleVideo(extractedText);
    }
  }

  Future<void> fetchSingleVideo(String label) async {
    try {
      final response = await supabase
          .from('i2_gesture_videos')
          .select()
          .ilike('label', label.trim())
          .maybeSingle();

      final videoUrl =
          response != null ? response['image_url'] as String? : null;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        setState(() {
          chatList.add({'type': 'video', 'url': videoUrl, 'label': label});
        });
        _scrollToBottom();
      } else {
        setState(() {
          chatList.add({'type': 'notfound', 'data': "⚠️ Gesture not found"});
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        chatList.removeWhere((item) => item["type"] == "loading");
        chatList.add({'type': 'notfound', 'data': "⚠️ Error loading gesture"});
      });
      _scrollToBottom();
      showError("Error fetching gesture: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildChatBubble(Map<String, dynamic> item) {
    if (item["type"] == "image") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              item["data"],
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    } else if (item["type"] == "loading") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CircularProgressIndicator(),
          ),
        ],
      );
    } else if (item["type"] == "video") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 250,
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: VideoWidget(videoUrl: item['url']!),
          ),
        ],
      );
    } else if (item["type"] == "notfound") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item["data"],
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item["data"],
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBackgroundDark : kBackgroundColor,
      appBar: AppBar(
        title: const Text('Image to Gesture'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextWhite,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: buildChatBubble(chatList[index]),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: pickImageFromCamera,
              backgroundColor: kButtonPurple,
              shape: const CircleBorder(),
              child: const Icon(Icons.camera_alt, color: Colors.white),
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
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
        }
      }).catchError((e) {
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
} */

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'package:gesturetalk1/constants/app_colors.dart';

class ImageToGestureScreen extends StatefulWidget {
  const ImageToGestureScreen({Key? key}) : super(key: key);

  @override
  State<ImageToGestureScreen> createState() => _ImageToGestureScreenState();
}

class _ImageToGestureScreenState extends State<ImageToGestureScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> chatList = [];

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        chatList.add({"type": "image", "data": imageFile});
        chatList.add({"type": "loading"});
      });
      _scrollToBottom();

      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      String extractedText = recognizedText.text.trim();
      if (extractedText.isEmpty) {
        setState(() {
          chatList.removeWhere((item) => item["type"] == "loading");
          chatList.add({
            'type': 'notfound',
            'data': "⚠️ No text found in image",
          });
        });
        _scrollToBottom();
        return;
      }

      setState(() {
        chatList.removeWhere((item) => item["type"] == "loading");
      });

      await fetchVideoWithFallback(extractedText);
    }
  }

  Future<void> fetchVideoWithFallback(String label) async {
    final words = label.split(RegExp(r'\s+'));

    // Try full sentence first
    bool foundAny = await fetchSingleVideo(label);

    // Try each word separately if no match
    if (!foundAny) {
      for (final word in words) {
        if (word.trim().isEmpty) continue;
        bool wordFound = await fetchSingleVideo(word);
        if (wordFound) {
          foundAny = true;
          break; // stop after first successful word match
        }
      }
    }

    if (!foundAny) {
      setState(() {
        chatList.add({'type': 'notfound', 'data': "⚠️ Gesture not found"});
      });
      _scrollToBottom();
    }
  }

  Future<bool> fetchSingleVideo(String label) async {
    try {
      final response = await supabase
          .from('i2_gesture_videos')
          .select()
          .ilike('label', '%${label.trim()}%')
          .limit(1)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception("Query timed out"),
          );

      if (response.isNotEmpty) {
        final videoUrl = response[0]['image_url'] as String?;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          setState(() {
            chatList.add({'type': 'video', 'url': videoUrl, 'label': label});
          });
          _scrollToBottom();
          return true;
        }
      }
      return false;
    } catch (e) {
      setState(() {
        chatList.add({'type': 'notfound', 'data': "⚠️ Error loading gesture"});
      });
      _scrollToBottom();
      showError("Error fetching gesture: $e");
      return false;
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildChatBubble(Map<String, dynamic> item) {
    if (item["type"] == "image") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              item["data"],
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    } else if (item["type"] == "loading") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CircularProgressIndicator(),
          ),
        ],
      );
    } else if (item["type"] == "video") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 250,
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: VideoWidget(videoUrl: item['url']!),
          ),
        ],
      );
    } else if (item["type"] == "notfound") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item["data"],
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item["data"],
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBackgroundDark : kBackgroundColor,
      appBar: AppBar(
        title: const Text('Image to Gesture'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextWhite,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: buildChatBubble(chatList[index]),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: pickImageFromCamera,
              backgroundColor: kButtonPurple,
              shape: const CircleBorder(),
              child: const Icon(Icons.camera_alt, color: Colors.white),
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
