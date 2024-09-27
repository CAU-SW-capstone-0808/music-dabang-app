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
  return MyMusicListStateNotifier(ref: ref, musicRepository: musicRepository);
});

final myMusicListCountProvider =
    StateNotifierProvider<MyMusicListCountStateNotifier, int?>(
  (ref) {
    final musicRepository = ref.watch(musicRepositoryProvider);
    return MyMusicListCountStateNotifier(musicRepository: musicRepository);
  },
);

class MyMusicListStateNotifier extends AbstractPageNotifier<PlaylistItemModel> {
  final Ref ref;
  final MusicRepository musicRepository;

  MyMusicListStateNotifier({
    required this.ref,
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
    ref.read(myMusicListCountProvider.notifier).add(1);
    return addMyMusicItem;
  }

  Future<void> removeItems({required List<int> itemIds}) async {
    await musicRepository.deleteMyMusicItems(itemIds: itemIds);
    ref.read(myMusicListCountProvider.notifier).add(-itemIds.length);
    state = state.where((e) => !itemIds.contains(e.id)).toList();
  }
}

class MyMusicListCountStateNotifier extends StateNotifier<int?> {
  final MusicRepository musicRepository;

  MyMusicListCountStateNotifier({
    required this.musicRepository,
  }) : super(null) {
    fetch();
  }

  Future<void> fetch() async {
    state = await musicRepository.getMyMusicItemsCount();
  }

  void add([int count = 1]) {
    if (state != null) {
      state = state! + count;
      if (state! < 0) {
        state = 0;
      }
    }
  }
}
