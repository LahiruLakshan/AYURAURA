import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/music_page/player_screen.dart';

class TracksScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  TracksScreen({required this.category});

  @override
  _TracksScreenState createState() => _TracksScreenState();
}

class _TracksScreenState extends State<TracksScreen> {
  String searchQuery = '';
  final Map<String, double> playProgress = {};

  List<Map<String, dynamic>> get filteredTracks {
    if (searchQuery.isEmpty) return List<Map<String, dynamic>>.from(widget.category['tracks']);
    return List<Map<String, dynamic>>.from(widget.category['tracks'])
        .where((track) =>
            track['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Color getAccentColor() {
    switch (widget.category['type'].toString().toLowerCase()) {
      case 'deep sleep music (delta waves)':
        return Colors.indigo;
      case 'gregorian chants or om mantra meditation':
        return Colors.purple;
      case 'tibetan singing bowls':
        return Colors.orange;
      case 'ambient meditation music':
        return Colors.teal;
      case 'soft instrumental':
        return Colors.pink;
      case 'alpha waves':
        return Colors.green;
      case 'nature sounds with soft piano':
        return Colors.lightGreen;
      case 'lofi chill beats':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = getAccentColor();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Hero(
              tag: 'category_${widget.category['type']}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(
                                  widget.category['type'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '${widget.category['tracks'].length} Meditation Tracks',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search tracks...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = filteredTracks[index];
                final progress = playProgress[track['url']] ?? 0.0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(15),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Update progress
                        setState(() {
                          if (playProgress.containsKey(track['url'])) {
                            playProgress.remove(track['url']);
                          } else {
                            playProgress[track['url']] = 0.3;
                          }
                        });
                        
                        // Convert track to Map<String, String>
                        final playerTrack = {
                          'title': track['title'].toString(),
                          'url': track['url'].toString(),
                        };
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(track: playerTrack),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    color: accentColor,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track['title'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (progress > 0) ...[
                                        SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey.withOpacity(0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredTracks.length,
            ),
          ),
        ],
      ),
    );
  }
}