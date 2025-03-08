import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BehaviorSummery extends StatefulWidget {
  final Map<int, double> answers;
  final List<Map<String, dynamic>> questions;

  const BehaviorSummery({
    Key? key,
    required this.answers,
    required this.questions,
  }) : super(key: key);

  @override
  State<BehaviorSummery> createState() => _BehaviorSummeryState();
}

class _BehaviorSummeryState extends State<BehaviorSummery> {
  late Future<Map<String, dynamic>> _predictionFuture;
  final String _backendUrl = 'https://f9b3-35-245-17-224.ngrok-free.app/predict';

  @override
  void initState() {
    super.initState();
    _predictionFuture = _fetchPrediction();
  }

  Future<Map<String, dynamic>> _fetchPrediction() async {
    final parameterNames = [
      'avg_sleep_hours_per_night',
      'avg_exercise_days_per_week',
      'avg_work_or_study_hours_per_week',
      'avg_screen_hours_per_day',
      'social_interaction_quality_rating',
      'diet_healthiness_rating',
      'smoking_drinking_habits_rating',
      'avg_recreational_hours_per_week',
    ];

    final Map<String, dynamic> requestBody = {};
    for (int i = 0; i < parameterNames.length; i++) {
      requestBody[parameterNames[i]] = widget.answers[i]?.toDouble() ?? 0.0;
    }

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get prediction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary & Prediction')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _predictionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorSection(snapshot.error.toString());
          }

          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> prediction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnswersSection(),
          const SizedBox(height: 24),
          _buildPredictionSection(prediction),
        ],
      ),
    );
  }

  Widget _buildAnswersSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Your Answers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.questions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                title: Text(widget.questions[index]['text']),
                trailing: Text(
                  widget.answers[index]?.toStringAsFixed(1) ?? '0.0',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionSection(Map<String, dynamic> prediction) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Stress Prediction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${prediction['predicted_class']}',
              style: TextStyle(
                fontSize: 18,
                color: prediction['predicted_class'] == 'Stress'
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildProbabilityIndicator(
              label: 'No Stress',
              value: prediction['probabilities']['No Stress'],
              color: Colors.green,
            ),
            _buildProbabilityIndicator(
              label: 'Stress',
              value: prediction['probabilities']['Stress'],
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityIndicator({
    required String label,
    required String value,
    required Color color,
  }) {
    final percentage = double.parse(value.replaceAll('%', ''));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value', style: TextStyle(fontSize: 16, color: color)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Failed to get prediction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _predictionFuture = _fetchPrediction()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}