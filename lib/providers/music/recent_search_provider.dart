import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';

final recentSearchProvider =
    StateNotifierProvider<RecentSearchStateNotifier, List<String>>((ref) {
  return RecentSearchStateNotifier();
});

class RecentSearchStateNotifier extends StateNotifier<List<String>> {
  static const storageKey = 'recent-search-keywords';
  static const maxCount = 10;
  final localStorage = LocalStorage('recent-search');

  RecentSearchStateNotifier() : super([]) {
    init();
  }

  void init() async {
    await localStorage.ready; // localStorage 준비가 완료될 때까지 기다림
    final storedData = localStorage.getItem(storageKey) as List<dynamic>?;

    if (storedData != null) {
      // 저장된 데이터를 상태로 설정
      state = List<String>.from(storedData);
    }
  }

  void add(String keyword) {
    if (state.contains(keyword)) {
      state.remove(keyword);
    }
    if (keyword.isEmpty) {
      return;
    }
    state = [keyword, ...state];
    if (state.length > maxCount) {
      state = state.sublist(0, maxCount);
    }
    _save();
  }

  void remove(String keyword) {
    state = state.where((element) => element != keyword).toList();
    _save();
  }

  void _save() {
    localStorage.setItem('recent-search-keywords', state);
  }

  Future<void> clear() async {
    state = [];
    await localStorage.clear();
  }
}
