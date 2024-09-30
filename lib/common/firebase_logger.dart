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

  static Future<void> setScreenSize(Size screenSize) async {
    await FirebaseAnalytics.instance.setUserProperty(
      name: 'screen_size',
      value: '${screenSize.width.toInt()}x${screenSize.height.toInt()}',
    );
  }

  /// 로그인 성공 기록
  static Future<void> initUser(UserModel user) async {
    await FirebaseAnalytics.instance.setUserId(id: user.id.toString());
    await FirebaseAnalytics.instance.logLogin(loginMethod: 'kakao');
    await FirebaseAnalytics.instance.logEvent(name: 'init_user');
  }

  /// 최근 검색어 사용
  static Future<void> useRecentSearchKeyword({
    required String keyword,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music_use_recent',
      parameters: {
        'keyword': keyword,
        'index': index,
      },
    );
  }

  /// 최근 검색어 사용 삭제
  static Future<void> deleteRecentSearchKeyword({
    required String keyword,
    required int index,
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
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'search_music_auto_complete',
      parameters: {
        'current_keyword': currentKeyword,
        'keyword': selectedKeyword,
        'index': index,
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
        'is_playing': isPlaying.toString(),
        if (playlistId != null) 'playlist_id': playlistId,
        if (musicId != null) 'music_id': musicId,
        if (title != null) 'title': title,
        if (position != null) 'position': position.inSeconds,
      },
    );
  }

  /// 스크린 기록
  static Future<void> logScreenView(String screenName) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  /// 홈: 라이브 영상 터치
  static Future<void> touchLivePlaylistItem({
    required int musicId,
    required String title,
    required String artistName,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_live_item',
      parameters: <String, Object>{
        'music_id': musicId,
        'title': title,
        'artist_name': artistName,
        'index': index,
      },
    );
  }

  /// 홈: 플레이리스트 터치
  static Future<void> touchPlaylist({
    required int playlistId,
    required String playlistName,
    required String? firstMusicTitle,
    required int? firstMusicId,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_playlist',
      parameters: <String, Object>{
        'playlist_id': playlistId,
        'playlist_name': playlistName,
        if (firstMusicTitle != null) 'first_music_title': firstMusicTitle,
        if (firstMusicId != null) 'first_music_id': firstMusicId,
        'index': index,
      },
    );
  }

  /// 홈: 플레이리스트 아이템 터치
  static Future<void> touchPlaylistItem({
    required int playlistId,
    required int playlistItemId,
    required int musicId,
    required String title,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_playlist_item',
      parameters: <String, Object>{
        'playlist_id': playlistId,
        'playlist_item_id': playlistItemId,
        'music_id': musicId,
        'title': title,
        'index': index,
      },
    );
  }
}
