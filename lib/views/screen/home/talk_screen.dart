import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      // Add a simple chat bubble to indicate image was captured
      setState(() {
        messages.add({'type': 'input', 'text': '📷 Gesture image captured'});
      });
    }
  }

  void sendTextMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({'type': 'input', 'text': message});
        messages.add({'type': 'output', 'text': 'You said: $message'});
      });
      _controller.clear();
    }
  }

  Widget buildMessageBubble(Map<String, String> message) {
    final isInput = message['type'] == 'input';
    return Container(
      alignment: isInput ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isInput ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(
            color: isInput ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                return buildMessageBubble(messages[index]);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: pickImageFromCamera,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendTextMessage,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
