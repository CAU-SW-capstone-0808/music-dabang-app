import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/common/abstract_page_notifier.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';
import 'package:music_dabang/repository/music_repository.dart';
import 'package:synchronized/synchronized.dart';

// final myMusicListProvider =
//     StateNotifierProvider<MyMusicListStateNotifier, List<PlaylistItemModel>>(
//         (ref) {
//   final musicRepository = ref.watch(musicRepositoryProvider);
//   return MyMusicListStateNotifier(ref: ref, musicRepository: musicRepository);
// });

final myMusicListCountProvider =
    StateNotifierProvider<MyMusicListCountStateNotifier, int?>(
  (ref) {
    final musicRepository = ref.watch(musicRepositoryProvider);
    return MyMusicListCountStateNotifier(musicRepository: musicRepository);
  },
);

final isInMyMusicListProvider =
    StateNotifierProviderFamily<IsInMyMusicListStateNotifier, bool?, int?>(
  (ref, musicId) {
    final musicRepository = ref.watch(musicRepositoryProvider);
    return IsInMyMusicListStateNotifier(
      ref: ref,
      musicId: musicId,
      musicRepository: musicRepository,
    );
  },
);

class MyMusicListStateNotifier extends AbstractPageNotifier<PlaylistItemModel> {
  final Ref ref;
  final MusicRepository musicRepository;
  final Lock _lock = Lock();

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

  Future<void> changeOrder({
    required int oldIndex,
    required int newIndex,
  }) async {
    if (oldIndex < 0 || oldIndex >= state.length || oldIndex == newIndex) {
      return;
    }
    return changeOrderById(itemId: state[oldIndex].id, targetIndex: newIndex);
  }

  Future<void> changeOrderById({
    // 현재 화면에서 볼 수 있는 아이템의 아이디여야 함
    required int itemId,
    // itemId이 최종적으로 되어야 할 index. 만약 범위를 벗어나면 가장 끝으로 이동
    required int targetIndex,
  }) async {
    // 길이가 2 이상인 리스트에 대해서만 동작
    if (state.length < 2) {
      return;
    }
    // item 탐색
    PlaylistItemModel? item;
    for (var i = 0; i < state.length; i++) {
      if (state[i].id == itemId) {
        item = state[i];
        break;
      }
    }
    if (item == null) {
      return;
    }

    // targetIndex 조정
    if (targetIndex < 0) {
      targetIndex = 0;
    }
    if (targetIndex >= state.length) {
      int wholeCount =
          await ref.read(myMusicListCountProvider.notifier).fetch();
      if (wholeCount <= targetIndex) {
        targetIndex = wholeCount - 1;
      }
    }

    // targetIndex보다 불러오지 못했을 경우, fetch() 실행
    while (state.length <= targetIndex) {
      final fetched = await fetch();
      if (fetched.isEmpty) {
        break;
      }
    }
    // 불러왔음에도 targetIndex가 범위를 벗어나면 종료
    if (state.length <= targetIndex) {
      return;
    }

    // 순서 변경 시작
    print('ordering start: id=$itemId -> index:$targetIndex');
    final orderingItem = item;
    await _lock.synchronized(() async {
      // 첫 번째에 삽입하는 경우
      if (targetIndex == 0) {
        // positive feedback
        state = [
          orderingItem.copyWith(order: state[0].order - 1000),
          ...state.where((e) => e.id != itemId),
        ];
        await musicRepository.changeItemOrder(
          itemId: orderingItem.id,
          order: state[0].order - 1000,
        );
      }
      // 마지막에 삽입하는 경우
      else if (targetIndex == state.length - 1) {
        // positive feedback
        state = [
          ...state.where((e) => e.id != itemId),
          orderingItem.copyWith(order: state.last.order + 1000),
        ];
        await musicRepository.changeItemOrder(
          itemId: orderingItem.id,
          order: state.last.order + 1000,
        );
      }
      // 중간에 삽입하는 경우
      else {
        int newOrder =
            (state[targetIndex - 1].order + state[targetIndex + 1].order) ~/ 2;
        // positive feedback
        final filtered = state.where((e) => e.id != itemId).toList();
        state = [
          ...filtered.sublist(0, targetIndex),
          orderingItem.copyWith(order: newOrder),
          ...filtered.sublist(targetIndex),
        ];
        await musicRepository.changeItemOrder(
          itemId: orderingItem.id,
          order: newOrder,
        );
      }
    });

    // 만약 중복된 order를 가지는 경우, order 조정 로직 실행됨.
    reorderValueIfNeeded(targetIndex - 1, direction: -1);
    reorderValueIfNeeded(targetIndex + 1, direction: 1);
  }

  /// order 값 조정. 리스트의 순서는 바뀌지 않음.
  /// [index] 중복된 order를 가지는 아이템의 인덱스
  /// [direction] -1이면 왼쪽, 1이면 오른쪽으로 전파
  Future<void> reorderValueIfNeeded(int index, {required int direction}) async {
    if (index < 0 || index >= state.length) {
      return;
    }
    int comparingIndex = index - direction;
    if (comparingIndex < 0 || comparingIndex >= state.length) {
      return;
    }
    // 비교 대상과 order가 같은 경우, order를 조정해야 함
    bool shouldChange = state[index].order == state[comparingIndex].order;
    if (shouldChange) {
      await _lock.synchronized(() async {
        if (index == 0) {
          final orderedItem = await musicRepository.changeItemOrder(
            itemId: state[index].id,
            order: state[comparingIndex].order - 1000,
          );
          state = [orderedItem, ...state.sublist(1)];
        } else if (index == state.length - 1) {
          final orderedItem = await musicRepository.changeItemOrder(
            itemId: state[index].id,
            order: state[comparingIndex].order + 1000,
          );
          state = [...state.sublist(0, state.length - 1), orderedItem];
        } else {
          int newOrder = (state[index - 1].order + state[index + 1].order) ~/ 2;
          // 이미 같은 order를 가지는 경우, 조정하지 않음
          if (newOrder == state[index].order) {
            return;
          }
          final orderedItem = await musicRepository.changeItemOrder(
            itemId: state[index].id,
            order: newOrder,
          );
          state = [
            ...state.sublist(0, index),
            orderedItem,
            ...state.sublist(index + 1),
          ];
        }
      });
    }
  }
}

class MyMusicListCountStateNotifier extends StateNotifier<int?> {
  final MusicRepository musicRepository;

  MyMusicListCountStateNotifier({
    required this.musicRepository,
  }) : super(null) {
    fetch();
  }

  Future<int> fetch() async {
    return state = await musicRepository.getMyMusicItemsCount();
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

class IsInMyMusicListStateNotifier extends StateNotifier<bool?> {
  final Ref ref;
  final int? musicId;
  final MusicRepository musicRepository;

  IsInMyMusicListStateNotifier({
    required this.ref,
    required this.musicId,
    required this.musicRepository,
  }) : super(null) {
    if (musicId != null) {
      fetch();
    } else {
      state = false;
    }
  }

  set value(bool x) => state = x;

  Future<bool> fetch() async {
    if (musicId == null) {
      return state = false;
    }
    if (ref
        .read(playlistItemsProvider(null).notifier)
        .isMusicInList(musicId!)) {
      return state = true;
    }
    return state = await musicRepository.isInMyMusicItems(musicId: musicId!);
  }
}
