import 'package:music_dabang/models/music/playlist_model.dart';
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

class PlaylistMainStateNotifier extends StateNotifier<List<PlaylistModel>> {
  final MusicRepository musicRepository;

  PlaylistMainStateNotifier({
    required this.musicRepository,
  }) : super([]) {
    init();
  }

  Future<List<PlaylistModel>> init() async {
    return state = await musicRepository.getMainPlaylists();
  }
}
