import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/providers/post/post_list_provider.dart';
import 'package:music_dabang/repository/post_repository.dart';

final postLikedProvider =
    StateNotifierProviderFamily<PostLikedProvider, bool, int>(
  (ref, postId) {
    final postRepository = ref.watch(postRepositoryProvider);
    return PostLikedProvider(
      ref: ref,
      postRepository: postRepository,
      postId: postId,
    );
  },
);

class PostLikedProvider extends StateNotifier<bool> {
  final Ref ref;
  final PostRepository postRepository;
  final int postId;

  PostLikedProvider({
    required this.ref,
    required this.postRepository,
    required this.postId,
  }) : super(false) {
    fetch();
  }

  Future<bool> fetch() async {
    final isLiked = await postRepository.getPostLike(postId: postId);
    state = isLiked;
    return isLiked;
  }

  Future<void> unlikePost(int postId) async {
    await postRepository.cancelLikePost(postId: postId);
    state = false;
    ref.read(postListProvider.notifier).refreshOne(postId);
  }

  Future<void> likePost(int postId) async {
    await postRepository.likePost(postId: postId);
    state = true;
    ref.read(postListProvider.notifier).refreshOne(postId);
  }

  Future<void> toggleLike() async {
    if (state) {
      await unlikePost(postId);
    } else {
      await likePost(postId);
    }
  }
}
