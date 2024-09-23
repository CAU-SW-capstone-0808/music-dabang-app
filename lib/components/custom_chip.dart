import 'package:music_dabang/common/colors.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final bool value;
  final void Function() onPressed;

  const CustomChip({
    required this.label,
    required this.value,
    required this.onPressed,
    super.key,
  });

  static const onLabelStyle = TextStyle(
    color: Colors.white,
    height: 1.25,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static const offLabelStyle = TextStyle(
    color: Colors.black,
    height: 1.25,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  TextStyle get labelStyle => value ? onLabelStyle : offLabelStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(100),
      // splashColor: value ? ColorTable.kPrimaryColor.withOpacity(0.5) : null,
      // highlightColor: value ? ColorTable.kPrimaryColor : null,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: value ? ColorTable.kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: ColorTable.stroke, width: 1.0),
        ),
        child: Center(
          child: Text(
            label,
            style: labelStyle,
          ),
        ),
      ),
    );
  }
}
