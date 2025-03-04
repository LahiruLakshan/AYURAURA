import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:stress_management/pages/auth/profile_page.dart';
import 'package:stress_management/pages/main_pages/home_page/home_page.dart';
import 'package:stress_management/pages/navigator_page/navigator_page.dart';
import 'package:stress_management/pages/splash_screen/splash_screen.dart';
import 'package:stress_management/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:stress_management/pages/auth/login_screen.dart';
import 'package:stress_management/pages/auth/signup_screen.dart';
import 'package:stress_management/pages/auth/forgot_password_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase App Check
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MainProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Stress Management',
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
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/profile': (context) => ProfilePage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomePage(), // Assuming NavigatorPage is your home page
      },
    );
  }
}
