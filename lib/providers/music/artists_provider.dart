import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/music/artist_model.dart';
import 'package:music_dabang/repository/music_repository.dart';

final artistsProvider =
    StateNotifierProvider<ArtistsProvider, List<ArtistModel>>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return ArtistsProvider(musicRepository: musicRepository);
});

class ArtistsProvider extends StateNotifier<List<ArtistModel>> {
  final MusicRepository musicRepository;

  ArtistsProvider({
    required this.musicRepository,
  }) : super([]) {
    fetch();
  }

  Future<List<ArtistModel>> fetch() async {
    return state = await musicRepository.getArtists();
  }
}
