import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/consts.dart';
import 'package:music_dabang/models/common/page_response_model.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/dio_provider.dart';
import 'package:retrofit/retrofit.dart';

part 'music_repository.g.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MusicRepository(dio, baseUrl: '$serverOrigin/music');
});

@RestApi()
abstract class MusicRepository {
  factory MusicRepository(Dio dio, {String baseUrl}) = _MusicRepository;

  /// 시스템 메인에 보이는 플레이리스트를 가져옵니다.
  @GET('/playlists/main')
  Future<PageResponseModel> getMainPlaylists({
    @Queries() required Map<String, dynamic> queries,
  });

  /// 내 음악 목록
  @GET("/playlists/my/items")
  Future<PageResponseModel> getMyMusicItems({
    @Queries() required Map<String, dynamic> queries,
  });

  @GET("/playlists/my/items/count")
  Future<int> getMyMusicItemsCount();

  @POST("/playlists/my/items")
  Future<PlaylistItemModel> addMyMusicItem({
    @Query("music_id") required int musicId,
  });

  @DELETE("/playlists/items")
  Future<void> deleteMyMusicItems({
    @Query("item_id") required List<int> itemIds,
  });

  @PATCH("/playlists/items/{itemId}/order")
  Future<PlaylistItemModel> changeItemOrder({
    @Path("itemId") required int itemId,
    @Query("order") required int order,
  });

  @GET("/playlists/{playlistId}/items")
  Future<PageResponseModel> getPlaylistItems({
    @Path("playlistId") required int playlistId,
    @Queries() required Map<String, dynamic> queries,
  });

  @GET("/playlists/{playlistId}/items/count")
  Future<int> getPlaylistItemCount({
    @Path("playlistId") required int playlistId,
  });

  @GET("/search")
  Future<PageResponseModel> search({
    @Queries() required Map<String, dynamic> queries,
    @Query("type") String? musicContentType,
    @Query("q") String? query,
  });

  @GET("/search/autocomplete")
  Future<List<String>> autoComplete({
    @Query("q") required String query,
    @Query("limit") required int limit,
  });
}
