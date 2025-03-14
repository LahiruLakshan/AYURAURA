import 'package:path/path.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stress_management/constants/constants.dart';

import '../../../constants/colors.dart';
import 'eye_stress_level_screen.dart';

class StressScaleQuiz extends StatefulWidget {
  final File videoFile;
  const StressScaleQuiz({super.key, required this.videoFile});

  @override
  _StressScaleQuizState createState() => _StressScaleQuizState();
}

class _StressScaleQuizState extends State<StressScaleQuiz> {
  bool _isLoading = false;
  bool _predictionDone = false;
  double confidence = 33.01;
  final List<String> questions = [
    "In the last month, how often have you been upset because of something that happened unexpectedly?",
    "In the last month, how often have you felt that you were unable to control the important things in your life?",
    "In the last month, how often have you felt nervous and stressed?",
    "In the last month, how often have you felt confident about your ability to handle your personal problems?",
    "In the last month, how often have you felt that things were going your way?",
    "In the last month, how often have you found that you could not cope with all the things that you had to do?",
    "In the last month, how often have you been able to control irritations in your life?",
    "In the last month, how often have you felt that you were on top of things?",
    "In the last month, how often have you been angered because of things that happened that were outside of your control?",
    "In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?",
  ];

  void _showError(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar( // Fixed Context to context
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }




  List<int?> answers = List.filled(10, null);
  int _currentQuestionIndex = 0;
  bool _showResults = false;
  int _totalScore = 0;

  void _answerQuestion(int score) {
    setState(() {
      answers[_currentQuestionIndex] = score;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _calculateScore() {
    int total = 0;
    for (int i = 0; i < answers.length; i++) {
      int score = answers[i] ?? 0;
      // Reverse scores for questions 4, 5, 7, 8 (0-indexed 3,4,6,7)
      if ([3, 4, 6, 7].contains(i)) {
        total += (4 - score);
      } else {
        total += score;
      }
    }
    setState(() {
      _totalScore = total;
      _showResults = true;
    });
  }

  String _getStressLevel() {
    print("((_totalScore/40*100) + confidence)/2 :----------   ${((_totalScore/40*100) + confidence)/2}");
    if (((_totalScore/40*100) + confidence)/2 <= 13) return 'Low Stress';
    if (((_totalScore/40*100) + confidence)/2 <= 26) return 'Moderate Stress';
    if (((_totalScore/40*100) + confidence)/2 <= 34) return 'Severe Stress';
    if (((_totalScore/40*100) + confidence)/2 <= 65) return 'Critical Stress';
    return 'High Perceived Stress';
  }

  Widget _buildQuestion(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${index + 1}/10',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          questions[index],
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 30),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i <= 4; i++)
              ChoiceChip(
                label: Text('$i'),
                selected: answers[index] == i,
                onSelected: (selected) => _answerQuestion(i),
                selectedColor: Colors.green[300],
              ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          '0 - never  1 - almost never  2 - sometimes  3 - fairly often  4 - very often',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {


    Future<void> _analyzeStress() async {
      setState(() => _isLoading = true);


      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${AppConstants.BASE_URL_EYE_ANALYSIS}predict'),
        );

        final videoFile = await http.MultipartFile.fromPath(
          'video',
          widget.videoFile.path,
        );
        request.files.add(videoFile);

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print("-----------------" + responseBody);

        if (response.statusCode == 200) {
          setState(() => _predictionDone = true);
          // Navigator.push(
          //   context, // Correct context here
          //   MaterialPageRoute(
          //     builder: (context) => EyeStressLevelScreen(responseData: responseBody),
          //   ),
          // );
        } else {
          _showError('Analysis failed: ${response.reasonPhrase}');
        }
      } catch (e) {
        _showError('Connection error: $e');
      } finally {
        setState(() => _isLoading = false);

      }
    }

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your PSS Score: $_totalScore',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),



          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: _isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.analytics, size: 24),
            label: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Analyze Stress Level'),
            onPressed: _isLoading ? null : _analyzeStress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(30),
              // ),
            ),
          ),
          SizedBox(height: 20),

          if(_predictionDone)
            Text(
              _getStressLevel(),
              style: TextStyle(
                fontSize: 22,
                color: ((_totalScore/40*100) + confidence)/2 <= 13
                    ? Colors.green
                    : ((_totalScore/40*100) + confidence)/2 <= 34
                    ? Colors.orange
                    : Colors.red,
              ),
            ),

          if(_predictionDone)
            Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: ((_totalScore/40*100) + confidence)/200,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                      Text('${(((_totalScore/40*100) + (confidence))/2).toStringAsFixed(2)}%'),
                    ],
                  ),
                  SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the main page
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('Return to Main Page'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(30),
                      // ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Percentage Interpretation:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('0%-33%: Low Stress\n34%-65%: Moderate Stress\n66%-100%: High Perceived Stress'),
                  SizedBox(height: 30),
                  Text(
                    'Disclaimer: This self-assessment does not reflect any particular diagnosis or course of treatment. '
                        'It is meant as a tool to help assess your stress level. If you have concerns about your well-being, '
                        'please consult a professional.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perceived Stress Scale'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showResults
            ? _buildResults(context)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestion(_currentQuestionIndex),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[300],
                      onPrimary: Colors.black,
                    ),
                  ),
                if (_currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed:
                    answers[_currentQuestionIndex] != null
                        ? _nextQuestion
                        : null,
                    child: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                if (_currentQuestionIndex == questions.length - 1)
                  ElevatedButton(
                    onPressed:
                    answers[_currentQuestionIndex] != null
                        ? _calculateScore
                        : null,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}