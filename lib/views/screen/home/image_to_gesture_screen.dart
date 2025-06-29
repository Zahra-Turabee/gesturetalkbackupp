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

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import 'package:gesturetalk1/constants/app_colors.dart';

class ImageToGestureScreen extends StatefulWidget {
  const ImageToGestureScreen({Key? key}) : super(key: key);

  @override
  State<ImageToGestureScreen> createState() => _ImageToGestureScreenState();
}

class _ImageToGestureScreenState extends State<ImageToGestureScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> chatList = [];

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Add image bubble on right and loader on left
      setState(() {
        chatList.add({"type": "image", "data": imageFile});
        chatList.add({"type": "loading"});
      });
      _scrollToBottom();

      // Extract text using MLKit
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
        extractedText = "No text found!";
      }

      // Send text to FastAPI backend
      try {
        final response = await http.post(
          Uri.parse(
            "http://192.168.0.103:8000/match",
          ), // Change to your IP if needed
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"text": extractedText}),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          String videoResult =
              result["results"]
                  .toString(); // Adjust based on response structure
          replaceLoaderWithText(videoResult);
        } else {
          replaceLoaderWithText("Server error: ${response.statusCode}");
        }
      } catch (e) {
        replaceLoaderWithText("Connection error: ${e.toString()}");
      }

      _scrollToBottom();
    }
  }

  void replaceLoaderWithText(String text) {
    setState(() {
      int index = chatList.indexWhere((item) => item["type"] == "loading");
      if (index != -1) {
        chatList[index] = {"type": "text", "data": text};
      }
    });
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

          // Floating camera button
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
