import 'package:flutter/material.dart';
import 'package:stress_management/pages/main_pages/mandala_page/stress_meter.dart'; // Ensure the correct import path
import '../../../constants/colors.dart'; // Ensure the correct import path

class PredictionStressMandalaAndMusic extends StatefulWidget {
  final int stressLevel;


  const PredictionStressMandalaAndMusic({Key? key, required this.stressLevel}) : super(key: key);

  @override
  _PredictionStressMandalaAndMusicState createState() =>
      _PredictionStressMandalaAndMusicState();
}

class _PredictionStressMandalaAndMusicState
    extends State<PredictionStressMandalaAndMusic> {
  // You can add state variables here if needed
  int stressLevel = 0; // Example state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Current Stress Level based on your activity performance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 40),
              StressMeter(stressLevel: widget.stressLevel), // Use the state variable
              const SizedBox(height: 40),
              Text(
                widget.stressLevel < 1 ? "LOW LEVEL" : "HIGH LEVEL", // Example logic
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}