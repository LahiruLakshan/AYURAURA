import 'package:stress_management/pages/main_pages/quiz_page/results_screen.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../models/question_model/question.dart';

class QuizScreen extends StatefulWidget {
  final List<String>? initialAnswers;

  QuizScreen({this.initialAnswers});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> questions = [
    Question("How much pressure are you feeling right now?", [
      "1. 😰 I feel extremely anxious and unable to cope with daily tasks.",
      "2. 😟 I feel quite overwhelmed and find it hard to relax.",
      "3. 😐 I'm aware of some stress but I'm managing okay.",
      "4. 🙂 I have a few minor concerns but feel generally fine.",
      "5. 😌 I'm completely relaxed and worry-free."
    ]),
    Question("How happy do you feel today?", [
      "1. 😐 I feel mostly unhappy or neutral.",
      "2. 🙂 I feel a little happy, but nothing special.",
      "3. 😊 I feel generally happy and content.",
      "4. 😄 I feel very happy and positive about my day.",
      "5. 🤩 I'm bursting with joy and feeling ecstatic!"
    ]),
    Question("How calm and relaxed do you feel?", [
      "1. 😫 I feel very agitated or anxious.",
      "2. 😟 I feel a bit uneasy but not too stressed.",
      "3. 😌 I feel generally calm and at ease.",
      "4. 🧘‍♂️ I feel very relaxed and peaceful.",
      "5. 🌅 I'm completely serene and tranquil."
    ]),
    Question("How energetic are you feeling right now?", [
      "1. 😴 I feel very low on energy and sluggish.",
      "2. 😪 I have a bit of energy, but mostly tired.",
      "3. 🙂 I have enough energy to get through the day.",
      "4. 💪 I feel quite energetic and active.",
      "5. ⚡ I'm full of energy and ready for anything!"
    ]),
  ];

  late List<String> selectedAnswers;

  @override
  void initState() {
    super.initState();
    selectedAnswers = widget.initialAnswers ?? List.filled(questions.length, "");
  }

  bool get isAllQuestionsAnswered {
    return !selectedAnswers.any((answer) => answer.isEmpty);
  }

  void submitAnswers() {
    if (isAllQuestionsAnswered) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(selectedAnswers: selectedAnswers),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions before submitting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Stress Assessment",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "Please answer all questions to assess your current stress levels:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...List.generate(questions.length, (questionIndex) {
                        return _buildQuestionCard(questionIndex);
                      }),
                      SizedBox(height: 80), // Space for the button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: submitAnswers,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Submit Answers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int questionIndex) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Question ${questionIndex + 1}: ${questions[questionIndex].questionText}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
          ...questions[questionIndex].answers.map((answer) {
            return RadioListTile<String>(
              title: Text(
                answer,
                style: TextStyle(fontSize: 16),
              ),
              value: answer,
              groupValue: selectedAnswers[questionIndex],
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  selectedAnswers[questionIndex] = value!;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}