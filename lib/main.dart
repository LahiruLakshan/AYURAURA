import 'package:colorgame/pages/navigator_page/navigator_page.dart';
import 'package:colorgame/pages/splash_screen/splash_screen.dart';
import 'package:colorgame/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MainProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the primary color swatch and overall app styling
        primarySwatch: Colors.green, // Green swatch for consistent theming
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Light green background
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32), // Dark green for headlines
          ),
          bodyText1: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF388E3C), // Medium green for body text
          ),
          button: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF66BB6A), // Button background green
            onPrimary: Colors.white, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded button corners
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF43A047), // AppBar green
          foregroundColor: Colors.white, // AppBar text color
          elevation: 0,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
