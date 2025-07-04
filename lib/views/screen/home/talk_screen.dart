/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class GestureTalkScreen extends StatefulWidget {
  const GestureTalkScreen({super.key});

  @override
  State<GestureTalkScreen> createState() => _GestureTalkScreenState();
}

class _GestureTalkScreenState extends State<GestureTalkScreen> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;

  File? selectedImage;
  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  List<String> labels1 = [];
  List<String> labels2 = [];
  String detectedText = "👋 Tap to detect gesture";

  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  Future<void> loadModels() async {
    _interpreter1 = await Interpreter.fromAsset(
      "assets/tfmodel/model_unquant.tflite",
    );
    _interpreter2 = await Interpreter.fromAsset(
      "assets/tfmodel/model_unquant1.tflite",
    );
    labels1 = await loadLabels("assets/tfmodel/labels.txt");
    labels2 = await loadLabels("assets/tfmodel/labels1.txt");
  }

  Future<List<String>> loadLabels(String path) async {
    String labelsData = await DefaultAssetBundle.of(context).loadString(path);
    return labelsData.split('\n').map((e) => e.trim()).toList();
  }

  Future<void> takePhotoAndDetect() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() => selectedImage = File(pickedFile.path));

    Uint8List imageBytes = await selectedImage!.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return;

    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    List<List<List<List<double>>>> input = [
      List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.rNormalized.toDouble(),
            pixel.gNormalized.toDouble(),
            pixel.bNormalized.toDouble(),
          ];
        }),
      ),
    ];

    var output1 = List.generate(1, (_) => List.filled(14, 0.0));
    var output2 = List.generate(1, (_) => List.filled(26, 0.0));
    _interpreter1!.run(input, output1);
    _interpreter2!.run(input, output2);

    int i1 = output1[0].indexOf(output1[0].reduce((a, b) => a > b ? a : b));
    int i2 = output2[0].indexOf(output2[0].reduce((a, b) => a > b ? a : b));

    String result = "${labels1[i1]} ${labels2[i2]}";
    setState(() {
      detectedText = "✋ Detected: $result";
      messages.add({'type': 'input', 'text': result});
    });
  }

  void fetchGestureVideo(String label) async {
    setState(() {
      messages.add({'type': 'input', 'text': label});
    });

    final response =
        await supabase
            .from('gestureimages')
            .select()
            .eq('label', label.toLowerCase())
            .maybeSingle();

    if (response != null && response['image_url'] != null) {
      setState(() {
        messages.add({'type': 'video', 'url': response['image_url']});
      });
    } else {
      setState(() {
        messages.add({
          'type': 'notfound',
          'text': "No gesture found for '$label'",
        });
      });
    }
  }

  @override
  void dispose() {
    _interpreter1?.close();
    _interpreter2?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Talk'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.purple.shade50,
      body: Column(
        children: [
          GestureDetector(
            onTap: takePhotoAndDetect,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      detectedText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(color: Colors.white),
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
                } else {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type to respond...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final input = _controller.text.trim();
                    if (input.isNotEmpty) {
                      fetchGestureVideo(input);
                      _controller.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    "Send",
                    style: TextStyle(color: Colors.white),
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
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.setLooping(true);
          _controller.play();
        }
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
*/

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class GestureTalkScreen extends StatefulWidget {
  const GestureTalkScreen({super.key});

  @override
  State<GestureTalkScreen> createState() => _GestureTalkScreenState();
}

class _GestureTalkScreenState extends State<GestureTalkScreen> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;

  File? selectedImage;
  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  List<String> labels1 = [];
  List<String> labels2 = [];
  String detectedText = "👋 Tap camera to detect gesture";

  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  Future<void> loadModels() async {
    _interpreter1 = await Interpreter.fromAsset(
      "assets/tfmodel/model_unquant.tflite",
    );
    _interpreter2 = await Interpreter.fromAsset(
      "assets/tfmodel/model_unquant1.tflite",
    );
    labels1 = await loadLabels("assets/tfmodel/labels.txt");
    labels2 = await loadLabels("assets/tfmodel/labels1.txt");
  }

  Future<List<String>> loadLabels(String path) async {
    String labelsData = await DefaultAssetBundle.of(context).loadString(path);
    return labelsData.split('\n').map((e) => e.trim()).toList();
  }

  Future<void> takePhotoAndDetect() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() => selectedImage = File(pickedFile.path));

    Uint8List imageBytes = await selectedImage!.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return;

    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    List<List<List<List<double>>>> input = [
      List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.rNormalized.toDouble(),
            pixel.gNormalized.toDouble(),
            pixel.bNormalized.toDouble(),
          ];
        }),
      ),
    ];

    var output1 = List.generate(1, (_) => List.filled(14, 0.0));
    var output2 = List.generate(1, (_) => List.filled(26, 0.0));
    _interpreter1!.run(input, output1);
    _interpreter2!.run(input, output2);

    int i1 = output1[0].indexOf(output1[0].reduce((a, b) => a > b ? a : b));
    int i2 = output2[0].indexOf(output2[0].reduce((a, b) => a > b ? a : b));

    String result = "${labels1[i1]} ${labels2[i2]}";
    setState(() {
      detectedText = "✋ Detected: $result";
      messages.add({'type': 'input', 'text': result});
    });
  }

  void fetchGestureVideo(String label) async {
    setState(() {
      messages.add({'type': 'input', 'text': label});
    });

    final response =
        await supabase
            .from('gestureimages')
            .select()
            .eq('label', label.toLowerCase())
            .maybeSingle();

    if (response != null && response['image_url'] != null) {
      setState(() {
        messages.add({'type': 'video', 'url': response['image_url']});
      });
    } else {
      setState(() {
        messages.add({
          'type': 'notfound',
          'text': "No gesture found for '$label'",
        });
      });
    }
  }

  @override
  void dispose() {
    _interpreter1?.close();
    _interpreter2?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Talk'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Removed top camera container
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
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(color: colorScheme.onPrimary),
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
                } else {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(color: colorScheme.onTertiary),
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt, color: colorScheme.primary),
                  onPressed: takePhotoAndDetect,
                  tooltip: 'Open Camera',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: detectedText,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final input = _controller.text.trim();
                    if (input.isNotEmpty) {
                      fetchGestureVideo(input);
                      _controller.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  child: Text(
                    "Send",
                    style: TextStyle(color: colorScheme.onPrimary),
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
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.setLooping(true);
          _controller.play();
        }
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
