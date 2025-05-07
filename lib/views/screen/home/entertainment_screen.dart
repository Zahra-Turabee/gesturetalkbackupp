import 'package:flutter/material.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'videoplayer_screen.dart';

class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allVideos = [
    {
      'title': 'Sign Language Basics',
      'id': 'f_hH7v4fQ5A',
      'category': 'Sign Language',
    },
    {'title': 'Music with Captions', 'id': 'QBKDg3pJOvg', 'category': 'Music'},
    {
      'title': 'Educational Video (CC)',
      'id': 'K6NGrFj0q4w',
      'category': 'Education',
    },
    {'title': 'News in Sign Language', 'id': 'VfWfVKYnyOY', 'category': 'News'},
  ];

  final List<String> categories = [
    'All',
    'Sign Language',
    'Music',
    'Education',
    'News',
  ];

  String selectedCategory = 'All';

  List<Map<String, String>> get filteredVideos {
    final query = _searchController.text.toLowerCase();
    return allVideos.where((video) {
      final matchesCategory =
          selectedCategory == 'All' || video['category'] == selectedCategory;
      final matchesSearch = video['title']!.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBackgroundDark : kBackgroundColor,
      appBar: AppBar(
        title: const Text('Entertainment'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextWhite,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildCategories(),
            const SizedBox(height: 10),
            Expanded(child: _buildVideoList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search videos...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: isDark ? kWhiteContainer.withOpacity(0.1) : kWhiteContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kGreyColor),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kButtonPurple : kButtonGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: kTextWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoList() {
    if (filteredVideos.isEmpty) {
      return const Center(
        child: Text('No videos found.', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        final thumbnailUrl = 'https://img.youtube.com/vi/${video['id']}/0.jpg';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                thumbnailUrl,
                width: 100,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              video['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => VideoPlayerScreen(
                        videoId: video['id']!,
                        title: video['title']!,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
