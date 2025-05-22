import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';

class WeeklyOverview extends StatefulWidget {
  const WeeklyOverview({Key? key}) : super(key: key);

  @override
  State<WeeklyOverview> createState() => _WeeklyOverviewState();
}



class _WeeklyOverviewState extends State<WeeklyOverview> {
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



  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildWeeklyOverview(),
    );
  }

  Widget _buildWeeklyOverview() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weekly Overview",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
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
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

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
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isPositive, {bool isStressCard = false}) {
    Color getColor(bool positive) {
      if (isStressCard) {
        return positive ? Color(0xFF2E7D32) : Colors.red;
      }
      return positive ? Color(0xFF2E7D32) : Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade100,
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