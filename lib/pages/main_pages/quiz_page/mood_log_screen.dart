import 'package:stress_management/pages/main_pages/quiz_page/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../mandala_page/mandala_music_home_screen.dart';
import './daily_reminder_screen.dart';

class MoodLogScreen extends StatefulWidget {
  final int predictedDays;
  const MoodLogScreen({Key? key, required this.predictedDays}) : super(key: key);

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  @override
  Widget build(BuildContext context) {
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
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Predicted Recovery Days',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${widget.predictedDays}",
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'You are just ${widget.predictedDays} days away from a better you! 🎯',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Please note: The number of days shown is only an approximate estimation and may vary based on individual progress and circumstances.",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Tips Section
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Wellness Journey 🌟',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTipItem(
                          icon: Icons.palette_outlined,
                          text: 'Complete Mandala activities for inner peace',
                        ),
                        _buildTipItem(
                          icon: Icons.music_note_outlined,
                          text: 'Listen to soothing music for mental clarity',
                        ),
                        _buildTipItem(
                          icon: Icons.track_changes_outlined,
                          text: 'Track your progress consistently',
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgressScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.bar_chart_outlined, size: 24),
                      label: Text(
                        'View Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MandalaMusicHomeScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.start_outlined, size: 20),
                          label: Text('Begin Journey'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DailyReminderScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.notifications_outlined, size: 20),
                          label: Text('Set Reminder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8FFF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}