import 'package:flutter/material.dart';

class SOSSystemScreen extends StatelessWidget {
  const SOSSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS System'),
        backgroundColor: Color.fromARGB(255, 142, 38, 160),
      ),
      body: const Center(
        child: Text('SOS System Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
