import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stress_management/pages/main_pages/eye_analysis/stress_scale_quiz.dart';
import 'package:stress_management/pages/main_pages/mandala_page/prediction_stress_mandala_and_music.dart';
import 'package:stress_management/pages/navigator_page/music_navigator_page.dart';
import 'package:stress_management/pages/main_pages/quiz_page/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../navigator_page/mandala_navigator_page.dart';

class MandalaMusicHomeScreen extends StatefulWidget {
  @override
  _MandalaMusicHomeScreenState createState() => _MandalaMusicHomeScreenState();
}

class _MandalaMusicHomeScreenState extends State<MandalaMusicHomeScreen> {
  bool _isLoading = false;
  Map<String, dynamic> userData = <String, dynamic>{};

  String getComplexityValue(String type) {
    switch (type.toLowerCase()) {
      case 'simple':
        return "3 (Simple)";
      case 'medium':
        return "2 (Medium)";
      case 'complex':
        return "1 (Complex)";
      default:
        return "1 (Complex)";
    }
  }

  int getMusicTypeValue(String type) {
    switch (type.toLowerCase()) {
      case 'Deep':
        return 1;
      case 'Gregorian':
        return 2;
      case 'Tibetan':
        return 3;
      case 'Ambient':
        return 4;
      case 'Soft':
        return 5;
      case 'Alpha':
        return 6;
      case 'Nature':
        return 7;
      case 'LoFI':
        return 8;
      default:
        return 1;
    }
  }

  Future<void> predictStress() async {
    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is currently logged in.");
        return null;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        userData = userDoc.data() as Map<String, dynamic>;
      }

      final listeningSnapshot = await FirebaseFirestore.instance
          .collection('listening_logs')
          .orderBy('date_time_listened', descending: true)
          .limit(1)
          .get();

      final coloringSnapshot = await FirebaseFirestore.instance
          .collection('coloring_logs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (listeningSnapshot.docs.isEmpty || coloringSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete both coloring and listening activities first.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      var listeningData = listeningSnapshot.docs.first.data() as Map<String, dynamic>;
      var coloringData = coloringSnapshot.docs.first.data() as Map<String, dynamic>;

      print("-------listeningData : $listeningData");
      print("---------coloringData : $coloringData");
      final url = Uri.parse(AppConstants.BASE_URL_MANDALA_MUSIC);
      final payload = {
        "Age": userData["age"],
        "Gender": userData["gender"],
        "Mandala Design Pattern": getComplexityValue(coloringData['image_type']),
        "Mandala Colors Used": coloringData['color_palette_id'],
        "Mandala Time Spent": coloringData['color_duration']/60,
        "Music Type": getMusicTypeValue(listeningData['track_title'].split(" ")[0]),
        "Music Time Spent": listeningData['time_listened']/60,
        "Total_Time": coloringData['color_duration'] + listeningData['time_listened']
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _isLoading = false);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PredictionStressMandalaAndMusic(
                stressLevel: data["Stress Level"]),
          ),
        );
      }
    } catch (e) {
      print("Error predicting stress: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error predicting stress. Please try again.')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildActivityCards(),
              const SizedBox(height: 32),
              _buildHowItWorks(),
              const SizedBox(height: 32),
              _buildStressCheckButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Art & Music Therapy',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Combine mandala coloring and music for stress relief',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCards() {
    return Column(
      children: [
        _buildActivityCard(
          icon: Icons.palette,
          title: 'Mandala Coloring',
          description: 'Relax by coloring beautiful mandala patterns',
          color: Colors.purple.shade50,
          iconColor: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MandalaNavigator()),
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          icon: Icons.music_note,
          title: 'Meditation Music',
          description: 'Calm your mind with therapeutic sounds',
          color: Colors.blue.shade50,
          iconColor: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MusicNavigator()),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'How It Works',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Complete a mandala coloring session'),
          _buildStep('2', 'Listen to meditation music'),
          _buildStep('3', 'Get your stress level analysis'),
          const SizedBox(height: 8),
          Text(
            'The combination of art and music therapy provides powerful stress relief benefits',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressCheckButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : predictStress,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Check My Stress Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
