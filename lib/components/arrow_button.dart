import 'package:music_dabang/common/colors.dart';
import 'package:flutter/material.dart';

class ArrowButton extends StatefulWidget {
  final void Function()? onPressed;
  final Widget child;
  final double arrowSize;
  final Color arrowColor;

  /// 누르는 동안 화살표 이동됨 + 떼면 onPressed() 실행
  const ArrowButton({
    required this.onPressed,
    required this.child,
    this.arrowSize = 24.0,
    this.arrowColor = ColorTable.textInfoColor,
    Key? key,
  }) : super(key: key);

  @override
  State<ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton> {
  bool touching = false;

  Widget get arrowIcon => Icon(
        Icons.keyboard_arrow_right_rounded,
        size: widget.arrowSize,
        color: widget.arrowColor,
      );

  void onTouchDown(TapDownDetails details) => setState(() => touching = true);

  void onTouchUp(TapUpDetails details) {
    setState(() => touching = false);
    widget.onPressed?.call();
  }

  void onTouchCancel() => setState(() => touching = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTouchDown,
      onTapUp: onTouchUp,
      onTapCancel: onTouchCancel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: touching ? -widget.arrowSize / 5 : 0,
            top: 0,
            bottom: 0,
            child: arrowIcon,
          ),
          widget.child,
        ],
      ),
    );
  }
}
