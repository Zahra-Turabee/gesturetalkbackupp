import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math; // ⭐ YE NEW IMPORT ADD KAREIN
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
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

  // TensorFlow Lite interpreter
  Interpreter? _interpreter;
  List<String> _labels = [
    'stop',
    'hello',
    'i am in pain',
    'good luck',
    'i love you',
    'i want to talk',
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Model ki details check karne ke liye function
  void debugModelInfo() {
    if (_interpreter != null) {
      try {
        // Input tensor info
        var inputTensor = _interpreter!.getInputTensor(0);
        print('Input shape: ${inputTensor.shape}');
        print('Input type: ${inputTensor.type}');

        // Output tensor info
        var outputTensor = _interpreter!.getOutputTensor(0);
        print('Output shape: ${outputTensor.shape}');
        print('Output type: ${outputTensor.type}');
      } catch (e) {
        print('Debug model info error: $e');
      }
    }
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      debugModelInfo(); // Model info check karein
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      showError('Failed to load model: $e');
    }
  }

  // ⭐ REPLACE: Enhanced preprocessing with debug info
  Uint8List preprocessImageWithDebug(String imagePath) {
    try {
      print('Reading image bytes...');
      final imageBytes = File(imagePath).readAsBytesSync();
      print('Image bytes read: ${imageBytes.length}');

      print('Decoding image...');
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      print('Original image size: ${image.width}x${image.height}');

      print('Resizing image to 224x224...');
      final resized = img.copyResize(image, width: 224, height: 224);
      print('Image resized successfully');

      print('Converting to input array...');
      final input = Uint8List(1 * 224 * 224 * 3);
      int pixelIndex = 0;

      // Sample some pixel values for debugging
      List<String> samplePixels = [];

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);

          // Different preprocessing approaches - try each one
          int r, g, b;

          // Method 1: Direct RGB (0-255)
          r = (pixel.r * 255).toInt().clamp(0, 255);
          g = (pixel.g * 255).toInt().clamp(0, 255);
          b = (pixel.b * 255).toInt().clamp(0, 255);

          input[pixelIndex++] = r;
          input[pixelIndex++] = g;
          input[pixelIndex++] = b;

          // Sample first few pixels for debugging
          if (samplePixels.length < 5) {
            samplePixels.add('($r,$g,$b)');
          }
        }
      }

      print('Sample pixels: ${samplePixels.join(", ")}');
      print('Input array size: ${input.length}');
      print('Expected size: ${224 * 224 * 3}');

      return input;
    } catch (e) {
      print('Image preprocessing error: $e');
      rethrow;
    }
  }

  // ⭐ REPLACE: Complete debug prediction function
  Future<void> pickImageAndPredict() async {
    print('=== PREDICTION DEBUG START ===');

    if (_interpreter == null) {
      print('ERROR: Model not loaded');
      showError('Model not loaded yet');
      return;
    }

    print('Model is loaded, proceeding with image picker');
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      print('Image picked: ${picked.path}');

      try {
        // Step 1: Check if file exists
        final file = File(picked.path);
        if (!file.existsSync()) {
          throw Exception('Image file does not exist');
        }
        print('Image file exists, size: ${file.lengthSync()} bytes');

        // Step 2: Process image with detailed logging
        print('Starting image preprocessing...');
        final input = preprocessImageWithDebug(picked.path);
        print('Image preprocessing completed');

        // Step 3: Check model input requirements
        var inputTensor = _interpreter!.getInputTensor(0);
        print('Required input shape: ${inputTensor.shape}');
        print('Required input type: ${inputTensor.type}');
        print('Our input size: ${input.length}');

        // Step 4: Reshape input
        final reshapedInput = input.reshape([1, 224, 224, 3]);
        print('Input reshaped successfully');

        // Step 5: Prepare output with multiple attempts
        var outputTensor;
        var outputTensorInfo = _interpreter!.getOutputTensor(0);
        print('Required output shape: ${outputTensorInfo.shape}');
        print('Required output type: ${outputTensorInfo.type}');

        // Try different output formats based on model requirements
        if (outputTensorInfo.shape.length == 2 &&
            outputTensorInfo.shape[1] == 6) {
          // Format: [1, 6]
          outputTensor = List.generate(1, (i) => List.filled(6, 0.0));
          print('Using List<List<double>> output format');
        } else {
          // Fallback format
          outputTensor = Float32List(6).reshape([1, 6]);
          print('Using Float32List output format');
        }

        // Step 6: Run inference with error handling
        print('Running inference...');
        try {
          _interpreter!.run(reshapedInput, outputTensor);
          print('Inference completed successfully');
        } catch (e) {
          print('Inference failed: $e');
          throw Exception('Model inference failed: $e');
        }

        // Step 7: Process results with detailed logging
        List<double> scores;
        if (outputTensor is List<List>) {
          scores = outputTensor[0].map<double>((e) => e.toDouble()).toList();
        } else {
          final flatOutput = outputTensor.reshape([6]);
          scores = flatOutput.map<double>((e) => e.toDouble()).toList();
        }

        print('Raw scores: $scores');

        // Apply softmax if scores look like logits (very high/low values)
        if (scores.any((score) => score.abs() > 10)) {
          print('Applying softmax to scores...');
          scores = applySoftmax(scores);
          print('Softmax scores: $scores');
        }

        // Step 8: Find prediction
        double maxScore = scores[0];
        int maxIndex = 0;
        for (int i = 1; i < scores.length; i++) {
          if (scores[i] > maxScore) {
            maxScore = scores[i];
            maxIndex = i;
          }
        }

        print('Max score: $maxScore at index: $maxIndex');
        print('Predicted label: ${_labels[maxIndex]}');

        // Step 9: Show all predictions for debugging
        String allPredictions = '';
        for (int i = 0; i < _labels.length; i++) {
          allPredictions +=
              '${_labels[i]}: ${(scores[i] * 100).toStringAsFixed(1)}%\n';
        }
        print('All predictions:\n$allPredictions');

        // Step 10: Check confidence threshold
        if (maxScore < 0.1) {
          // Very low threshold for debugging
          showError(
            'All predictions very low. Check model and image quality.\n$allPredictions',
          );
          return;
        }

        String detectedWord = _labels[maxIndex];

        setState(() {
          messages.add({
            'type': 'output',
            'text':
                '$detectedWord (${(maxScore * 100).toStringAsFixed(1)}%)\n\nAll:\n$allPredictions',
          });
        });

        fetchVideo(detectedWord);
      } catch (e) {
        print('PREDICTION ERROR: $e');
        print('Stack trace: ${StackTrace.current}');
        showError("Prediction failed: $e");
      }
    } else {
      print('No image selected');
    }

    print('=== PREDICTION DEBUG END ===');
  }

  // ⭐ ADD: Softmax function for logits
  List<double> applySoftmax(List<double> logits) {
    // Find max for numerical stability
    double maxLogit = logits.reduce((a, b) => a > b ? a : b);

    // Compute exp(x - max)
    List<double> expValues = logits.map((x) => math.exp(x - maxLogit)).toList();

    // Compute sum
    double sum = expValues.reduce((a, b) => a + b);

    // Normalize
    return expValues.map((x) => x / sum).toList();
  }

  // ⭐ ADD: Simple test function
  void testModelWithDummyData() async {
    if (_interpreter == null) {
      print('Model not loaded');
      return;
    }

    print('=== TESTING MODEL WITH DUMMY DATA ===');

    try {
      // Create dummy input (random values between 0-255)
      final dummyInput = Uint8List(224 * 224 * 3);
      for (int i = 0; i < dummyInput.length; i++) {
        dummyInput[i] = (i % 256); // Fill with pattern
      }

      final reshapedInput = dummyInput.reshape([1, 224, 224, 3]);
      print('Dummy input created and reshaped');

      // Prepare output
      final outputTensor = List.generate(1, (i) => List.filled(6, 0.0));

      // Run inference
      _interpreter!.run(reshapedInput, outputTensor);
      print('Dummy inference completed');

      final scores = outputTensor[0].map<double>((e) => e.toDouble()).toList();
      print('Dummy prediction scores: $scores');

      // Find max
      double maxScore = scores[0];
      int maxIndex = 0;
      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      print(
        'Dummy prediction: ${_labels[maxIndex]} with confidence: $maxScore',
      );

      showError('Model test completed! Check console for results.');
    } catch (e) {
      print('Dummy test failed: $e');
      showError('Model test failed: $e');
    }
  }

  void fetchVideo(String label) async {
    try {
      print('Fetching video for label: $label');

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
        print('Video found: $videoUrl');
        setState(() {
          messages.add({'type': 'video', 'url': videoUrl});
        });
      } else {
        print('No video found for label: $label');
        setState(() {
          messages.add({
            'type': 'notfound',
            'text': "⚠️ Gesture for '$label' not found",
          });
        });
      }
    } catch (e) {
      print('Error fetching gesture: $e');
      showError("Error fetching gesture: $e");
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Gesture Talk"),
        backgroundColor: const Color.fromARGB(255, 134, 58, 169),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Debug info container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Text(
              'Model Status: ${_interpreter != null ? "Loaded ✓" : "Loading..."}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
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
            child: Column(
              children: [
                // ⭐ CHANGED: Two rows of buttons for better layout
                Row(
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
                        backgroundColor: const Color.fromARGB(
                          255,
                          153,
                          56,
                          183,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final label = _controller.text.trim();
                        if (label.isNotEmpty) {
                          fetchVideo(label);
                          _controller.clear();
                        }
                      },
                      child: const Text("Send"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          _interpreter != null ? pickImageAndPredict : null,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text("Gesture"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                    // ⭐ ADD: Test Model button
                    ElevatedButton.icon(
                      onPressed:
                          _interpreter != null ? testModelWithDummyData : null,
                      icon: const Icon(Icons.bug_report, size: 18),
                      label: const Text("Test Model"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// VideoWidget class remains the same
class VideoWidget extends StatefulWidget {
  final String videoUrl;
  const VideoWidget({super.key, required this.videoUrl});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    try {
      final encodedUrl = Uri.encodeFull(widget.videoUrl);
      print('Initializing video: $encodedUrl');

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
              print("Video initialization failed: $e");
              if (mounted) {
                setState(() {
                  _error = e.toString();
                });
              }
            });
    } catch (e) {
      print("Video setup failed: $e");
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red),
              Text('Video failed to load'),
            ],
          ),
        ),
      );
    }

    return _isInitialized
        ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        )
        : Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
  }
}
