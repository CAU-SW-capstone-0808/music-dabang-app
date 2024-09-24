import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/common/abstract_page_notifier.dart';
import 'package:music_dabang/repository/music_repository.dart';

final myMusicListProvider =
    StateNotifierProvider<MyMusicListStateNotifier, List<PlaylistItemModel>>(
        (ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return MyMusicListStateNotifier(musicRepository: musicRepository);
});

class MyMusicListStateNotifier extends AbstractPageNotifier<PlaylistItemModel> {
  final MusicRepository musicRepository;

  MyMusicListStateNotifier({
    required this.musicRepository,
  }) : super(pageRequestModel: const PageRequestModel(sortOrder: 'asc'));

  @override
  PlaylistItemModel fromJson(Map<String, dynamic> json) {
    return PlaylistItemModel.fromJson(json);
  }

  @override
  Future<PageResponseModel> getList({required PageRequestModel pageRequest}) {
    return musicRepository.getMyMusicItems(
      queries: pageRequest.toJson(),
    );
  }

  Future<PlaylistItemModel> addItem({required int musicId}) async {
    final addMyMusicItem =
        await musicRepository.addMyMusicItem(musicId: musicId);
    state = [...state, addMyMusicItem];
    return addMyMusicItem;
  }

  Future<void> removeItems({required List<int> itemIds}) async {
    await musicRepository.deleteMyMusicItems(itemIds: itemIds);
    state = state.where((e) => !itemIds.contains(e.id)).toList();
  }
}
