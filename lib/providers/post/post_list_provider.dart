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
      return state = await postRepository.getPosts();
    } else {
      return state = await postRepository.getPostsByArtist(artistId: artistId!);
    }
  }

  Future<PostModel> fetchOne(int postId) async {
    var updatingPost = await postRepository.getPostById(postId: postId);
    for (final post in state) {
      if (post.id == postId) {
        state = state.map((p) {
          if (p.id == postId) {
            return updatingPost;
          }
          return p;
        }).toList();
      }
    }
    return updatingPost;
  }

  Future<PostModel> refreshOne(int postId) async {
    final updatingPost = await postRepository.getPostById(postId: postId);
    state = state.map((post) {
      if (post.id == postId) {
        return updatingPost;
      }
      return post;
    }).toList();
    return updatingPost;
  }

  Future<List<PostModel>> addPost({
    required String title,
    required String content,
  }) async {
    if (artistId == null) {
      throw Exception('artistId is null');
    }
    final newPost = await postRepository.createPost(
      artistId: artistId!,
      createRequest: PostRequestModel(title: title, content: content),
    );
    return fetch();
    // state = [newPost, ...state];
    // return state;
  }
}
