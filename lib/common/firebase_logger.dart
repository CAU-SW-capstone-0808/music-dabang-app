import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:music_dabang/models/user/user_model.dart';

class FirebaseLogger {
  /// 터치 실수 기록
  static Future<void> touchMistake({
    required String path,
    Offset? position,
    Size? screenSize,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_mistake',
      parameters: <String, Object>{
        'path': path,
        if (position != null) 'position': '(${position.dx},${position.dy})',
        if (screenSize != null)
          'screen_size': '(${screenSize.width},${screenSize.height})',
      },
    );
  }

  /// 화면 리다이렉트 기록
  static Future<void> redirect({
    required String from,
    required String to,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'redirect',
      parameters: <String, Object>{
        'from': from,
        'to': to,
      },
    );
  }

  /// 로그인 시도 기록 (카카오)
  static Future<void> loginWithKakao() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'login_try',
      parameters: <String, Object>{
        'login_method': 'kakao',
      },
    );
  }

  /// 로그인 시도 기록 (전화번호)
  static Future<void> loginTryWithPhone() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'login_try',
      parameters: <String, Object>{
        'login_method': 'phone',
      },
    );
  }

  /// 로그인 성공 기록
  static Future<void> initUser(UserModel user) async {
    await FirebaseAnalytics.instance.setUserId(id: user.id.toString());
    await FirebaseAnalytics.instance.logLogin(loginMethod: 'kakao');
    await FirebaseAnalytics.instance.logEvent(name: 'init_user');
  }

  /// 최근 검색어 사용
  static Future<void> useRecentSearchKeyword({required String keyword}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music_use_recent',
      parameters: {
        'keyword': keyword,
      },
    );
  }

  /// 최근 검색어 사용 삭제
  static Future<void> deleteRecentSearchKeyword({
    required String keyword,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music_delete_recent',
      parameters: {
        'keyword': keyword,
      },
    );
  }

  /// 자동완성 검색어 사용
  static Future<void> useAutoCompleteSearchMusic({
    required String currentKeyword,
    required String selectedKeyword,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music_auto_complete',
      parameters: {
        'current_keyword': currentKeyword,
        'keyword': selectedKeyword,
      },
    );
  }

  /// 음악 검색 기록
  static Future<void> searchMusic({
    required String keyword,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music',
      parameters: <String, Object>{
        'keyword': keyword,
      },
    );
  }

  static Future<void> focusOnSearchField() async {
    await FirebaseAnalytics.instance.logEvent(name: 'use_search_text_field');
  }

  static Future<void> clearMusicSearchField() async {
    await FirebaseAnalytics.instance.logEvent(name: 'clear_search_text');
  }

  /// 음악 검색 화면에서 음악 재생 버튼 누름
  static Future<void> playMusicInSearchScreen({
    required int musicId, // 재생 음악 아이디
    required String keyword, // 검색어
    required String title, // 노래 제목
    required String artist, // 가수
    required int index, // 검색 결과 중 몇 번째 음악인지 (0부터 시작)
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music_play',
      parameters: {
        'music_id': musicId,
        'keyword': keyword,
        'title': title,
        'artist': artist,
        'index': index,
      },
    );
  }

  /// 오디오 플레이어 상태 기록
  static Future<void> audioPlayerStatus({
    required String eventName,
    required bool isPlaying, // 현재 재생 중인지 여부
    int? playlistId, // 현재 재생 중인 플레이리스트 ID
    int? musicId, // 현재 재생 중인 음악 ID
    String? title, // 현재 재생 중인 음악 제목
    Duration? position, // 현재 재생 중인 음악의 위치(초 단위 기록)
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'music_audio_event',
      parameters: <String, Object>{
        'event_name': eventName,
        'is_playing': isPlaying,
        if (playlistId != null) 'playlist_id': playlistId,
        if (musicId != null) 'music_id': musicId,
        if (title != null) 'title': title,
        if (position != null) 'position': position.inSeconds,
      },
    );
  }
}
