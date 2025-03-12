import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../providers/main_provider.dart';
import '../main_pages/home_page/home_page.dart';
import '../navigator_page/mandala_navigator_page.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // _navigateToHome();
  }



  // _navigateToHome() async {
  //   await Future.delayed(Duration(seconds: 3), () {});
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => HomePage()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {

    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    Future.delayed(Duration(seconds: 2), () {
      if (mainProvider.user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset('assets/logo.png'),
      ),
    );
  }
}
