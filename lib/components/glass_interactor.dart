import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';

/// 누를 때 배경이 글래스모피즘 적용됨.
class GlassMorphing extends StatefulWidget {
  final Widget background;
  final Duration duration;
  final Widget child;
  final void Function()? onPressed;

  const GlassMorphing({
    super.key,
    required this.background,
    this.duration = const Duration(milliseconds: 300),
    required this.child,
    this.onPressed,
  });

  @override
  State<GlassMorphing> createState() => _GlassMorphingState();
}

class _GlassMorphingState extends State<GlassMorphing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  // 탭 시작 시 애니메이션 실행
  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  // 탭 끝났을 때 애니메이션 reset
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  // 탭 취소 시 애니메이션 되돌리기
  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    // 투명도 애니메이션 설정
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown, // 탭 시작
      onTapUp: _onTapUp, // 탭 끝
      onTapCancel: _onTapCancel, // 탭 취소
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(child: widget.background),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                var borderRadius = BorderRadius.circular(0.0);
                var foregroundColor =
                    Colors.white.withOpacity(_opacityAnimation.value);
                if ((_opacityAnimation.value - 1).abs() < 0.01) {
                  return ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: borderRadius,
                    child: Container(
                      decoration: BoxDecoration(
                        color: foregroundColor,
                        border: Border.all(
                          color: foregroundColor,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: borderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 16,
                        sigmaY: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: foregroundColor,
                          border: Border.all(
                            color: foregroundColor,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 애니메이션 컨트롤러 해제
    _controller.dispose();
    super.dispose();
  }
}
