import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/music/music_model.dart';

final playingMusicProvider =
    StateNotifierProvider<PlayingMusicStateNotifier, MusicModel?>(
  (ref) => PlayingMusicStateNotifier(),
);

class PlayingMusicStateNotifier extends StateNotifier<MusicModel?> {
  PlayingMusicStateNotifier() : super(null);

  void play(MusicModel music) {
    state = music;
  }

  void stop() {
    state = null;
  }
}
