import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../auth/profile_page.dart';
import '../behaviors/behaviors_quiz_home_page.dart';
import '../behaviors/chat_screen.dart';
import '../eye_analysis/eye_analysis_home_screen.dart';
import '../mandala_page/mandala_music_home_screen.dart';
import '../quiz_page/quiz_home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<String> _wellnessTips = [
    "Practice deep breathing for 5 minutes daily to reduce stress",
    "Aim for 7-9 hours of quality sleep each night",
    "Take short breaks every hour when working or studying",
    "Stay hydrated - drink at least 8 glasses of water daily",
    "Connect with loved ones regularly for emotional support"
  ];
  int _currentTipIndex = 0;

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

    // Rotate tips every 10 seconds
    Future.delayed(const Duration(seconds: 10), _rotateTips);
  }

  void _rotateTips() {
    if (mounted) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _wellnessTips.length;
      });
      Future.delayed(const Duration(seconds: 10), _rotateTips);
    }
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
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWellnessTipCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Evaluate Stress"),
                        _buildFeatureCard(
                          context,
                          'Evaluate\nStress',
                          'assets/home/check_stress.png',
                          Icons.remove_red_eye,
                          EyeAnalysisHomeScreen(),
                          fullWidth: true,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Relaxation Tools"),
                        _buildFeatureCard(
                          context,
                          'Mandala Arts\n& Music',
                          'assets/home/mandala.png',
                          Icons.palette,
                          MandalaMusicHomeScreen(),
                          fullWidth: true,
                        ),
                        const SizedBox(height: 24),
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
                            ),
                            _buildFeatureCard(
                              context,
                              'Recovery\nPrediction',
                              'assets/home/mood_quiz.png',
                              Icons.quiz,
                              QuizHomeScreen(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildFooter(),
                        const SizedBox(height: 80), // Space for chatbot button
                      ]),
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

  Widget _buildWellnessTipCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryGreen.withOpacity(0.8), kSecondaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Wellness Tip',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _wellnessTips[_currentTipIndex],
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: kPrimaryGreen,
                      ),
                    ),
                    Text(
                      'Ayuraura',
                      style: GoogleFonts.inter(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: kPrimaryGreen.withOpacity(0.2),
                  child: Icon(
                    Icons.account_circle,
                    color: kPrimaryGreen,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal stress management companion',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      String imagePath,
      IconData icon,
      Widget page, {
        bool fullWidth = false,
      }) {
    return SizedBox(
      width: fullWidth
          ? double.infinity
          : MediaQuery.of(context).size.width / 2 - 28,
      height: 160,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [kBackground, Color(0xFFCDECE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kPrimaryGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: kPrimaryGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: kPrimaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Ayuraura Research Project 24-25J-180',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChatBotButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen()),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryGreen,
        elevation: 4,
        icon: Image.asset('assets/home/panda.png', width: 36, height: 36),
        label: Text(
          'Mochi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}