import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'offline_select.dart';

class OfflineModeScreen extends StatefulWidget {
  @override
  _OfflineModeScreenState createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  List<Map<String, dynamic>> images = [];
  bool deleteMode = false;
  AudioPlayer? _audioPlayer;
  late Box box; // <-- Box variable to open once

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // ✅ Create only once
    openBoxAndLoadImages(); // Open box once & load images
  }

  Future<void> openBoxAndLoadImages() async {
    box = await Hive.openBox('offlineImages'); // Open once
    loadImages();
  }

  Future<void> loadImages() async {
    setState(() {
      images =
          box.values
              .cast<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
    });
  }

  void playVoice(String groupName) async {
    try {
      await _audioPlayer?.stop();
      String audioPath = 'offline_voices/${groupName.toLowerCase()}.mp3';
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer?.play(AssetSource(audioPath));
      print('Playing: $audioPath');
    } catch (e) {
      print('Error playing voice: $e');
    }
  }

  void stopVoice() {
    _audioPlayer?.stop();
  }

  Future<void> deleteImage(int index) async {
    await box.deleteAt(index); // Use already opened box
    await loadImages();
  }

  void showPopup(String imagePath, String groupName) async {
    playVoice(groupName);

    await showDialog(
      context: context,
      barrierDismissible: true, // ✅ Tap outside to dismiss
      builder:
          (_) => WillPopScope(
            onWillPop: () async {
              stopVoice(); // ✅ Stop on back button
              return true;
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Block tap-through
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            stopVoice(); // ✅ Stop on cross
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Image.asset(imagePath, height: 180),
                      SizedBox(height: 12),
                      Text(
                        groupName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    stopVoice(); // ✅ Stop if dismissed by outside tap
  }

  Future<bool> onWillPop() async {
    if (deleteMode) {
      setState(() => deleteMode = false);
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    stopVoice();
    _audioPlayer?.dispose(); // ✅ Dispose to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Offline Mode'),
          actions: [
            IconButton(
              icon: Icon(deleteMode ? Icons.cancel : Icons.edit),
              onPressed: () => setState(() => deleteMode = !deleteMode),
            ),
          ],
        ),
        body: GridView.builder(
          padding: EdgeInsets.all(12),
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) {
            final imagePath = images[index]['image'];
            final groupName = images[index]['group'];

            return Stack(
              children: [
                GestureDetector(
                  onTap: () => showPopup(imagePath, groupName),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                if (deleteMode)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => deleteImage(index),
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 14,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OfflineSelectScreen()),
            );
            await loadImages(); // Refresh list after return
          },
          child: Icon(Icons.add),
          backgroundColor: const Color.fromARGB(142, 160, 1, 157),
        ),
      ),
    );
  }
}
