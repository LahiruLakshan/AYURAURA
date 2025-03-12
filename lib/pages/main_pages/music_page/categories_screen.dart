import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/music_page/tracks_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final List<String> categories = [
    'Type 1', 'Type 2', 'Type 3', 'Type 4',
    'Type 5', 'Type 6', 'Type 7', 'Type 8'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Music Categories')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(categories[index], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TracksScreen(category: categories[index]),
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