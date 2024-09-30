import 'package:music_dabang/common/firebase_logger.dart';
import 'package:riverpod/riverpod.dart';

final bottomNavProvider = StateNotifierProvider<BottomNavStateNotifier, int>(
  (ref) => BottomNavStateNotifier(),
);

class BottomNavStateNotifier extends StateNotifier<int> {
  BottomNavStateNotifier() : super(0);

  void select(int index) {
    state = index;
    if (index == 0) {
      FirebaseLogger.logScreenView('main');
    } else if (index == 1) {
      FirebaseLogger.logScreenView('my_music');
    }
  }
}
