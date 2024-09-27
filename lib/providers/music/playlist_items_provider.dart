import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/common/abstract_page_notifier.dart';
import 'package:music_dabang/repository/music_repository.dart';

final playlistItemsProvider = StateNotifierProviderFamily<
    PlaylistItemsStateNotifier,
    List<PlaylistItemModel>,
    int>((ref, playlistId) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return PlaylistItemsStateNotifier(
    playlistId: playlistId,
    musicRepository: musicRepository,
  );
});

class PlaylistItemsStateNotifier
    extends AbstractPageNotifier<PlaylistItemModel> {
  final int playlistId;
  final MusicRepository musicRepository;

  PlaylistItemsStateNotifier({
    required this.playlistId,
    required this.musicRepository,
  });

  @override
  PlaylistItemModel fromJson(Map<String, dynamic> json) {
    return PlaylistItemModel.fromJson(json);
  }

  @override
  Future<PageResponseModel> getList({
    required PageRequestModel pageRequest,
  }) async {
    return musicRepository.getPlaylistItems(
      playlistId: playlistId,
      queries: queries,
    );
  }

  PlaylistItemModel? findById(int id) {
    for (final item in state) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  PlaylistItemModel? getPrevious(int id) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].id == id) {
        if (i - 1 >= 0) {
          return state[i - 1];
        }
      }
    }
    return null;
  }

  PlaylistItemModel? getNext(int id) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].id == id) {
        if (i + 1 < state.length) {
          return state[i + 1];
        }
      }
    }
    return null;
  }
}
