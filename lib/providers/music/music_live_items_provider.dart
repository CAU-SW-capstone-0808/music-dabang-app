import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/providers/common/abstract_page_notifier.dart';
import 'package:music_dabang/repository/music_repository.dart';

final musicLiveItemsProvider =
    StateNotifierProvider<MusicLiveItemsStateNotifier, List<MusicModel>>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return MusicLiveItemsStateNotifier(musicRepository: musicRepository);
});

class MusicLiveItemsStateNotifier extends AbstractPageNotifier<MusicModel> {
  final MusicRepository musicRepository;

  MusicLiveItemsStateNotifier({required this.musicRepository});

  @override
  MusicModel fromJson(Map<String, dynamic> json) {
    return MusicModel.fromJson(json);
  }

  @override
  Future<PageResponseModel> getList({required PageRequestModel pageRequest}) {
    return musicRepository.search(
      queries: queries,
      musicContentType: 'live',
    );
  }
}
