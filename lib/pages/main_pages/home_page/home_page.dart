import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_management/pages/auth/profile_page.dart';

import 'package:stress_management/pages/main_pages/eye_analysis/eye_analysis_home_screen.dart';
import 'package:stress_management/pages/main_pages/mandala_page/mandala_music_home_screen.dart';
import 'package:stress_management/pages/main_pages/behaviors/chat_screen.dart';
import 'package:stress_management/pages/main_pages/quiz_page/quiz_home_screen.dart';
import 'package:stress_management/pages/main_pages/behaviors/behaviors_quiz_home_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildSectionTitle("Quick Access"),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildFeatureCard(
                              context,
                              'Will I\nBe Stressed?',
                              'assets/home/behavior_quiz.png',
                              Icons.psychology,
                              BehaviorsQuizHomePage(),
                              [Colors.green.shade500, Colors.green.shade300],
                            ),
                            _buildFeatureCard(
                              context,
                              'Recovery\nPrediction',
                              'assets/home/mood_quiz.png',
                              Icons.quiz,
                              QuizHomeScreen(),
                              [Colors.green.shade500, Colors.green.shade300],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Relaxation Tools"),
                        _buildFeatureCard(
                          context,
                          'Mandala Arts\n& Music',
                          'assets/home/mandala.png',
                          Icons.palette,
                          MandalaMusicHomeScreen(),
                          [Colors.green.shade500, Colors.green.shade300],
                          fullWidth: true,
                        ),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Evaluate Stress"),
                        _buildFeatureCard(
                          context,
                          'Evaluate\nStress',
                          'assets/home/check_stress.png',
                          Icons.remove_red_eye,
                          EyeAnalysisHomeScreen(),
                          [Colors.green.shade500, Colors.green.shade300],
                          fullWidth: true,
                        ),
                        const SizedBox(height: 30),
                        _buildFooter(),
                        const SizedBox(height: 80), // for chatbot space
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildChatBotButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Text(
                    'Ayuraura',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                ),
                icon: const Icon(
                  Icons.account_circle,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal stress management companion',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      String imagePath,
      IconData icon,
      Widget page,
      List<Color> gradientColors, {
        bool fullWidth = false,
      }) {
    return SizedBox(
      width: fullWidth ? double.infinity : MediaQuery.of(context).size.width / 2 - 28,
      height: 160,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: const Text(
        'Ayuraura Research Project 24-25J-180',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChatBotButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset('assets/home/panda.png', width: 36, height: 36),
              const SizedBox(width: 8),
              const Text(
                'Chat with\nMochi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF424242)),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
