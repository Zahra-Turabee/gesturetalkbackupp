import 'package:flutter/material.dart';

class EntertainmentScreen extends StatelessWidget {
  const EntertainmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entertainment'),
        backgroundColor: Color.fromARGB(255, 142, 38, 160),
      ),
      body: const Center(
        child: Text('Entertainment Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
