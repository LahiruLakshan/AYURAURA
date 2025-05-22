import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final Map<String, String> track;

  PlayerScreen({required this.track});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration? totalDuration;
  Duration listenedDuration = Duration.zero;
  DateTime? startTime;
  late AnimationController _animationController;
  List<double> visualizerHeights = List.generate(30, (index) => 0.0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
    );

    _audioPlayer.setUrl(widget.track['url']!).then((_) {
      setState(() {
        totalDuration = _audioPlayer.duration;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        listenedDuration = position;
        _updateVisualizer();
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    });
  }

  void _updateVisualizer() {
    setState(() {
      for (int i = 0; i < visualizerHeights.length; i++) {
        if (isPlaying) {
          visualizerHeights[i] = (0.1 + (i % 3) * 0.2) * (1 + _animationController.value);
        } else {
          visualizerHeights[i] = 0.1;
        }
      }
    });
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      _animationController.stop();
    } else {
      startTime = DateTime.now();
      await _audioPlayer.play();
      _animationController.repeat(reverse: true);
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _submitListeningData() async {
    if (startTime == null || totalDuration == null) return;
    final percentageListened = (listenedDuration.inSeconds / totalDuration!.inSeconds) * 100;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('listening_logs').add({
        'user_id': user.uid,
        'track_title': widget.track['title'],
        'date_time_listened': startTime,
        'time_listened': listenedDuration.inSeconds,
        'percentage_listened': percentageListened,
      });

      _showCategoryDialog();
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'deep sleep music (delta waves)':
        return Icons.nightlight_round;
      case 'gregorian chants or om mantra meditation':
        return Icons.volume_up;
      case 'tibetan singing bowls':
        return Icons.waves;
      case 'ambient meditation music':
        return Icons.spa;
      case 'soft instrumental':
        return Icons.piano;
      case 'alpha waves':
        return Icons.psychology;
      case 'nature sounds with soft piano':
        return Icons.nature;
      case 'lofi chill beats':
        return Icons.headphones;
      default:
        return Icons.music_note;
    }
  }


  void _showCategoryDialog() {
    final categories = [
      'Deep Sleep Music (Delta Waves)',
      'Gregorian Chants or Om Mantra Meditation',
      'Tibetan Singing Bowls',
      'Ambient Meditation Music',
      'Soft Instrumental',
      'Alpha Waves',
      'Nature Sounds with Soft Piano',
      'Lofi Chill Beats',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("What's your favourite music category?"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                return ListTile(
                  leading: Icon(_getCategoryIcon(category)),
                  title: Text(category),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You selected "$category" as your favorite'),
                        backgroundColor: Colors.blueAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context); // Exit PlayerScreen
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.track['title']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 40), // To balance the back button
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Music Icon
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    // Play/Pause Button
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Timer Text
                    Text(
                      _formatDuration(listenedDuration),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _submitListeningData,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Save Session',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

