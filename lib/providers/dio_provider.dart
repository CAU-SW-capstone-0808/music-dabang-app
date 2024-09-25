import 'dart:convert';

import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/providers/secret_value_provider.dart';
import 'package:music_dabang/providers/secure_storage_provider.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(connectTimeout: const Duration(minutes: 10)),
  );
  dio.interceptors.add(CustomInterceptor(ref: ref, storage: secureStorage));
  return dio;
});

class CustomInterceptor extends Interceptor {
  final Ref ref;
  final FlutterSecureStorage storage;

  const CustomInterceptor({
    required this.ref,
    required this.storage,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final String reqPath = options.uri.path;
    AidolUtils.d('[REQ] [${options.method}] ${options.uri}');
    AidolUtils.d(
        '[REQ] data(type=${options.data.runtimeType}) = ${options.data}');
    if (reqPath.contains('refresh')) {
      String? refreshToken = await ref
          .read(secretValueProvider("refreshToken").notifier)
          .fetchIf();
      if (refreshToken != null) {
        AidolUtils.d('reqPath:$reqPath -> Bearer {refreshToken}');
        options.headers.addAll({"Authorization": "Bearer $refreshToken"});
      }
    } else {
      String? accessToken =
          await ref.read(secretValueProvider("accessToken").notifier).fetchIf();
      if (accessToken != null && !reqPath.contains('/user/oauth')) {
        options.headers.addAll({"Authorization": "Bearer $accessToken"});
      }
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    AidolUtils.d(
        '[RES] [${response.requestOptions.method}][${response.statusCode}] ${response.requestOptions.uri}');
    final dataString = response.data.toString();
    AidolUtils.d(
        '[RES] body(type=${response.headers['Content-Type']}): ${dataString.length > 200 ? '${dataString.substring(0, 200)}...' : dataString}');
    // 단일 String 데이터에 대해 String으로 인식됨.
    if (response.data is String &&
        (response.headers['Content-Type']?.contains("application/json") ??
            false)) {
      response.data = jsonDecode(response.data);
    }

    // 오류 발생
    if (response.data is Map &&
        response.data.containsKey('error') &&
        response.data['error'] != null) {
      String? code = response.data['error'] as String?;
      // 오류 메시지 띄우기
      AidolUtils.showErrorToast(message: code);
      return handler.reject(
        DioException.badResponse(
          statusCode: response.statusCode ?? 500,
          requestOptions: response.requestOptions,
          response: response,
        ),
      );
    }
    // // data 추출 - {status:..., message:..., data:...}
    // if (response.data is Map && response.data.containsKey('data')) {
    //   response.data = response.data['data'];
    // }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 error => 로그아웃
    AidolUtils.d(
        '[ERR] [status=${err.response?.statusCode}][${err.requestOptions.method}] ${err.requestOptions.uri}');
    AidolUtils.d('[ERR] message = ${err.message}');
    if (err.requestOptions.uri.path.contains("login")) {
      return handler.reject(err);
    }
    final refreshResult = await ref.read(userProvider.notifier).refreshToken();
    if (refreshResult) {
      final newAccessToken = await storage.read(key: "accessToken");
      // 요청 재전송
      // err.requestOptions.headers.addAll(
      //   {"Authorization": "Bearer $newAccessToken"},
      // );
      err.requestOptions.headers["Authorization"] = 'Bearer $newAccessToken';
      try {
        final dio = Dio();
        final response = await dio.fetch(err.requestOptions);
        AidolUtils.d('did refresh token, re-fetch -> $response');
        return handler.resolve(response);
      } on DioException catch (e) {
        AidolUtils.d('did refresh token, error -> $e');
        return handler.reject(e);
      }
    } else {}
    return super.onError(err, handler);
  }
}
