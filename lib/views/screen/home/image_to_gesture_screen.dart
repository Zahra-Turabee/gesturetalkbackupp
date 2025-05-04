import 'package:flutter/material.dart';

class ImageToGestureScreen extends StatelessWidget {
  const ImageToGestureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to Gesture'),
        backgroundColor: Color.fromARGB(255, 142, 38, 160),
      ),
      body: const Center(
        child: Text('Image to Gesture Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
