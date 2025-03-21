import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/behaviors/behavior_summery.dart';

class BehaviorsQuizScreen extends StatefulWidget {
  const BehaviorsQuizScreen({Key? key}) : super(key: key);

  @override
  State<BehaviorsQuizScreen> createState() => _BehaviorsQuizScreenState();
}

class _BehaviorsQuizScreenState extends State<BehaviorsQuizScreen> {
  int _currentQuestionIndex = 0;
  final List<Map<String, dynamic>> _questions = [
    {'text': 'On average, how many hours do you sleep per night?', 'range': [3, 9], 'image': 'assets/behaviors/sleep.png'},
    {'text': 'On average, how many days per week do you exercise?', 'range': [1, 7], 'image': 'assets/behaviors/exercise.png'},
    {'text': 'On average, how many hours per week do you spend on work/study?', 'range': [0, 100], 'image': 'assets/behaviors/work.png'},
    {'text': 'On average, how many hours per day do you spend on screens?', 'range': [0, 20], 'image': 'assets/behaviors/screen.png'},
    {'text': 'How would you rate your daily social interactions?', 'range': [1, 10], 'image': 'assets/behaviors/social.png'},
    {'text': 'How would you rate the healthiness of your diet?', 'range': [1, 10], 'image': 'assets/behaviors/diet.png'},
    {'text': 'How would you rate your smoking and drinking habits?', 'range': [1, 10], 'image': 'assets/behaviors/habits.png'},
    {'text': 'On average, how many hours per week do you spend on recreational activities?', 'range': [0, 30], 'image': 'assets/behaviors/recreation.png'},
  ];

  Map<int, double> _answers = {};

  @override
  void initState() {
    super.initState();
    // Set default value for exercise to 0
    _answers[1] = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    var question = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text("Question ${_currentQuestionIndex + 1}/8")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question['text'], textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Image.asset(question['image'], height: 200, fit: BoxFit.contain),
            SizedBox(height: 20),
            if (_currentQuestionIndex == 1) ...[
              Text("Select days:", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _answers[_currentQuestionIndex] = index.toDouble();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          primary: _answers[_currentQuestionIndex] == index.toDouble()
                              ? Colors.blue[300]
                              : Colors.blue[900],
                        ),
                        child: Text(
                          '${index}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _answers[_currentQuestionIndex] = (index + 4).toDouble();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          primary: _answers[_currentQuestionIndex] == (index + 4).toDouble()
                              ? Colors.blue[300]
                              : Colors.blue[900],
                        ),
                        child: Text(
                          '${index + 4}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ] else ...[
              Text("Select a value:", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              if (_answers[_currentQuestionIndex] != null)
                Text(
                  _answers[_currentQuestionIndex]!.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    question['range'][0].toString(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Expanded(
                    child: Slider(
                      value: _answers[_currentQuestionIndex] ?? question['range'][0].toDouble(),
                      min: question['range'][0].toDouble(),
                      max: question['range'][1].toDouble(),
                      divisions: _currentQuestionIndex == 0
                          ? (question['range'][1] - question['range'][0]) * 2  // Half units for sleep
                          : question['range'][1] - question['range'][0],     // Whole units for others
                      label: _answers[_currentQuestionIndex]?.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _answers[_currentQuestionIndex] = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    question['range'][1].toString(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ],
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    child: Text("Previous"),
                  )
                else
                  SizedBox.shrink(),
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < _questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BehaviorSummery(answers: _answers, questions: _questions),
                        ),
                      );
                    }
                  },
                  child: Text(_currentQuestionIndex == _questions.length - 1 ? "Finish" : "Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}