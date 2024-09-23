import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/secure_storage_provider.dart';
import 'package:music_dabang/repository/user_repository.dart';
import 'package:riverpod/riverpod.dart';

final userProvider =
    StateNotifierProvider<UserStateNotifier, UserModelBase>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return UserStateNotifier(
    userRepository: userRepository,
    secureStorage: secureStorage,
  );
});

class UserStateNotifier extends StateNotifier<UserModelBase> {
  final UserRepository userRepository;
  final FlutterSecureStorage secureStorage;

  UserStateNotifier({
    required this.userRepository,
    required this.secureStorage,
  }) : super(UserModelLoading()) {
    init();
  }

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 2));
    state = UserModelNone();
  }

  Future<void> loginWithKakao() async {
    try {
      late OAuthToken token;
      bool kakaoInstalled = await isKakaoTalkInstalled();
      if (kakaoInstalled) {
        debugPrint('kakaotalk installed');
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        debugPrint('kakaotalk not installed');
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      debugPrint('카카오계정으로 로그인 성공 ${token.accessToken}, ${token.refreshToken}');
      state = UserModelLoading();
      final serviceToken =
          await userRepository.loginWithKakao(accessToken: token.accessToken);
      // save jwt service token to secure storage
      await Future.wait([
        secureStorage.write(
            key: 'accessToken', value: serviceToken.accessToken),
        secureStorage.write(
            key: 'refreshToken', value: serviceToken.refreshToken),
      ]);
      await fetch();
    } catch (error) {
      debugPrint('카카오계정으로 로그인 실패 $error');
      state = UserModelError('카카오계정으로 로그인 실패');
    }
  }

  Future<bool> refreshToken() async {
    return false;
  }

  Future<UserModel> fetch() async {
    return state = await userRepository.getMe();
  }

  void logout() {
    state = UserModelLoading();
  }

  void error(String message) {
    state = UserModelError(message);
  }
}
