import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';

class RecentSearchStateNotifier extends StateNotifier<List<String>> {
  static const storageKey = 'recent-search-keywords';
  static const maxCount = 10;
  final localStorage = LocalStorage('recent-search');

  RecentSearchStateNotifier() : super([]);

  void init() {
    state = localStorage.getItem(storageKey) ?? [];
  }

  void add(String keyword) {
    state = [keyword, ...state];
    if (state.length > maxCount) {
      state = state.sublist(0, maxCount);
    }
    _save();
  }

  void remove(String keyword) {
    state.remove(keyword);
  }

  void _save() {
    localStorage.setItem('recent-search-keywords', state);
  }

  Future<void> clear() async {
    state = [];
    await localStorage.clear();
  }
}
