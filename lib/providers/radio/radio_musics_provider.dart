import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/radio_music_model.dart';
import 'package:music_dabang/repository/radio_repository.dart';
import 'package:synchronized/synchronized.dart';

final radioMusicsProvider = StateNotifierProviderFamily<RadioMusicsProvider,
    List<RadioMusicModel>, int>(
  (ref, id) {
    return RadioMusicsProvider(
      radioRepository: ref.watch(radioRepositoryProvider),
      broadcastId: id,
    );
  },
);

final willPlayMusicProvider =
    StateNotifierProviderFamily<WillPlayMusicProvider, RadioMusicModel?, int>(
        (ref, broadcastId) {
  return WillPlayMusicProvider();
});

class RadioMusicsProvider extends StateNotifier<List<RadioMusicModel>> {
  final RadioRepository radioRepository;
  final int broadcastId;
  final _lock = Lock();

  RadioMusicsProvider({
    required this.radioRepository,
    required this.broadcastId,
  }) : super([]);

  Future<List<RadioMusicModel>> fetch({refresh = false}) async {
    if (refresh) {
      state = [];
    }
    final radioMusics =
        await radioRepository.getRadioMusics(broadcastId: broadcastId);
    return state = [...radioMusics.reversed];
  }

  Future<void> addMusic(RadioMusicModel music) async {
    await _lock.synchronized(() async {
      if (state.isEmpty || state.first.id < music.id) {
        state = [music, ...state];
      }
    });
  }
}

class WillPlayMusicProvider extends StateNotifier<RadioMusicModel?> {
  WillPlayMusicProvider() : super(null);

  set music(RadioMusicModel? music) {
    state = music;
  }
}
