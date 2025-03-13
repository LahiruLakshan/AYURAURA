import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stress_management/pages/main_pages/quiz_page/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants/colors.dart';
import 'mood_log_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<String> selectedAnswers;

  ResultsScreen({required this.selectedAnswers});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int stressLevel = 0;
  int daysSinceRegistration = 0;
  Map<String, dynamic> data = <String, dynamic>{};

  Future<Timestamp?> getCreatedAtTimestamp() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is currently logged in.");
      return null;
    }

    // Fetch the user document from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();


    // Check if the document exists and has a `createdAt` field
    if (userDoc.exists && userDoc.data() != null) {
      data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('createdAt')) {
        return data['createdAt'] as Timestamp;
      }
    }

    print("User document or `createdAt` field not found.");
    return null;
  }

  int calculateDaysSinceRegistration(Timestamp createdAt) {
    // Convert Firestore Timestamp to DateTime
    DateTime registrationDate = createdAt.toDate();

    // Get the current date and time
    DateTime now = DateTime.now();

    // Calculate the difference in days
    Duration difference = now.difference(registrationDate);
    return difference.inDays;
  }
  Future<void> fetchDaysSinceRegistration() async {
    Timestamp? createdAt = await getCreatedAtTimestamp();
    if (createdAt != null) {
      int days = calculateDaysSinceRegistration(createdAt);
      setState(() {
        daysSinceRegistration = days;
      });
    }
  }

  int getComplexityValue(String type) {
    switch (type.toLowerCase()) {
      case 'simple':
        return 3;
      case 'medium':
        return 2;
      case 'complex':
        return 1;
      default:
        return 1;
    }
  }

  int getMusicTypeValue(String type) {
    switch (type.toLowerCase()) {
      case 'Deep':
        return 1;
      case 'Gregorian':
        return 2;
      case 'Tibetan':
        return 3;
      case 'Ambient':
        return 4;
      case 'Soft':
        return 5;
      case 'Alpha':
        return 6;
      case 'Nature':
        return 7;
      case 'LoFI':
        return 8;
      default:
        return 1;
    }
  }
  @override
  void initState() {
    super.initState();
    fetchDaysSinceRegistration();
  }

  @override
  Widget build(BuildContext context) {
    List<String> answerNumbers = widget.selectedAnswers.map((answer) {
      return answer[0]; // Get the first character
    }).toList();


    print(answerNumbers);
    print(daysSinceRegistration);
    print(data["gender"]);

    Future<void> predictStress() async {
      try {
        final listeningSnapshot = await FirebaseFirestore.instance
            .collection('listening_logs')
            .orderBy('time_listened', descending: true)
            .limit(1)
            .get();

        final coloringSnapshot = await FirebaseFirestore.instance
            .collection('coloring_logs')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (listeningSnapshot.docs.isEmpty || coloringSnapshot.docs.isEmpty) {
          print("No sufficient data to predict stress.");
          return;
        }

        var listeningData =
        listeningSnapshot.docs.first.data() as Map<String, dynamic>;
        var coloringData =
        coloringSnapshot.docs.first.data() as Map<String, dynamic>;

        final url = Uri.parse("http://127.0.0.1:5000/predict_stress");

        final payload = {
          "Age": data["age"],
          "Gender": data["gender"],
          "Days": daysSinceRegistration,
          "DailyStressLevel": answerNumbers[0],
          "DailyEnergyLevel": answerNumbers[1],
          "DailyHappinessLevel": answerNumbers[2],
          "DailyCalmnessLevel": answerNumbers[3],
          "DurationofParticipation": listeningData['time_listened'] + coloringData['color_duration'],
          "BaseRecoveryDays": daysSinceRegistration >= 4 ? 5:10,
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
              builder: (context) => MoodLogScreen(predictedDays: 8),
            ),
          );
        }
      } catch (e) {
        print("Error predicting stress: $e");
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Emotional Summary for Today',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...widget.selectedAnswers.asMap().entries.map((entry) {
                int index = entry.key;
                String answer = entry.value;
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '$answer',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      width: double.maxFinite,
                    ),
                    SizedBox(height: 20),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoodLogScreen(predictedDays: 8),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Predict & Save My Mood Log 💾',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        initialAnswers: widget.selectedAnswers,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Edit My Answers ✏️',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
