import 'package:flutter/material.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'videoplayer_screen.dart';

class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({Key? key}) : super(key: key);

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  String selectedCategory = 'Music';

  final Map<String, List<Map<String, String>>> categoryVideos = {
    'Music': [
      {'id': 'W5VxKmAh8tY'},
      {'id': 'k08lV8GO43w'},
      {'id': 'fKUBNQc83sg'},
      {'id': 'z_jzRLVmbjE'},
      {'id': 'rum8YtlVCGA'},
      {'id': 'nbHo3YAzbB8'},
      {'id': 'H3KSKS3TTbc'},
      {'id': 'CxHMO4mH16k'},
      {'id': 'pZMO-Sx4LU8'},
      {'id': 'sjln9OMOw-0'},
      {'id': 'pxlRS1v0MyU'},
      {'id': 'M6zMVvpPqxQ'},
      {'id': 'QmKnQjBf8wM'},
      {'id': 'fK3cBbJ7cPI'},
      {'id': 'MyTJaclSJgo'}, // 👈 Replaced last video ID here
    ],
    'Comedy': [
      {'id': 'k3qLNv9PyNM'},
      {'id': '62HmWgGtzeo'},
      {'id': 'SbxLFo7kfjw'},
      {'id': '6mPYWMqSYGU'},
      {'id': 'WTiL_YSTYCM'},
      {'id': '9Uqk4h9MWcw'},
      {'id': 'iqt29njco3M'},
      {'id': 'N8cUy163_rg'},
      {'id': '0XJpvOcc4ag'},
      {'id': 'nAgumQK9VtM'},
      {'id': 'kjtVOM0Hubw'},
      {'id': 'kMAoBGDzAG8'},
    ],
    'Short Films': [
      {'id': 'rW2g5cwxrqQ'},
      {'id': 'zON0wDD7VJY'},
      {'id': 'NuyQTmFSj9A'},
      {'id': 'Bl1FOKpFY2Q'},
      {'id': 'XrqSF2OOz_M'},
      {'id': 'wEKLEeY_WeQ'},
      {'id': '5hPtU8Jbpg0'},
      {'id': 'iD_tsK_aqIQ'},
      {'id': 'K7rPUuEXvvo'},
      {'id': 'Nq77_880cy8'},
      {'id': 'nTB61iR6cVQ'},
      {'id': '38y_1EWIE9I'},
    ],
    'Charlie Chaplin': [
      {'id': '_0a998z_G4g'},
      {'id': '6n9ESFJTnHs'},
      {'id': 'AkLnj5pJtDI'},
      {'id': 'Z7-QdoofMq8'},
      {'id': 'UwahG1s4dqI'},
      {'id': 'G09dfRrUxUM'},
      {'id': 'xBjk18ggIcI'},
      {'id': 'vhfofjBFpQw'},
      {'id': 'o9NfXIXzgnA'},
      {'id': 'Da05CRAZ97c'},
      {'id': 'Yym5xcpnA4E'},
      {'id': 'pJIa6X2t_7U'},
    ],
    'DIY Crafts': [
      {'id': 'EbetaWeMYAA'},
      {'id': 'g2Z9YogD43o'},
      {'id': 'ILJmyV3LQM8'},
      {'id': 'd0SkbVYRrxo'},
      {'id': 'pgxmPoVyj80'},
      {'id': 'zxHMWXSTfu0'},
      {'id': 'Tsp6FxJtjuA'},
      {'id': 'xqESXxfKv8o'},
      {'id': 'TdB9g-o2bmU'},
      {'id': 'ZMIniSzJ7RQ'},
      {'id': 'FZSe2Cjz2-s'},
      {'id': 'ghf6g-_Gds4'},
    ],
    'Cooking': [
      {'id': 'lVfNStAU178'},
      {'id': 'CoFAfGwtqAg'},
      {'id': 'zPxQjuFoUBc'},
      {'id': 'eqxk2rVPbdA'},
      {'id': '3SVi80fjs7U'},
      {'id': '08PzUdjfYys'},
      {'id': '-LIGJzqwp60'},
      {'id': 'M1ALtNdNAx8'},
      {'id': 'rM7qDWJprxM'},
      {'id': 'BRaTJ-ZsCcg'},
      {'id': 'Ypnd_7sVz1k'},
      {'id': 'lGWntfREhig'},
    ],
  };

  final Map<String, IconData> categoryIcons = {
    'Music': Icons.music_note,
    'Comedy': Icons.emoji_emotions,
    'Short Films': Icons.movie_filter,
    'Charlie Chaplin': Icons.movie,
    'DIY Crafts': Icons.palette,
    'Cooking': Icons.restaurant_menu,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedVideos = categoryVideos[selectedCategory] ?? [];
    final icon = categoryIcons[selectedCategory] ?? Icons.play_arrow;

    return Scaffold(
      backgroundColor: isDark ? kBackgroundDark : kBackgroundColor,
      appBar: AppBar(
        title: const Text('Entertainment'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  categoryVideos.keys
                      .map((title) => _buildCategoryButton(title))
                      .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildVideoGrid(selectedVideos, icon),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = title),
        child: Chip(
          label: Text(
            title,
            style: TextStyle(
              color: selectedCategory == title ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor:
              selectedCategory == title ? kButtonPurple : Colors.grey[300],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildVideoGrid(List<Map<String, String>> videos, IconData icon) {
    return GridView.builder(
      itemCount: videos.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final videoId = videos[index]['id']!;
        final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

        final relatedVideos = List.generate(
          videos.length,
          (i) => {
            'videoId': videos[i]['id']!,
            'title': '$selectedCategory Video ${i + 1}',
          },
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => VideoPlayerScreen(
                      videoId: videoId,
                      title: '$selectedCategory Video ${index + 1}',
                      relatedVideos: relatedVideos,
                    ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(thumbnailUrl, fit: BoxFit.cover),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: 40),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
