import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/consts.dart' as c;

class LogoTitle extends StatelessWidget {
  final Color color;
  final double fontSize;

  const LogoTitle({
    super.key,
    this.color = ColorTable.kPrimaryColor,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      c.serviceName,
      maxLines: 1,
      style: TextStyle(
        fontFamily: 'ChangwonDangamAsac',
        fontSize: fontSize / MediaQuery.of(context).textScaler.scale(1),
        fontWeight: FontWeight.bold,
        color: color,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
