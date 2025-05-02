import 'package:stress_management/pages/main_pages/quiz_page/quiz_screen.dart';
import 'package:flutter/material.dart';

// App colors constants similar to the ones in your project
class AppColors {
  static const Color background = Colors.white;
  static const Color primary = Color(0xFF047857);
  static const Color secondary = Color(0xFF111827);
  static const Color accent = Color(0xFF047857);
}
// Note: Removed the duplicate AppColors class since it's already imported from colors.dart

class QuizHomeScreen extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8FFF5),
              AppColors.accent.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildInfoCard(
                    "Your progress matters! Let's see how you are feeling and predict your path to a stress-free mind. 🌿",
                    AppColors.accent,
                  ),
                  const SizedBox(height: 24),
                  _buildMoodCard(),
                  const SizedBox(height: 20),
                  _buildActionButton(context),
                  const SizedBox(height: 20),
                  _buildInsightCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
          'Hey there! 👋',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let us check in on your journey to a stress-free life',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        "Take this quick quiz to predict how many days it might take you to feel stress-free!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: textColor,
        ),
       ),
   );
  }

  Widget _buildMoodCard() {
    final emotions = [
      {'icon': Icons.wb_sunny_rounded, 'label': 'Great', 'color': const Color(0xFFF59E0B), 'bgColor': const Color(0xFFFEF3C7)},
      {'icon': Icons.sentiment_satisfied_rounded, 'label': 'Good', 'color': const Color(0xFF047857), 'bgColor': const Color(0xFFD1FAE5)},
      {'icon': Icons.cloud_rounded, 'label': 'Okay', 'color': const Color(0xFF60A5FA), 'bgColor': const Color(0xFFDBEAFE)},
      {'icon': Icons.sentiment_dissatisfied_rounded, 'label': 'Not Great', 'color': const Color(0xFFF87171), 'bgColor': const Color(0xFFFEE2E2)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let AyurAura guide you toward a stress-free life.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your emotions, energy levels, and daily activities to get personalized insights and guidance.',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: emotions.length,
            itemBuilder: (context, index) {
              final emotion = emotions[index];
              return _buildEmotionButton(
                icon: emotion['icon'] as IconData,
                label: emotion['label'] as String,
                color: emotion['color'] as Color,
                bgColor: emotion['bgColor'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF047857),  // Primary button background
        foregroundColor: Colors.white,       // Primary button text
        elevation: 8,
        shadowColor: Color(0xFF047857).withOpacity(0.4),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        "Let's find out! Log Your Answers Now",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF047857).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFE8FFF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: Color(0xFF047857),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Did you know?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Regular stress assessment can help you understand and manage your mental well-being better.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}