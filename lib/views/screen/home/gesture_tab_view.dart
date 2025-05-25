import 'package:flutter/material.dart';
import 'gesture_popup.dart';

class GestureTabView extends StatelessWidget {
  final String selectedTab; // 'ASL', 'BSL', or 'PSL'

  GestureTabView({required this.selectedTab});

  // Example data structure for headings and images per tab
  // In practice, load this from your JSON or assets dynamically
  final Map<String, Map<String, List<String>>> data = {
    'ASL': {
      'hello': ['assets/offline_gestures/hello/asl_hello.png'],
      'angry': ['assets/offline_gestures/angry/asl_angry.png'],
    },
    'BSL': {
      'hello': ['assets/offline_gestures/hello/bsl_hello.png'],
      'angry': ['assets/offline_gestures/angry/bsl_angry.png'],
    },
    'PSL': {
      'hello': ['assets/offline_gestures/hello/psl_hello.png'],
      'angry': ['assets/offline_gestures/angry/psl_angry.png'],
    },
  };

  @override
  Widget build(BuildContext context) {
    final headings = data[selectedTab]?.keys.toList() ?? [];

    return ListView.builder(
      itemCount: headings.length,
      itemBuilder: (context, index) {
        String heading = headings[index];
        List<String> images = data[selectedTab]?[heading] ?? [];

        return _buildHeadingSection(context, heading, images);
      },
    );
  }

  Widget _buildHeadingSection(
    BuildContext context,
    String heading,
    List<String> images,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => GesturePopup(
                            imagePath: images[i],
                            groupName: heading,
                            languageTab: selectedTab,
                          ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    child: Image.asset(images[i]),
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
