import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/mandala_page/stress_meter.dart';
import '../../../constants/colors.dart';

class PredictionStressMandalaAndMusic extends StatelessWidget {
  final int stressLevel;

  const PredictionStressMandalaAndMusic({
    Key? key,
    required this.stressLevel,
  }) : super(key: key);

  String get _stressLabel {
    switch (stressLevel) {
      case 1:
        return 'High Level';
      case 2:
        return 'Moderate Level';
      case 3:
        return 'Mild Level';
      default:
        return 'Low Level';
    }
  }

  Color get _stressColor {
    switch (stressLevel) {
      case 1:
        return Colors.red.shade700;
      case 2:
        return Colors.orange.shade700;
      case 3:
        return Colors.amber.shade600;
      default:
        return AppColors.primary;
    }
  }

  String get _stressDescription {
    switch (stressLevel) {
      case 1:
        return 'Your stress levels are very high. Consider deep breathing exercises and professional support.';
      case 2:
        return 'You\'re experiencing significant stress. Try mindfulness meditation and physical activity.';
      case 3:
        return 'Your stress is at a manageable level. Keep practicing relaxation techniques.';
      default:
        return 'You\'re doing great! Maintain your healthy habits to stay balanced.';
    }
  }

  int get _meterValue {
    // Convert your 1-4 scale to the meter's expected scale if different
    return stressLevel == 1 ? 3 :
    stressLevel == 2 ? 2 :
    stressLevel == 3 ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.05,
            image: AssetImage("assets/bg_logo.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Stress Analysis Result',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the row
                  ],
                ),
                const SizedBox(height: 32),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stress level indicator
                        Text(
                          'Your Current Stress Level',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Visual meter
                        StressMeter(
                          stressLevel: _meterValue,
                          size: 180,
                        ),
                        const SizedBox(height: 32),

                        // Stress level label
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: _stressColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _stressColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$_stressLabel',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _stressColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Recommendation',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _stressDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Back To Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // TextButton(
                        //   onPressed: () {
                        //     // Add navigation to more info
                        //   },
                        //   child: Text(
                        //     'Learn more about stress levels',
                        //     style: TextStyle(
                        //       color: AppColors.primary,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}