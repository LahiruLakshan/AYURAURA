import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/music_page/player_screen.dart';


class TracksScreen extends StatelessWidget {
  final String category;
  final List<String> tracks = ['Track 1', 'Track 2', 'Track 3', 'Track 4'];

  TracksScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category Tracks')),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(tracks[index], style: TextStyle(fontSize: 18)),
              trailing: Icon(Icons.play_arrow, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(trackName: tracks[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}