import 'package:flutter/material.dart';

class StressMeter extends StatelessWidget {
  final int stressLevel; // 0-3 scale (0=low, 3=high)
  final double width;
  final double height;

  const StressMeter({
    Key? key,
    required this.stressLevel,
    this.width = 250,
    this.height = 40, required int size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define stress level colors and labels
    final levels = [
      {
        'color': const Color(0xFF4CAF50), // Green
        'label': 'Low',
        'icon': Icons.sentiment_very_satisfied,
      },
      {
        'color': const Color(0xFFFFC107), // Amber
        'label': 'Mild',
        'icon': Icons.sentiment_satisfied,
      },
      {
        'color': const Color(0xFFFF9800), // Orange
        'label': 'Moderate',
        'icon': Icons.sentiment_neutral,
      },
      {
        'color': const Color(0xFFF44336), // Red
        'label': 'High',
        'icon': Icons.sentiment_very_dissatisfied,
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title with current level indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              levels[stressLevel]['icon'] as IconData,
              color: levels[stressLevel]['color'] as Color,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Stress Level: ${levels[stressLevel]['label']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Visual meter
        Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            // color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: AnimatedContainer(
                    height: index < stressLevel
                        ? 40
                        : 43,
                    color: index <= stressLevel
                        ? levels[index]['color'] as Color
                        : Colors.transparent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,

                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index <= stressLevel
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Labels
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return Text(
                levels[index]['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: index <= stressLevel
                      ? levels[index]['color'] as Color
                      : Colors.grey.shade600,
                  fontWeight: index == stressLevel
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}