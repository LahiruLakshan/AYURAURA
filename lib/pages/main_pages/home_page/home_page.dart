import 'package:stress_management/constants/colors.dart';
import 'package:stress_management/pages/image_list_page/image_grid_list_page.dart';
import 'package:stress_management/pages/main_pages/mandala_page/mandala_music_home_screen.dart';
import 'package:stress_management/pages/navigator_page/mandala_navigator_page.dart';
import 'package:stress_management/providers/main_provider.dart';
import 'package:stress_management/widgets/image_menu_item/image_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/profile_page.dart';
import '../behaviors/behaviors_quiz_home_page.dart';
import '../eye_analysis/eye_analysis_home_screen.dart';
import '../mandala_page/mandala_page.dart';
import '../quiz_page/quiz_home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false, // This hides the back button
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2D7231)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
            alignment: Alignment.center,
            child: Text(
              'AYURAURA',
              style: TextStyle(
                fontFamily: 'Chocolate',
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, size: 32, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.3,
            image: AssetImage("assets/bg_logo.png"), // Path to your image
            fit: BoxFit.contain, // Cover the entire screen
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: [
                      _buildMenuButton(context, 'Mandala Arts\n &\n Music', Icons.color_lens, MandalaMusicHomeScreen()),
                      _buildMenuButton(context, 'Quiz Page', Icons.quiz, QuizHomeScreen()),
                      _buildMenuButton(context, 'Eye Analysis', Icons.remove_red_eye, EyeAnalysisHomeScreen()),
                      _buildMenuButton(context, 'Behaviors Quiz', Icons.psychology, BehaviorsQuizHomePage()),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Powered by Team AYURAURA',
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2D7231)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}