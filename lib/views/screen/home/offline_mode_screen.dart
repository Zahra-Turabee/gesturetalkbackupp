import 'package:flutter/material.dart';

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
        backgroundColor: Color.fromARGB(255, 142, 38, 160),
      ),
      body: const Center(
        child: Text('Offline Mode Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
