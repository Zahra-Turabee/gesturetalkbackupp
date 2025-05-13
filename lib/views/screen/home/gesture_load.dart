import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class GestureLoadScreen extends StatefulWidget {
  @override
  _GestureLoadScreenState createState() => _GestureLoadScreenState();
}

class _GestureLoadScreenState extends State<GestureLoadScreen> {
  Map<String, List<String>> gestureGroups = {};
  Box<dynamic>? _offlineImagesBox;

  @override
  void initState() {
    super.initState();
    loadGestures();
    openHiveBox();
  }

  // Load gestures from the JSON file
  Future<void> loadGestures() async {
    final loadedGestures = await GestureLoader.loadGesturesFromJson();
    setState(() {
      gestureGroups = loadedGestures;
    });
  }

  // Open the Hive box to store offline images
  Future<void> openHiveBox() async {
    _offlineImagesBox = await Hive.openBox('offlineImages');
    setState(() {});
  }

  // Save selected image to Hive
  Future<void> saveImageToHive(String imagePath, String groupName) async {
    await _offlineImagesBox!.add({'image': imagePath, 'group': groupName});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Added to Offline Mode")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Gestures')),
      body:
          _offlineImagesBox == null
              ? Center(child: CircularProgressIndicator())
              : gestureGroups.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView(
                children:
                    gestureGroups.entries.map((entry) {
                      final groupName = entry.key;
                      final images = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              groupName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            itemCount: images.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemBuilder: (_, index) {
                              final imagePath = images[index];
                              return GestureDetector(
                                onTap:
                                    () => saveImageToHive(imagePath, groupName),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: AssetImage(imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
              ),
    );
  }
}

class GestureLoader {
  static Future<Map<String, List<String>>> loadGesturesFromJson() async {
    final String jsonString = await rootBundle.loadString(
      'assets/gestures.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert dynamic list into List<String>
    return jsonMap.map((key, value) {
      List<String> imagePaths = List<String>.from(value);
      return MapEntry(key, imagePaths);
    });
  }
}
