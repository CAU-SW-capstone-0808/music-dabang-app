import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/repository/music_repository.dart';

final musicAutoCompleteProvider =
    StateNotifierProvider<MusicAutoCompleteStateNotifier, List<String>>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return MusicAutoCompleteStateNotifier(musicRepository: musicRepository);
});

class MusicAutoCompleteStateNotifier extends StateNotifier<List<String>> {
  final MusicRepository musicRepository;
  final Map<String, _AutoCompleteInfo> _cache = {};

  /// keyword used in getter, setter
  String _keyword = '';
  String get keyword => _keyword;
  set keyword(String x) {
    if (x != _keyword) {
      _keyword = x;
      if (x.isNotEmpty) {
        fetch(x);
      }
    }
  }

  MusicAutoCompleteStateNotifier({
    required this.musicRepository,
  }) : super([]);

  Future<List<String>> fetch(String keyword) async {
    final now = DateTime.now();
    final info = _cache[keyword];
    if (info != null && now.difference(info.timestamp).inMinutes < 1) {
      return info.result;
    }

    final result = await musicRepository.autoComplete(
      query: keyword,
      limit: 20,
    );
    _cache[keyword] = _AutoCompleteInfo(
      keyword: keyword,
      result: result,
      timestamp: now,
    );
    return state = result;
  }
}

class _AutoCompleteInfo {
  final String keyword;
  final List<String> result;
  final DateTime timestamp;

  _AutoCompleteInfo({
    required this.keyword,
    required this.result,
    required this.timestamp,
  });
}
