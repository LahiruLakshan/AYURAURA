import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/colors.dart';

class ProgressScreen extends StatefulWidget {
  ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<DailyMetrics> barChartData = [];

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  Future<void> _fetchMoodData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime today = DateTime.now();
    DateTime lastWeek = today.subtract(Duration(days: 7));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('mood_logs')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: lastWeek.toIso8601String().split("T")[0])
        .orderBy('date', descending: false)
        .get();

    List<DailyMetrics> fetchedData = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return DailyMetrics(
        day: data['date'].toString().split('-').last, // Extracting day from YYYY-MM-DD
        stress: double.parse(data['stress']),
        happiness: double.parse(data['happiness']),
        calmness: double.parse(data['calmness']),
        energy: double.parse(data['energy']),
      );
    }).toList();

    setState(() {
      barChartData = fetchedData;
    });
  }
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              _buildBarChartCard(),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Daily Emotional Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: charts.BarChart(
                _createBarChartSeries(),
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
                domainAxis: const charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 45,
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 10,
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                ),
                primaryMeasureAxis: const charts.NumericAxisSpec(
                  tickProviderSpec: charts.StaticNumericTickProviderSpec(
                    [
                      charts.TickSpec(0, label: '0'),
                      charts.TickSpec(1),
                      charts.TickSpec(2),
                      charts.TickSpec(3),
                      charts.TickSpec(4),
                      charts.TickSpec(5, label: '5'),
                    ],
                  ),
                  renderSpec: charts.GridlineRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      fontSize: 12,
                      color: charts.MaterialPalette.black,
                    ),
                    lineStyle: charts.LineStyleSpec(
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                ),
                behaviors: [
                  charts.ChartTitle('Days',
                      titleStyleSpec: const charts.TextStyleSpec(fontSize: 14),
                      behaviorPosition: charts.BehaviorPosition.bottom),
                  charts.ChartTitle('Intensity',
                      titleStyleSpec: const charts.TextStyleSpec(fontSize: 14),
                      behaviorPosition: charts.BehaviorPosition.start),
                  charts.SeriesLegend(
                    position: charts.BehaviorPosition.bottom,
                    desiredMaxColumns: 4,
                    entryTextStyle: charts.TextStyleSpec(
                      fontSize: 12,
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<DailyMetrics, String>> _createBarChartSeries() {
    return [
      charts.Series<DailyMetrics, String>(
        id: 'Stress',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.stress),
        domainFn: (DailyMetrics metrics, _) => metrics.day,
        measureFn: (DailyMetrics metrics, _) => metrics.stress,
        data: barChartData,
      ),
      charts.Series<DailyMetrics, String>(
        id: 'Happiness',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.happiness),
        domainFn: (DailyMetrics metrics, _) => metrics.day,
        measureFn: (DailyMetrics metrics, _) => metrics.happiness,
        data: barChartData,
      ),
      charts.Series<DailyMetrics, String>(
        id: 'Calmness',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.calmness),
        domainFn: (DailyMetrics metrics, _) => metrics.day,
        measureFn: (DailyMetrics metrics, _) => metrics.calmness,
        data: barChartData,
      ),
      charts.Series<DailyMetrics, String>(
        id: 'Energy',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.energy),
        domainFn: (DailyMetrics metrics, _) => metrics.day,
        measureFn: (DailyMetrics metrics, _) => metrics.energy,
        data: barChartData,
      ),
    ];
  }
}

Widget _buildBackButton(BuildContext context) {
  return Center(
    child: ElevatedButton.icon(
      icon: const Icon(Icons.arrow_back, size: 20),
      label: const Text('Back to Dashboard'),
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        primary: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}

class DailyMetrics {
  final String day;
  final double stress;
  final double happiness;
  final double calmness;
  final double energy;

  DailyMetrics({
    required this.day,
    required this.stress,
    required this.happiness,
    required this.calmness,
    required this.energy,
  });
}


class DayMetrics {
  final String day;
  final double happiness;
  final double calmness;

  DayMetrics({
    required this.day,
    required this.happiness,
    required this.calmness,
  });
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Emotional Analytics 📊",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Visualizing your mood patterns and stress levels",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(AppColors.stress, 'Stress'),
            _buildLegendItem(AppColors.happiness, 'Happiness'),
            _buildLegendItem(AppColors.calmness, 'Calmness'),
            _buildLegendItem(AppColors.energy, 'Energy'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}