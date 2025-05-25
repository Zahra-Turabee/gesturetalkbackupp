import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';

class OfflineSelectScreen extends StatefulWidget {
  @override
  _OfflineSelectScreenState createState() => _OfflineSelectScreenState();
}

class _OfflineSelectScreenState extends State<OfflineSelectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Map<String, List<String>>> _filteredData = {
    'PSL': {},
    'BSL': {},
    'ASL': {},
  };
  bool _isLoading = true;

  final List<String> languages = ['PSL', 'BSL', 'ASL'];
  final List<String> flags = [
    'assets/flags/pakistan.png', // PSL
    'assets/flags/uk.png', // BSL
    'assets/flags/usa.png', // ASL
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: languages.length, vsync: this);
    loadGestureData();
  }

  Future<void> loadGestureData() async {
    String jsonString = await rootBundle.loadString('assets/gestures.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    for (var group in jsonData.entries) {
      String groupName = group.key;
      List<String> images = List<String>.from(group.value);

      for (String imagePath in images) {
        if (imagePath.contains('psl_')) {
          _filteredData['PSL']!.putIfAbsent(groupName, () => []).add(imagePath);
        }
        if (imagePath.contains('bsl_')) {
          _filteredData['BSL']!.putIfAbsent(groupName, () => []).add(imagePath);
        }
        if (imagePath.contains('asl_')) {
          _filteredData['ASL']!.putIfAbsent(groupName, () => []).add(imagePath);
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> showAddDialog(String imagePath, String groupName) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.all(15),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You want to add this gesture to offline?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                Image.asset(imagePath, width: 150),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      onPressed: () async {
                        final box = await Hive.openBox('offlineImages');
                        bool alreadyExists = box.values.any(
                          (element) =>
                              element['image'] == imagePath &&
                              element['group'] == groupName,
                        );
                        if (alreadyExists) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("This gesture is already added."),
                            ),
                          );
                          return;
                        }

                        await box.add({'image': imagePath, 'group': groupName});
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gesture added to offline.")),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red, size: 32),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget buildTabContent(String langCode) {
    Map<String, List<String>> data = _filteredData[langCode]!;

    String heading = '';
    String flagPath = '';

    if (langCode == 'PSL') {
      heading = 'Pakistan Sign Language';
      flagPath = 'assets/flags/pakistan.png';
    } else if (langCode == 'BSL') {
      heading = 'British Sign Language';
      flagPath = 'assets/flags/uk.png';
    } else if (langCode == 'ASL') {
      heading = 'American Sign Language';
      flagPath = 'assets/flags/usa.png';
    }

    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(flagPath, width: 28, height: 28),
            SizedBox(width: 8),
            Text(
              heading,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 20),
        ...data.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key.toUpperCase(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    entry.value.map((imgPath) {
                      return GestureDetector(
                        onTap: () {
                          showAddDialog(imgPath, entry.key);
                        },
                        child: Image.asset(imgPath, height: 120),
                      );
                    }).toList(),
              ),
              SizedBox(height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Offline Select")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Select"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(languages.length, (index) {
            return Tab(
              icon: Image.asset(flags[index], width: 24),
              text: languages[index],
            );
          }),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          languages.length,
          (index) => buildTabContent(languages[index]),
        ),
      ),
    );
  }
}
