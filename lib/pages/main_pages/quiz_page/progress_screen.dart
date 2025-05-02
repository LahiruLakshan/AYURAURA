import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';

class ProgressScreen extends StatefulWidget {
  ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<DailyMetrics> barChartData = [];
  Map<String, double> weeklyChanges = {
    'stress': 0.0,
    'happiness': 0.0,
    'calmness': 0.0,
    'energy': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  void _calculateWeeklyChanges() {
    if (barChartData.length < 2) return;

    var latest = barChartData.last;
    var previous = barChartData[barChartData.length - 2];

    weeklyChanges['stress'] = ((latest.stress - previous.stress) / previous.stress * 100);
    weeklyChanges['happiness'] = ((latest.happiness - previous.happiness) / previous.happiness * 100);
    weeklyChanges['calmness'] = ((latest.calmness - previous.calmness) / previous.calmness * 100);
    weeklyChanges['energy'] = ((latest.energy - previous.energy) / previous.energy * 100);
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
      _calculateWeeklyChanges();
    });
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24),
                  _buildWeeklyOverview(),
                  SizedBox(height: 24),
                  _buildChartSection(),
                  SizedBox(height: 24),
                  _buildInsightCard(),
                  SizedBox(height: 24),
                  _buildBackButton(context),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Emotional Progress 📈",
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Track your journey to better mental well-being",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Overview",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStatCard(
                  "Stress Level",
                  "${weeklyChanges['stress']?.toStringAsFixed(1)}% ${weeklyChanges['stress']! >= 0 ? '↑' : '↓'}",
                  Icons.trending_down,
                  weeklyChanges['stress']! >= 0,
                  isStressCard: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  "Happiness",
                  "${weeklyChanges['happiness']?.toStringAsFixed(1)}% ${weeklyChanges['happiness']! >= 0 ? '↑' : '↓'}",
                  Icons.sentiment_satisfied,
                  weeklyChanges['happiness']! >= 0,
                  isStressCard: false,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  "Calmness",
                  "${weeklyChanges['calmness']?.toStringAsFixed(1)}% ${weeklyChanges['calmness']! >= 0 ? '↑' : '↓'}",
                  Icons.spa,
                  weeklyChanges['calmness']! >= 0,
                  isStressCard: false,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  "Energy",
                  "${weeklyChanges['energy']?.toStringAsFixed(1)}% ${weeklyChanges['energy']! >= 0 ? '↑' : '↓'}",
                  Icons.bolt,
                  weeklyChanges['energy']! >= 0,
                  isStressCard: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isPositive, {bool isStressCard = false}) {
    Color getColor(bool positive) {
      if (isStressCard) {
        return positive ? Color(0xFF047857) : Colors.red;
      }
      return positive ? Color(0xFF047857) : Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFE8FFF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF047857).withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: getColor(isPositive),
            size: 20
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: getColor(isPositive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Emotional Metrics",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 300,
            child: charts.BarChart(
              _createBarChartSeries(),
              animate: true,
              barGroupingType: charts.BarGroupingType.grouped,
              defaultRenderer: charts.BarRendererConfig(
                cornerStrategy: const charts.ConstCornerStrategy(30),
              ),
              domainAxis: charts.OrdinalAxisSpec(
                renderSpec: charts.SmallTickRendererSpec(
                  labelRotation: 45,
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                ),
              ),
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: charts.StaticNumericTickProviderSpec(
                  [
                    charts.TickSpec(0, label: '0'),
                    charts.TickSpec(1, label: '1'),
                    charts.TickSpec(2, label: '2'),
                    charts.TickSpec(3, label: '3'),
                    charts.TickSpec(4, label: '4'),
                    charts.TickSpec(5, label: '5'),
                  ],
                ),
                renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                  lineStyle: charts.LineStyleSpec(
                    color: charts.MaterialPalette.gray.shade300,
                  ),
                ),
              ),
              behaviors: [
                charts.SeriesLegend(
                  position: charts.BehaviorPosition.bottom,
                  desiredMaxColumns: 2,
                  entryTextStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                ),
                charts.ChartTitle(
                  'Days',
                  behaviorPosition: charts.BehaviorPosition.bottom,
                  titleStyleSpec: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                  titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                ),
                charts.ChartTitle(
                  'Level',
                  behaviorPosition: charts.BehaviorPosition.start,
                  titleStyleSpec: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                  titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    String insightText = _generateInsight();
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF047857),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF047857).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                "Today's Insight",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            insightText,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _generateInsight() {
    if (barChartData.isEmpty) return "Start logging your emotions to get personalized insights!";

    var latest = barChartData.last;
    var insights = [];

    if (latest.stress < 3) {
      insights.add("Your stress levels are high. Try these proven stress-relief activities in the app: "
          "🎨 Color some mandala patterns to calm your mind and "
          "🎵 Listen to soothing meditation music in our music player.");
    } else if (latest.stress >= 4) {
      insights.add("Great job managing your stress levels! Keep using the mandala coloring and music features to maintain this balance.");
    }

    if (latest.happiness > 3) {
      insights.add("You're maintaining good happiness levels. Keep up the positive attitude!");
    }

    if (latest.calmness > 3) {
      insights.add("Your calmness levels are good. The meditation seems to be working!");
    } else {
      insights.add("Try some breathing exercises while coloring mandalas to improve calmness.");
    }

    if (latest.energy > 3) {
      insights.add("Your energy levels are great! Make the most of your productive state.");
    } else if (latest.energy < 3) {
      insights.add("Your energy seems low. Try listening to some uplifting music from our playlist or engage in mindful mandala coloring.");
    }

    return insights.join(" ");
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF047857),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Color(0xFF047857).withOpacity(0.3),
        ),
        child: Text(
          'Back to Dashboard',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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