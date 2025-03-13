import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stress_management/pages/main_pages/mandala_page/prediction_stress_mandala_and_music.dart';
import 'package:http/http.dart' as http;
import 'package:stress_management/pages/main_pages/music_page/categories_screen.dart';
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../music_page/listening_history_screen.dart';

class PredictionAndHistory extends StatefulWidget {
  @override
  _PredictionAndHistoryState createState() => _PredictionAndHistoryState();
}

class _PredictionAndHistoryState extends State<PredictionAndHistory> {
  int stressLevel = 0;

  Future<void> predictStress() async {
    try {
      final listeningSnapshot = await FirebaseFirestore.instance.collection('listening_logs')
          .orderBy('time_listened', descending: true)
          .limit(1)
          .get();

      final coloringSnapshot = await FirebaseFirestore.instance.collection('coloring_logs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (listeningSnapshot.docs.isEmpty || coloringSnapshot.docs.isEmpty) {
        print("No sufficient data to predict stress.");
        return;
      }

      var listeningData = listeningSnapshot.docs.first.data() as Map<String, dynamic>;
      var coloringData = coloringSnapshot.docs.first.data() as Map<String, dynamic>;

      final url = Uri.parse("http://127.0.0.1:5000/predict_stress");
      final payload = {
        "Age": 25,
        "Gender": "Male",
        "Mandala Design Pattern": coloringData['color_palette_id'],
        "Mandala Colors Used": coloringData['colors_used'],
        "Mandala Time Spent": coloringData['color_duration'],
        "Music Type": listeningData['music_type'],
        "Music Time Spent": listeningData['time_listened'],
        "Total_Time": coloringData['color_duration'] + listeningData['time_listened']
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stressLevel = data["Stress Level"];
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PredictionStressMandalaAndMusic(stressLevel: data["Stress Level"]),
          ),
        );
      }
    } catch (e) {
      print("Error predicting stress: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Prediction Stress and History',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoriesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30),
                  // ),
                ),
                child: const Text(
                  'Mandala Arts History',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ListeningHistoryScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30),
                  // ),
                ),
                child: Text(
                  'Listening History',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  predictStress();
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30),
                  // ),
                ),
                child: const Text(
                  'Predict Stress',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 40),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('listening_logs')
                    .orderBy('time_listened', descending: true)
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  if (snapshot.data!.docs.isEmpty) return Text("No most played track.");
                  var track = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.blueGrey,
                    child: ListTile(
                      title: Text(track['track_title'], style: TextStyle(color: Colors.white)),
                      subtitle: Text("Listened for ${track['time_listened']} seconds", style: TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              ),
              SizedBox(height: 40),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('coloring_logs')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  if (snapshot.data!.docs.isEmpty) return Text("No coloring logs.");
                  var coloringLog = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.deepPurple,
                    child: ListTile(
                      title: Text(coloringLog['image_name'], style: TextStyle(color: Colors.white)),
                      subtitle: Text("Colored for ${coloringLog['color_duration']} seconds", style: TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
