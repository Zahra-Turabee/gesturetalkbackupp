import 'package:flutter/material.dart';

class GesturePopup extends StatelessWidget {
  final String imagePath;
  final String groupName;
  final String languageTab;

  GesturePopup({
    required this.imagePath,
    required this.groupName,
    required this.languageTab,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$groupName - $languageTab'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 150, height: 150),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Save selection to Hive or your local DB here
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.check),
                label: Text('Select'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
                label: Text('Cancel'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
