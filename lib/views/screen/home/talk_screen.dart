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

  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  List<String> labels1 = [];
  List<String> labels2 = [];

  int photoCount = 0;

  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  List<String> suggestions = [];
  bool showSuggestions = false;

  // Gallery functionality variables
  List<Map<String, dynamic>> gestureList = [];
  bool showGallery = false;
  bool isLoading = false;

  final List<String> categories = [
    'General',
    'Daily',
    'Emergency',
    'Greetings',
  ];
  String selectedCategory = 'General';

  @override
  void initState() {
    super.initState();
    loadModels();
    _controller.addListener(_handleTyping);
    // Load default category on start
    loadGesturesByCategory(selectedCategory);
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
    return labelsData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Gallery functionality methods
  Future<void> loadGesturesByCategory(String category) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('gestureimages')
          .select('*')
          .eq('category', category);

      setState(() {
        gestureList = List<Map<String, dynamic>>.from(response);
        selectedCategory = category;
        isLoading = false;
      });

      print('Loaded ${gestureList.length} gestures for category: $category');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showError("Error loading gestures: $e");
      print('Error loading gestures: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void onVideoTap(Map<String, dynamic> gesture) {
    final label = gesture['label'];
    final videoUrl = gesture['image_url'];

    setState(() {
      // Add video on right side first
      if (videoUrl != null && videoUrl.isNotEmpty) {
        messages.add({'type': 'selected_video', 'url': videoUrl});
      }
      // Add text message on left side after video
      messages.add({'type': 'selected_text', 'text': label});
    });
  }

  // Camera functionality
  Future<void> takePhotoAndDetect() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    await processImageFile(imageFile);
  }

  Future<void> processImageFile(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return;

    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    List<List<List<List<double>>>> input = [
      List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedImage.getPixelSafe(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    ];

    var output1 = List.generate(1, (_) => List.filled(14, 0.0));
    var output2 = List.generate(1, (_) => List.filled(26, 0.0));
    _interpreter1!.run(input, output1);
    _interpreter2!.run(input, output2);

    photoCount++;
    int index1 = (photoCount - 1) % labels1.length;
    int index2 = (photoCount - 1) % labels2.length;

    String result = "${labels1[index1]} ${labels2[index2]}";

    setState(() {
      messages.add({'type': 'image', 'file': imageFile});
      messages.add({'type': 'input', 'text': result});
    });

    fetchGestureVideo(labels1[index1].toLowerCase());
  }

  void fetchGestureVideo(String label) async {
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
    }
  }

  void _handleTyping() async {
    final text = _controller.text.trim().toLowerCase();
    if (text.isEmpty) {
      setState(() {
        suggestions = [];
        showSuggestions = false;
      });
      return;
    }

    final response = await supabase
        .from('gestureimages')
        .select('label')
        .ilike('label', '$text%')
        .limit(5);

    setState(() {
      suggestions = response.map<String>((e) => e['label'] as String).toList();
      showSuggestions = suggestions.isNotEmpty;
    });
  }

  // Open full screen gallery
  void openFullScreenGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenGallery(
              gestureList: gestureList,
              categories: categories,
              selectedCategory: selectedCategory,
              onCategoryChanged: loadGesturesByCategory,
              isLoading: isLoading,
              onVideoSelected: (gesture) {
                Navigator.pop(context);
                onVideoTap(gesture);
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter1?.close();
    _interpreter2?.close();
    _controller.removeListener(_handleTyping);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Talk'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.deepPurple,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                if (msg['type'] == 'image') {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(msg['file'], width: 180),
                      ),
                    ),
                  );
                } else if (msg['type'] == 'input') {
                  return Align(
                    alignment: Alignment.centerLeft,
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
                } else if (msg['type'] == 'response') {
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
                      child: VideoWidget(
                        videoUrl: msg['url']!,
                        key: ValueKey(msg['url']),
                      ),
                    ),
                  );
                } else if (msg['type'] == 'selected_video') {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 250,
                      height: 200,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: VideoWidget(
                        videoUrl: msg['url']!,
                        key: ValueKey(msg['url']),
                      ),
                    ),
                  );
                } else if (msg['type'] == 'selected_text') {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          // Suggestions
          if (showSuggestions)
            Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    suggestions.map((word) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            _controller.text = word;
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
                            setState(() {
                              showSuggestions = false;
                            });
                          },
                          child: Chip(
                            label: Text(word),
                            backgroundColor: Colors.deepPurple[100],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

          // Input Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Gallery Icon (Left side)
                IconButton(
                  icon: const Icon(
                    Icons.video_collection,
                    color: Colors.deepPurple,
                  ),
                  onPressed: openFullScreenGallery,
                ),
                // Camera Icon
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                  onPressed: takePhotoAndDetect,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your response...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final input = _controller.text.trim();
                    if (input.isNotEmpty) {
                      setState(() {
                        messages.add({'type': 'response', 'text': input});
                      });
                      fetchGestureVideo(input);
                      _controller.clear();
                      setState(() {
                        showSuggestions = false;
                      });
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

// Full Screen Gallery Widget
class FullScreenGallery extends StatefulWidget {
  final List<Map<String, dynamic>> gestureList;
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final bool isLoading;
  final Function(Map<String, dynamic>) onVideoSelected;

  const FullScreenGallery({
    super.key,
    required this.gestureList,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isLoading,
    required this.onVideoSelected,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Video Gallery"),
        backgroundColor: const Color.fromARGB(255, 134, 58, 169),
      ),
      body: Column(
        children: [
          // Category Selection Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final cat = widget.categories[index];
                final bool isSelected = cat == widget.selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color.fromARGB(255, 153, 56, 183),
                    onSelected: (selected) {
                      if (selected && cat != widget.selectedCategory) {
                        widget.onCategoryChanged(cat);
                      }
                    },
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.grey[300],
                  ),
                );
              },
            ),
          ),
          // Video Gallery
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child:
                  widget.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : widget.gestureList.isEmpty
                      ? Center(
                        child: Text(
                          'No gestures found for ${widget.selectedCategory}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 columns
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8, // Adjust aspect ratio
                            ),
                        itemCount: widget.gestureList.length,
                        itemBuilder: (context, index) {
                          final gesture = widget.gestureList[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                VideoWidget(
                                  videoUrl: gesture['image_url'],
                                  key: ValueKey(
                                    gesture['image_url'],
                                  ), // Important for unique videos
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap:
                                          () => widget.onVideoSelected(gesture),
                                    ),
                                  ),
                                ),
                                // Label at bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      gesture['label'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.videoUrl.isEmpty) return;

    final encodedUrl = Uri.encodeFull(widget.videoUrl);
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
            debugPrint("Video init failed: $e");
          });
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initializeVideo();
    }
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
