import 'package:music_dabang/common/colors.dart';
import 'package:flutter/material.dart';

// 큰 글씨 + 검정
class TitleDescriptionText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final bool center;

  const TitleDescriptionText(
    this.text, {
    this.fontSize = 24.0,
    this.center = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        color: ColorTable.enabledColor,
        fontFamily: 'Inter',
      ),
    );
  }
}
