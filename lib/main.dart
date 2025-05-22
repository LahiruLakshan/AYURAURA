import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:stress_management/pages/auth/profile_page.dart';
import 'package:stress_management/pages/main_pages/home_page/home_page.dart';
import 'package:stress_management/pages/navigator_page/mandala_navigator_page.dart';
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
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Colors.indigo.shade400,
          tertiary: Colors.orange.shade600,
          surfaceVariant: Colors.grey.shade100,
        ),
        useMaterial3: true,
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
