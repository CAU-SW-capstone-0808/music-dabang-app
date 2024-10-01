import 'dart:math';

import 'package:flutter/rendering.dart';

abstract class ColorTable {
  // static const kPrimaryColor = Color(0xFF2639E5);
  // static const kPrimaryColor = Color(0xFFFF8445);
  static const kPrimaryColor = Color(0xFFFF6131);
  static const kakaoYellow = Color(0xFFFEE500);
  static const clearIconColor = Color(0xFFC9C9C9);
  static const hintTextColor = Color(0xFFD2D8D8);
  static const okGreenColor = Color(0xFF55B782);
  static const inputCursorColor = Color(0xFF4B6AEA);
  static const textGrey = Color(0xFF87898A);
  static const inputBorderColor = Color(0xFFB1B9C0); // underlined input
  static const enabledColor = Color(0xFF0F1319);
  static const textInfoColor = Color(0xFF86898C);
  static const border2 = Color(0xFFE3E5E6);
  static const red = Color(0xFFFE537B);
  static const red2 = Color(0xFFE03C3A);
  static const sliderColor = Color(0xFFFF8445);
  static const mRed = Color(0xFFD82A75); // 뮤직다방 레드
  static const palePink = Color(0xFFFCE7F3);
  static const stroke = Color(0xFFD0D0D0);
  static const backGrey = Color(0xFFF5F5F5);
  static const purple = Color(0xFF8453E3);
  static const bottomNavBlack = Color(0xFF121212);
  static const skyBlue = Color(0xFF009FFF);
  static const chipGrey = Color(0xFFEFEFEF);
  static const iconBlack = Color(0xFF303030);

  /// 45도 그래디언트
  static const blueGradient45 = LinearGradient(
    colors: [
      Color(0xFF2639E5),
      Color(0xFF6776FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [
      Color(0xFF6A31DA),
      Color(0xFF9D74EC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const shinyGradient = LinearGradient(
    colors: [
      Color(0x66FFFFFF),
      Color(0x11FFFFFF),
      Color(0x11FFFFFF),
      Color(0x66FFFFFF),
    ],
    stops: [0.0, 0.22, 0.75, 1.0],
    transform: GradientRotation(40 * pi / 180),
  );
}
