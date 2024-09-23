import 'package:flutter/material.dart';

// 바운싱 애니메이션을 적용할 수 있는 위젯 정의
class BouncingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleFactor;
  final void Function()? onPressed;

  const BouncingWidget({
    super.key,
    required this.child,
    this.scaleFactor = 0.98,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    // 스케일 애니메이션 설정 (바운싱 효과)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown, // 탭 시작
      onTapUp: _onTapUp, // 탭 끝
      onTapCancel: _onTapCancel, // 탭 취소
      child: ScaleTransition(
        scale: _scaleAnimation, // 애니메이션 적용
        child: widget.child,
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
