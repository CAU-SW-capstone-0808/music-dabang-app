import 'package:flutter/material.dart';

class OutlinedRoundButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? borderColor;
  final Widget child;

  const OutlinedRoundButton({
    this.onPressed,
    this.borderColor,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: BorderSide(
          color: borderColor ?? Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: child,
    );
  }
}
