import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/common/abstract_page_notifier.dart';
import 'package:music_dabang/repository/music_repository.dart';
import 'package:riverpod/riverpod.dart';

final playlistMainProvider =
    StateNotifierProvider<PlaylistMainStateNotifier, List<PlaylistModel>>(
        (ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return PlaylistMainStateNotifier(
    musicRepository: musicRepository,
  );
});

class PlaylistMainStateNotifier extends AbstractPageNotifier<PlaylistModel> {
  final MusicRepository musicRepository;

  PlaylistMainStateNotifier({
    required this.musicRepository,
  }) : super(pageRequestModel: const PageRequestModel(sortOrder: 'asc'));

  @override
  PlaylistModel fromJson(Map<String, dynamic> json) {
    return PlaylistModel.fromJson(json);
  }

  @override
  Future<PageResponseModel> getList({required PageRequestModel pageRequest}) {
    return musicRepository.getMainPlaylists(queries: pageRequest.toJson());
  }
}
