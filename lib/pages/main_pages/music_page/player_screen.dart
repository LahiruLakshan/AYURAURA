import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final String trackName;

  PlayerScreen({required this.trackName});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  List<double> waveData = [];

  final Map<String, String> trackUrls = {
    'Track 1': 'https://res.cloudinary.com/dl3mpo0w3/video/upload/v1741783864/Music%20Tracks/Type%201%20-%20Deep%20Sleep%20Music%20%28Delta%20Waves%29/xdqs0agovocen6j76lwy.mp3',
    'Track 2': 'https://res.cloudinary.com/dl3mpo0w3/video/upload/v1741783864/Music%20Tracks/Type%201%20-%20Deep%20Sleep%20Music%20%28Delta%20Waves%29/xdqs0agovocen6j76lwy.mp3',
    'Track 3': 'https://res.cloudinary.com/YOUR_CLOUD_NAME/video/upload/v1234567890/track3.mpeg',
    'Track 4': 'https://res.cloudinary.com/YOUR_CLOUD_NAME/video/upload/v1234567890/track4.mpeg',
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer.setUrl(trackUrls[widget.trackName]!);
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      setState(() {
        isPlaying = false;
      });
      await _audioPlayer.pause();
    } else {
      setState(() {
        isPlaying = true;
      });
      await _audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.trackName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Playing ${widget.trackName}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            StreamBuilder<Duration?> (
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: snapshot.hasData ? snapshot.data!.inSeconds / (_audioPlayer.duration?.inSeconds ?? 1) : 0.0,
                      backgroundColor: Colors.grey,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Text(snapshot.hasData ? "${snapshot.data!.inMinutes}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, '0')}" : "0:00")
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _togglePlayPause,
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 40),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}