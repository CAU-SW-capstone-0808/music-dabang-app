import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/providers/common/abstract_page_notifier.dart';
import 'package:music_dabang/repository/music_repository.dart';
import 'package:riverpod/riverpod.dart';

final musicSearchProvider = StateNotifierProviderFamily<
    MusicSearchStateNotifier, List<MusicModel>, String>((ref, q) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return MusicSearchStateNotifier(
    musicRepository: musicRepository,
    keyword: q,
  );
});

class MusicSearchStateNotifier extends AbstractPageNotifier<MusicModel> {
  final MusicRepository musicRepository;
  final String keyword;

  MusicSearchStateNotifier({
    required this.musicRepository,
    required this.keyword,
  }) : super();

  @override
  Future<PageResponseModel> getList({
    required PageRequestModel pageRequest,
  }) async {
    if (keyword.isEmpty) {
      return const PageResponseModel(data: [], cursor: null);
    }
    return musicRepository.search(
      query: keyword,
      queries: queries,
    );
  }

  @override
  MusicModel fromJson(Map<String, dynamic> json) {
    return MusicModel.fromJson(json);
  }
}
