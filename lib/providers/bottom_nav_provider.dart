import 'package:riverpod/riverpod.dart';

final bottomNavProvider = StateNotifierProvider<BottomNavStateNotifier, int>(
  (ref) => BottomNavStateNotifier(),
);

class BottomNavStateNotifier extends StateNotifier<int> {
  BottomNavStateNotifier() : super(0);

  void select(int index) {
    state = index;
  }
}
