import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'offline_select.dart';

class OfflineModeScreen extends StatefulWidget {
  @override
  _OfflineModeScreenState createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  List<String> selectedImages = [];
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedImages();
  }

  void _loadSelectedImages() async {
    final box = await Hive.openBox<String>('selectedImages');
    final allValues = box.values.toList();

    // Filter out non-image entries (e.g. 'groupName' or invalid strings)
    final validImages =
        allValues
            .where(
              (path) =>
                  path.endsWith('.png') ||
                  path.endsWith('.jpg') ||
                  path.endsWith('.jpeg'),
            )
            .toList();

    setState(() {
      selectedImages = validImages;
    });
  }

  void _deleteImage(int index) async {
    final box = await Hive.openBox<String>('selectedImages');
    // Find actual key of the image to delete from values
    final key = box.keys.elementAt(index);
    await box.delete(key);
    _loadSelectedImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Mode00'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body:
          selectedImages.isEmpty
              ? Center(child: Text('No image selected'))
              : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Stack(
                      children: [
                        Image.asset(selectedImages[index]),
                        if (isEditMode)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteImage(index),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OfflineSelect()),
          );
          _loadSelectedImages();
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(142, 160, 1, 115),
      ),
    );
  }
}
