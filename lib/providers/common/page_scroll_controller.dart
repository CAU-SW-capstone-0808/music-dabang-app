import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class PageScrollController extends ScrollController {
  /// offset이 maxScrollExtent에 가까워졌을 때의 콜백
  void Function()? onEnd;

  /// 스크롤 방향에 대한 콜백
  void Function(ScrollDirection)? onDirection;

  /// offset에 대한 이벤트 콜백
  void Function(double)? onOffset;

  PageScrollController({
    this.onEnd,
    this.onDirection,
    this.onOffset,
  }) {
    addListener(_throttleEvent);
  }

  void _throttleEvent() {
    EasyThrottle.throttle(
      "paging-event-$hashCode",
      const Duration(milliseconds: 300),
      _handleScrollEvent,
      onAfter: _handleScrollEvent,
    );
  }

  void _handleScrollEvent() async {
    if (!hasClients) {
      return;
    }
    if (onEnd != null) {
      if (position.maxScrollExtent - offset < 300) {
        onEnd!.call();
      }
    }
    onOffset?.call(offset);
  }

  @override
  void dispose() {
    super.dispose();
    removeListener(_throttleEvent);
  }
}
