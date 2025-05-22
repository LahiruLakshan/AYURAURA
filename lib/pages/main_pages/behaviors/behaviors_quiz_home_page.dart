import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/behaviors/behavior_quiz_screen.dart';
import '../../../constants/colors.dart';

class BehaviorsQuizHomePage extends StatelessWidget {
  const BehaviorsQuizHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildBehaviorGrid(),
              const SizedBox(height: 32),
              _buildStressAssessmentCard(context),
              const SizedBox(height: 24),
              _buildWellnessTips(),
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
          'Behavior Tracker',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor daily habits that impact your stress levels',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorGrid() {
    final behaviors = [
      {
        'icon': Icons.nightlight_round,
        'label': 'Sleep',
        'color': Colors.blue.shade400,
        'bgColor': Colors.blue.shade50
      },
      {
        'icon': Icons.directions_run,
        'label': 'Exercise',
        'color': Colors.green.shade400,
        'bgColor': Colors.green.shade50
      },
      {
        'icon': Icons.work_outline,
        'label': 'Work',
        'color': Colors.amber.shade600,
        'bgColor': Colors.amber.shade50
      },
      {
        'icon': Icons.phone_iphone,
        'label': 'Screen Time',
        'color': Colors.red.shade400,
        'bgColor': Colors.red.shade50
      },
      {
        'icon': Icons.restaurant,
        'label': 'Nutrition',
        'color': Colors.purple.shade400,
        'bgColor': Colors.purple.shade50
      },
      {
        'icon': Icons.people_outline,
        'label': 'Social',
        'color': Colors.teal.shade400,
        'bgColor': Colors.teal.shade50
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: behaviors.length,
      itemBuilder: (context, index) {
        final behavior = behaviors[index];
        return _BehaviorCard(
          icon: behavior['icon'] as IconData,
          label: behavior['label'] as String,
          color: behavior['color'] as Color,
          bgColor: behavior['bgColor'] as Color,
        );
      },
    );
  }

  Widget _buildStressAssessmentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Stress Risk Assessment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Take a quick 2-minute assessment to understand your current stress risk factors',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BehaviorsQuizScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Assessment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Wellness Tip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Consistent sleep patterns can reduce stress by up to 40%. '
                'Try going to bed and waking up at the same time daily.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _BehaviorCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}