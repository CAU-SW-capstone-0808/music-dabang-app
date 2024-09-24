import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/consts.dart';
import 'package:music_dabang/models/user/token_model.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/dio_provider.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio, baseUrl: '$serverOrigin/user');
});

@RestApi()
abstract class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  @GET('/me')
  Future<UserModel> getMe();

  @POST('/oauth/kakao')
  Future<TokenModel> loginWithKakao({
    @Header('X-OAUTH-TOKEN') required String accessToken,
  });

  @POST('/token/refresh')
  Future<TokenModel> refreshToken({@Body() required TokenModel token});

  @POST('/token/logout')
  Future<void> logoutToken({@Body() required TokenModel token});
}
