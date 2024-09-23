import 'package:riverpod/riverpod.dart';

/// 0.0 ~ 1.0
final musicPlayerSizeProvider =
    StateNotifierProvider<MusicPlayerSizeStateNotifier, double>(
  (ref) => MusicPlayerSizeStateNotifier(),
);

/// 0 ~ device height
final musicPlayerHeightProvider =
    StateNotifierProvider<MusicPlayerHeightStateNotifier, double>(
  (ref) => MusicPlayerHeightStateNotifier(),
);

class MusicPlayerSizeStateNotifier extends StateNotifier<double> {
  MusicPlayerSizeStateNotifier() : super(0.1);

  void setPlayerSize(double size) {
    state = size;
  }

  /// 0.25를 기준으로 한 transition factor (0 -> 1)
  /// 예시) 투명도 변화
  double get transitionFactor0_25 {
    if (state < 0.25) return 0.0;
    return (state - 0.25) / 0.75;
  }
}

class MusicPlayerHeightStateNotifier extends StateNotifier<double> {
  MusicPlayerHeightStateNotifier() : super(100.0);

  void setPlayerHeight(double height) {
    state = height;
  }
}
