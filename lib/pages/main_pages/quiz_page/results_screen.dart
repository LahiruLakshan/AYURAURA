import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stress_management/pages/main_pages/quiz_page/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import 'mood_log_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<String> selectedAnswers;

  ResultsScreen({required this.selectedAnswers});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = false;
  double stressLevel = 0;
  int daysSinceRegistration = 0;
  Map<String, dynamic> data = <String, dynamic>{};

  Future<Timestamp?> getCreatedAtTimestamp() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;//to get the currently logged-in user.
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

  @override
  void initState() {
    super.initState();
    fetchDaysSinceRegistration();
  }

  @override
  Widget build(BuildContext context) {
    List<String> answerNumbers = widget.selectedAnswers.map((answer) {
      return answer[0];
    }).toList();

    List<Map<String, dynamic>> emotionCards = [
      {
        'title': 'Stress Level',
        'answer': widget.selectedAnswers[0],
        'icon': Icons.psychology,
        'color': Color(0xFFF59E0B),
        'bgColor': Color(0xFFFEF3C7),
      },
      {
        'title': 'Happiness Level',
        'answer': widget.selectedAnswers[1],
        'icon': Icons.sentiment_satisfied,
        'color': Color(0xFF059669),
        'bgColor': Color(0xFFD1FAE5),
      },
      {
        'title': 'Calmness Level',
        'answer': widget.selectedAnswers[2],
        'icon': Icons.spa,
        'color': Color(0xFF8B5CF6),
        'bgColor': Color(0xFFEDE9FE),
      },
      {
        'title': 'Energy Level',
        'answer': widget.selectedAnswers[3],
        'icon': Icons.bolt,
        'color': Color(0xFF60A5FA),
        'bgColor': Color(0xFFDBEAFE),
      },
    ];

    Future<void> saveMoodLog(int predictedDays) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in.");
        return;
      }

      CollectionReference moodLogs = FirebaseFirestore.instance.collection('mood_logs');
      String today = DateTime.now().toIso8601String().split("T")[0]; // Get only the date

      QuerySnapshot query = await moodLogs
          .where("userId", isEqualTo: user.uid)
          .where("date", isEqualTo: today)
          .limit(1)
          .get();

      Map<String, dynamic> moodData = {
        "userId": user.uid,
        "date": today,
        "stress": answerNumbers[0],
        "happiness": answerNumbers[1],
        "calmness": answerNumbers[2],
        "energy": answerNumbers[3],
        "predictedRecoveryDays": predictedDays,
        "timestamp": FieldValue.serverTimestamp(),
      };

      if (query.docs.isNotEmpty) {
        // Update the existing mood log
        await moodLogs.doc(query.docs.first.id).update(moodData);
        print("Mood log updated for today.");
      } else {
        // Create a new mood log
        await moodLogs.add(moodData);
        print("New mood log saved.");
      }
    }

    Future<void> predictStress() async {
      setState(() => _isLoading = true);
      try {
        final listeningSnapshot = await FirebaseFirestore.instance
            .collection('listening_logs')//orders the logs by time_listened in descending order, and retrieves the most recent log.
            .orderBy('time_listened', descending: true)
            .limit(1)
            .get();

        final coloringSnapshot = await FirebaseFirestore.instance
            .collection('coloring_logs')//orders the logs by timestamp, and retrieves the most recent log.
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

        final url = Uri.parse("${AppConstants.BASE_URL_QUIZ}predict_recovery_time");//The app sends a POST request to the backend API

        final payload = {//constructor load below data
          "Age": data["age"],
          "Gender": data["gender"] == "Male" ? 0:1,
          "Days": daysSinceRegistration,
          "DailyStressLevel": answerNumbers[0],
          "DailyEnergyLevel": answerNumbers[1],
          "DailyHappinessLevel": answerNumbers[2],
          "DailyCalmnessLevel": answerNumbers[3],
          "DurationofParticipation": listeningData['time_listened'] + coloringData['color_duration'],
          "BaseRecoveryDays": daysSinceRegistration >= 4 ? 5:10,
        };
        print("payload : $payload");
        final response = await http.post( //backend API call
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print("Response: $responseData");

          setState(() {
            stressLevel = responseData["predicted_recovery_Days"];
          });

          await saveMoodLog(responseData["predicted_recovery_Days"].round());
          setState(() => _isLoading = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MoodLogScreen(predictedDays: responseData["predicted_recovery_Days"].round()),
            ),
          );
        }
      } catch (e) {
        print("Error predicting stress: $e");
        setState(() => _isLoading = false);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8FFF5),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Emotional Summary',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Here's how you're feeling today",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 32),
                  ...emotionCards.map((emotion) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: emotion['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              emotion['icon'] as IconData,
                              color: emotion['color'] as Color,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emotion['title'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  emotion['answer'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _isLoading ? null : predictStress(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF059669),
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Color(0xFF059669).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Calculate Recovery Time',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: TextButton(
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
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Edit My Answers',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

