import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/quiz_page/results_screen.dart';
import '../../../constants/colors.dart';
import '../../../models/question_model/question.dart';

class QuizScreen extends StatefulWidget {
  final List<String>? initialAnswers;
  const QuizScreen({Key? key, this.initialAnswers}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> questions = [
    Question("How much pressure are you feeling right now?", [
      "1. 😰 Extremely anxious, can't cope",
      "2. 😟 Quite overwhelmed",
      "3. 😐 Managing okay",
      "4. 🙂 Generally fine",
      "5. 😌 Completely relaxed"
    ]),
    Question("How happy do you feel today?", [
      "1. 😐 Mostly unhappy",
      "2. 🙂 A little happy",
      "3. 😊 Generally content",
      "4. 😄 Very positive",
      "5. 🤩 Bursting with joy"
    ]),
    Question("How calm and relaxed do you feel?", [
      "1. 😫 Very agitated",
      "2. 😟 A bit uneasy",
      "3. 😌 Generally calm",
      "4. 🧘‍♂️ Very peaceful",
      "5. 🌅 Completely serene"
    ]),
    Question("How energetic are you feeling right now?", [
      "1. 😴 Very sluggish",
      "2. 😪 Mostly tired",
      "3. 🙂 Enough energy",
      "4. 💪 Quite active",
      "5. ⚡ Full of energy"
    ]),
  ];

  late List<String> selectedAnswers;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    selectedAnswers = widget.initialAnswers ?? List.filled(questions.length, "");
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get isAllQuestionsAnswered => !selectedAnswers.any((answer) => answer.isEmpty);

  void _submitAnswers() {
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: LinearProgressIndicator(
        value: (_currentPage + 1) / questions.length,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 8,
      ),
    );
  }

  Widget _buildQuestionCard(int questionIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questions[questionIndex].questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...questions[questionIndex].answers.map((answer) {
            bool isSelected = selectedAnswers[questionIndex] == answer;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    selectedAnswers[questionIndex] = answer;
                  });
                  if (_currentPage < questions.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                          Icons.circle,
                          size: 12,
                          color: AppColors.primary,
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          answer,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Daily Check-In",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              itemCount: questions.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Text(
                          "Answer honestly to get the most accurate results",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _buildQuestionCard(index),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _currentPage == questions.length - 1
          ? FloatingActionButton.extended(
        onPressed: _submitAnswers,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.check),
        label: const Text("Submit Answers"),
      )
          : null,
    );
  }
}