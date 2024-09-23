import 'package:music_dabang/common/colors.dart';
import 'package:flutter/material.dart';

/// 너비가 넓은 elevated button
/// 기본 색상은 ColorTable.enabledColor
class WideButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? disabledBorderColor;
  final double? width;
  final double? height;
  final Widget child;

  const WideButton({
    this.onPressed,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.disabledBorderColor,
    this.width,
    this.height = 44.0,
    required this.child,
    Key? key,
  }) : super(key: key);

  factory WideButton.blue({
    void Function()? onPressed,
    double? width,
    double height = 44.0,
    required Widget child,
  }) =>
      WideButton(
        onPressed: onPressed,
        backgroundColor: ColorTable.kPrimaryColor,
        disabledForegroundColor: ColorTable.textInfoColor,
        disabledBackgroundColor: const Color(0xFFF9F9F9),
        disabledBorderColor: ColorTable.border2,
        width: width,
        height: height,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor ?? ColorTable.enabledColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              disabledBackgroundColor ?? ColorTable.textGrey,
          disabledForegroundColor: disabledForegroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: onPressed != null
                  ? Colors.transparent
                  : (disabledBorderColor ?? Colors.transparent),
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        child: child,
      ),
    );
  }
}
