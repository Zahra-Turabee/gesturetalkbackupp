import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineSelect extends StatefulWidget {
  @override
  _OfflineSelectState createState() => _OfflineSelectState();
}

class _OfflineSelectState extends State<OfflineSelect> {
  final List<String> helloImages = [
    'assets/hello/hello1.png',
    'assets/hello/hello2.jpg',
    'assets/hello/hello3.png',
    'assets/hello/hello4.jpg',
  ];

  // Hive Box for selected images
  late Box<String> selectedImagesBox;

  @override
  void initState() {
    super.initState();
    _openBox(); // Open the Hive box on screen load
  }

  // Open the box where selected image paths will be saved
  void _openBox() async {
    selectedImagesBox = await Hive.openBox<String>('selectedImages');
  }

  // Save selected image (only if not already saved)
  void _saveImageToHive(String imagePath) async {
    if (!selectedImagesBox.values.contains(imagePath)) {
      selectedImagesBox.add(imagePath); // Only add if not already present
    }
  }

  // Show the confirmation dialog for saving the image
  void _showConfirmationPopup(String imagePath, String groupName) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Use this gesture?'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(imagePath, height: 180),
                Text(' $groupName', style: TextStyle(fontSize: 27)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () => Navigator.of(context).pop(),
              ),
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  _saveImageToHive(imagePath); // Save image only
                  Navigator.of(context).pop(); // Close dialog
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offline Select Screen')),
      body: Padding(
        padding: const EdgeInsets.all(4.11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    helloImages.map((imagePath) {
                      return GestureDetector(
                        onTap: () => _showConfirmationPopup(imagePath, 'Hello'),
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 84,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
