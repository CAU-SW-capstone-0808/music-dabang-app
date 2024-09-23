import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/logo_title.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = 'splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorTable.kPrimaryColor,
      body: Center(
        child: LogoTitle(
          color: Colors.white,
          fontSize: 72,
        ),
      ),
    );
  }
}
