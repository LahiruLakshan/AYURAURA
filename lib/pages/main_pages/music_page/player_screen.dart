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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Meditation session recorded'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
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
    final accentColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withOpacity(0.8),
              accentColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.track['title']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Album Art and Visualizer
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular Album Art
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                        ),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: isPlaying ? _animationController.value * 0.1 : 0,
                              child: Center(
                                child: Icon(
                                  Icons.music_note,
                                  size: 100,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 40),

                      // Audio Visualizer
                      Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            visualizerHeights.length,
                            (index) => AnimatedContainer(
                              duration: Duration(milliseconds: 600),
                              width: 4,
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              height: visualizerHeights[index] * 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Progress Bar
                    StreamBuilder<Duration?>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = _audioPlayer.duration ?? Duration.zero;
                        
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(0.2),
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: position.inSeconds.toDouble(),
                                max: duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.replay_10, color: Colors.white, size: 32),
                          onPressed: () => _audioPlayer.seek(Duration(seconds: listenedDuration.inSeconds - 10)),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 40,
                                color: accentColor,
                                key: ValueKey<bool>(isPlaying),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.forward_10, color: Colors.white, size: 32),
                          onPressed: () => _audioPlayer.seek(Duration(seconds: listenedDuration.inSeconds + 10)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    TextButton.icon(
                      onPressed: _submitListeningData,
                      icon: Icon(Icons.check_circle_outline, color: Colors.white),
                      label: Text(
                        'Complete Meditation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

