import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stress_management/pages/main_pages/eye_analysis/stress_scale_quiz.dart';
import 'package:stress_management/pages/main_pages/mandala_page/prediction_and_history.dart';
import 'package:stress_management/pages/main_pages/music_page/categories_screen.dart';
import 'package:stress_management/pages/main_pages/quiz_page/quiz_screen.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../utils/camera_utils.dart';
import '../../../utils/permission_utils.dart';
import '../../../widgets/camera_bloc.dart';
import '../../camera_page/camera_page.dart';
import '../../navigator_page/mandala_navigator_page.dart';


class MandalaMusicHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.1,
            image: AssetImage("assets/bg_logo.png"), // Path to your image
            fit: BoxFit.contain, // Cover the entire screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mandala Arts & Music',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),


                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MandalaNavigator(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                  ),
                  child: Text(
                    'Mandala Arts',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoriesScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                  ),
                  child: const Text(
                    'Music Listening',
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PredictionAndHistory(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                  ),
                  child: const Text(
                    'Prediction And History',
                    style: TextStyle(fontSize: 18),
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
