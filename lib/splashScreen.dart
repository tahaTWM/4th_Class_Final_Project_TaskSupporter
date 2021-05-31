import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import './login/selectIP.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Container(
        child: Lottie.network(
            "https://assets4.lottiefiles.com/packages/lf20_lQfkLu.json"),
      ),
      nextScreen: SelectIP(),

      splashIconSize: MediaQuery.of(context).size.width > 400 ? 600 : 400,
      duration: 6500,
      // pageTransitionType: PageTransitionType.rightToLeft,
      centered: true,
    );
  }
}
