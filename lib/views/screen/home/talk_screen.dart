import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

class SignToTextScreen extends StatefulWidget {
  @override
  _SignToTextScreenState createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  String detectedText = "No sign detected yet.";
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  List<String> labels1 = [];
  List<String> labels2 = [];
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  Future<void> loadModels() async {
    try {
      _interpreter1 = await Interpreter.fromAsset(
        "assets/tfmodel/model_unquant.tflite",
      );
      _interpreter2 = await Interpreter.fromAsset(
        "assets/tfmodel/model_unquant1.tflite",
      );
      labels1 = await loadLabels("assets/tfmodel/labels.txt");
      labels2 = await loadLabels("assets/tfmodel/labels1.txt");
      print("✅ Models and labels loaded successfully!");
    } catch (e) {
      print("❌ Error loading models: $e");
      setState(() {
        detectedText = "Error loading models.";
      });
    }
  }

  Future<List<String>> loadLabels(String path) async {
    try {
      String labelsData = await DefaultAssetBundle.of(context).loadString(path);
      return labelsData.split('\n').map((e) => e.trim()).toList();
    } catch (e) {
      print("❌ Error loading labels: $e");
      return [];
    }
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> detectSign() async {
    if (selectedImage == null) {
      setState(() {
        detectedText = "⚠️ No image selected!";
      });
      return;
    }

    if (_interpreter1 == null || _interpreter2 == null) {
      setState(() {
        detectedText = "⚠️ Models not loaded!";
      });
      return;
    }

    try {
      Uint8List imageBytes = await selectedImage!.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        setState(() {
          detectedText = "Error: Unable to decode image!";
        });
        return;
      }

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

      var output1 = List.generate(1, (i) => List.filled(14, 0.0));
      var output2 = List.generate(1, (i) => List.filled(26, 0.0));

      _interpreter1!.run(input, output1);
      _interpreter2!.run(input, output2);

      int predictedIndex1 = output1[0].indexOf(
        output1[0].reduce((a, b) => a > b ? a : b),
      );
      int predictedIndex2 = output2[0].indexOf(
        output2[0].reduce((a, b) => a > b ? a : b),
      );

      if (labels1.isEmpty || labels2.isEmpty) {
        setState(() {
          detectedText = "⚠️ Label file missing or empty!";
        });
        return;
      }

      String predictedSign1 = labels1[predictedIndex1];
      String predictedSign2 = labels2[predictedIndex2];

      setState(() {
        detectedText = "Detected: $predictedSign1 / $predictedSign2";
        _textController.text = detectedText;
      });
    } catch (e, stackTrace) {
      print("❌ Error processing image: $e");
      print("🔴 Stack Trace: $stackTrace");
      setState(() {
        detectedText = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    _interpreter1?.close();
    _interpreter2?.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Sign-to-Text Converter"),
        centerTitle: true,
      ),
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                detectedText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child:
                    selectedImage != null
                        ? Image.file(selectedImage!, fit: BoxFit.cover)
                        : const Center(
                          child: Icon(
                            Icons.cloud_upload,
                            size: 50,
                            color: Colors.purple,
                          ),
                        ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImageFromGallery,
                child: const Text("Pick from Gallery"),
              ),
              ElevatedButton(
                onPressed: takePhoto,
                child: const Text("Take a Photo"),
              ),
              ElevatedButton(
                onPressed: detectSign,
                child: const Text("Detect Sign"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
