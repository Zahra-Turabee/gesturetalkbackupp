import 'package:flutter/material.dart';

class TalkScreen extends StatelessWidget {
  const TalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk'),
        backgroundColor: Color.fromARGB(255, 142, 38, 160),
      ),
      body: const Center(
        child: Text('Talk Feature Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
