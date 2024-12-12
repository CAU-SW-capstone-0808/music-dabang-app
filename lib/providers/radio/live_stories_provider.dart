import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/radio_story_model.dart';
import 'package:music_dabang/repository/radio_repository.dart';
import 'package:synchronized/synchronized.dart';

final liveStoriesProvider = StateNotifierProviderFamily<LiveStoriesProvider,
    List<RadioStoryModel>, int>(
  (ref, broadcastId) {
    return LiveStoriesProvider(
      broadcastId: broadcastId,
      radioRepository: ref.watch(radioRepositoryProvider),
    );
  },
);

class LiveStoriesProvider extends StateNotifier<List<RadioStoryModel>> {
  final RadioRepository radioRepository;
  final int broadcastId;
  final _lock = Lock();

  LiveStoriesProvider({
    required this.broadcastId,
    required this.radioRepository,
  }) : super([]);

  Future<List<RadioStoryModel>> fetch() async {
    return state =
        await radioRepository.getBroadcastStories(broadcastId: broadcastId);
  }

  /// 실제 요청은 웹소켓을 통함
  Future<void> addStory(RadioStoryModel story) async {
    await _lock.synchronized(() async {
      if (state.isEmpty || story.id > state.last.id) {
        state = [...state, story];
      }
    });
  }
}
