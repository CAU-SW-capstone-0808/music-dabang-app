import 'package:dio/dio.dart';
import 'package:music_dabang/common/consts.dart';
import 'package:riverpod/riverpod.dart';

final privacyAgreementStateNotifierProvider =
    StateNotifierProvider<PrivacyAgreementStateNotifier, String?>((ref) {
  return PrivacyAgreementStateNotifier(dio: Dio());
});

class PrivacyAgreementStateNotifier extends StateNotifier<String?> {
  final Dio dio;

  PrivacyAgreementStateNotifier({required this.dio}) : super(null) {
    init();
  }

  Future<String?> init() async {
    final resp = await dio.get('$serverOrigin/privacy-agreement.html');
    // 정규식을 사용하여 <pre> 태그 안의 텍스트만 추출
    RegExp regExp = RegExp(r"<pre>([\s\S]*?)<\/pre>");
    Match? match = regExp.firstMatch(resp.data);

    String preContent = match != null
        ? match.group(1) ?? 'No content found'
        : 'No <pre> tag found';

    return state = preContent;
  }
}
