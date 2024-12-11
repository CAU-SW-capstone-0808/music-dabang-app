import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/consts.dart';
import 'package:music_dabang/models/post/post_comment_model.dart';
import 'package:music_dabang/models/post/post_model.dart';
import 'package:music_dabang/providers/dio_provider.dart';
import 'package:retrofit/retrofit.dart';

part 'post_repository.g.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PostRepository(dio, baseUrl: '$serverOrigin/fandom');
});

@RestApi()
abstract class PostRepository {
  factory PostRepository(Dio dio, {String baseUrl}) = _PostRepository;

  @POST("/{artistId}/posts")
  Future<PostModel> createPost({
    @Path("artistId") required int artistId,
    @Body() required PostRequestModel createRequest,
  });

  @GET("/{artistId}/posts")
  Future<List<PostModel>> getPostsByArtist({
    @Path("artistId") required int artistId,
    @Query("sortBy") String sortBy = "createdAt",
  });

  @GET("/posts")
  Future<List<PostModel>> getPosts({
    @Query("sortBy") String sortBy = "createdAt",
  });

  @GET("/posts/{postId}")
  Future<PostModel> getPostById({
    @Path("postId") required int postId,
  });

  @POST("/posts/{postId}/comments")
  Future<PostCommentModel> addComment({
    @Path("postId") required int postId,
    @Body() required PostCommentRequestModel commentRequest,
  });

  @POST("/posts/{postId}/comments/{commentId}/reply")
  Future<PostCommentModel> addReply({
    @Path("postId") required int postId,
    @Path("commentId") required int commentId,
    @Body() required PostCommentRequestModel commentRequest,
  });

  @GET("/posts/{postId}/like")
  Future<bool> getPostLike({
    @Path("postId") required int postId,
  });

  @PUT("/posts/{postId}/like")
  Future<void> likePost({
    @Path("postId") required int postId,
  });

  @DELETE("/posts/{postId}/like")
  Future<void> cancelLikePost({
    @Path("postId") required int postId,
  });
}
