import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/post/post_model.dart';
import 'package:music_dabang/providers/post/fandom_provider.dart';
import 'package:music_dabang/repository/post_repository.dart';

final postListProvider =
    StateNotifierProvider<PostListStateNotifier, List<PostModel>>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final selectedArtistId = ref.watch(selectedArtistIdProvider);
  return PostListStateNotifier(
    postRepository: postRepository,
    artistId: selectedArtistId,
  );
});

class PostListStateNotifier extends StateNotifier<List<PostModel>> {
  final PostRepository postRepository;
  final int? artistId;

  PostListStateNotifier({
    required this.postRepository,
    required this.artistId,
  }) : super([]) {
    fetch();
  }

  Future<List<PostModel>> fetch() async {
    if (artistId == null) {
      return postRepository.getPosts();
    } else {
      return postRepository.getPostsByArtist(artistId: artistId!);
    }
  }
}
