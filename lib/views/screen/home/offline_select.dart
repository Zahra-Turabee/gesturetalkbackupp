import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class OfflineSelectScreen extends StatefulWidget {
  @override
  _OfflineSelectScreenState createState() => _OfflineSelectScreenState();
}

class _OfflineSelectScreenState extends State<OfflineSelectScreen> {
  Box? _offlineImagesBox;
  String _searchQuery = ''; // ✅ Search query state

  @override
  void initState() {
    super.initState();
    _initHiveBox();
  }

  Future<void> _initHiveBox() async {
    _offlineImagesBox = await Hive.openBox('offlineImages');
    setState(() {});
  }

  Future<Map<String, List<String>>> loadGesturesFromJson() async {
    final String jsonString = await rootBundle.loadString(
      'assets/gestures.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) {
      List<String> imagePaths = List<String>.from(value);
      return MapEntry(key, imagePaths);
    });
  }

  Future<void> saveImageToHive(String imagePath, String groupName) async {
    if (_offlineImagesBox != null) {
      bool alreadyExists = _offlineImagesBox!.values.any(
        (element) =>
            element['image'] == imagePath && element['group'] == groupName,
      );

      if (!alreadyExists) {
        await _offlineImagesBox!.add({'image': imagePath, 'group': groupName});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Added to Offline Mode")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Already added")));
      }
    }
  }

  void _showImageDialog(String imagePath, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath),
              SizedBox(height: 8),
              Text(
                "You want to add this in offline screen?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      saveImageToHive(imagePath, groupName);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_offlineImagesBox == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Offline Gesture Selection')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Gesture Selection'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by heading (e.g., Angry)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: loadGesturesFromJson(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading gestures'));
          }

          final gestureGroups = snapshot.data ?? {};

          // ✅ Filter groups based on search
          final filteredEntries = gestureGroups.entries.where((entry) {
            return entry.key.toLowerCase().contains(_searchQuery);
          });

          if (filteredEntries.isEmpty) {
            return Center(child: Text("No matching headings found."));
          }

          return ListView(
            children:
                filteredEntries.map((entry) {
                  final groupName = entry.key;
                  final imagePaths = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(18.50),
                        child: Text(
                          groupName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              imagePaths.map((imagePath) {
                                return GestureDetector(
                                  onTap:
                                      () => _showImageDialog(
                                        imagePath,
                                        groupName,
                                      ),
                                  child: Image.asset(
                                    imagePath,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
