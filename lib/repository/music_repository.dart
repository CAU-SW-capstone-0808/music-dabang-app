import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/consts.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
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
  Future<List<PlaylistModel>> getMainPlaylists();
}
