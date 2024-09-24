import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/models/user/token_model.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/secret_value_provider.dart';
import 'package:music_dabang/providers/secure_storage_provider.dart';
import 'package:music_dabang/repository/user_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'package:synchronized/synchronized.dart';

final userProvider =
    StateNotifierProvider<UserStateNotifier, UserModelBase>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return UserStateNotifier(
    ref: ref,
    userRepository: userRepository,
    secureStorage: secureStorage,
  );
});

class UserStateNotifier extends StateNotifier<UserModelBase> {
  final Ref ref;
  final UserRepository userRepository;
  final FlutterSecureStorage secureStorage;
  bool _isRefreshing = false;
  DateTime? _lastRefreshTokenTime;
  static const _refreshDurationMinutes = 10;

  UserStateNotifier({
    required this.ref,
    required this.userRepository,
    required this.secureStorage,
  }) : super(UserModelLoading()) {
    init();
  }

  Future<void> init() async {
    state = UserModelLoading();
    // await Future.delayed(const Duration(seconds: 2));
    final tokenModel = await fetchToken();
    if (tokenModel != null) {
      await fetch();
    } else {
      state = UserModelNone();
    }
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

  Future<TokenModel?> fetchToken() async {
    String? refreshToken =
        await ref.read(secretValueProvider('refreshToken').notifier).fetchIf();
    String? accessToken =
        await ref.read(secretValueProvider('accessToken').notifier).fetchIf();
    if (accessToken == null || refreshToken == null) {
      return null;
    }
    return TokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// returns true if token is refreshed
  Future<bool> refreshToken({force = false}) async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
      final refreshToken = await ref
          .read(secretValueProvider('refreshToken').notifier)
          .fetchIf();
      return refreshToken != null;
    }

    _isRefreshing = true;
    bool refreshFlag = false;
    if (force) {
      refreshFlag = true;
    } else {
      if (_lastRefreshTokenTime == null) {
        refreshFlag = true;
      } else {
        final now = DateTime.now();
        final diff = now.difference(_lastRefreshTokenTime!);
        if (diff.inMinutes > _refreshDurationMinutes) {
          refreshFlag = true;
        }
      }
    }

    /// refresh token
    if (refreshFlag) {
      String? refreshToken = await ref
          .read(secretValueProvider('refreshToken').notifier)
          .fetchIf();
      String? accessToken =
          await ref.read(secretValueProvider('accessToken').notifier).fetchIf();

      /// if token is null, return false
      if (accessToken == null || refreshToken == null) {
        return false;
      }
      try {
        final newTokenModel = await userRepository.refreshToken(
          token: TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
        await Future.wait([
          ref
              .read(secretValueProvider('accessToken').notifier)
              .setValue(newTokenModel.accessToken),
          ref
              .read(secretValueProvider('refreshToken').notifier)
              .setValue(newTokenModel.refreshToken),
        ]);
        AidolUtils.d('refresh token saved');
        return true;
      } catch (e) {
        debugPrint('refresh token error: $e');
        await Future.wait([
          ref.read(secretValueProvider('accessToken').notifier).clear(),
          ref.read(secretValueProvider('refreshToken').notifier).clear(),
        ]);
        state = UserModelError('refresh token failed');
        return false;
      } finally {
        _isRefreshing = false;
      }
    } else {
      _isRefreshing = false;
      return false;
    }
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
