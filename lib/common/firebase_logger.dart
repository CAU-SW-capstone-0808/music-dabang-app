import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:music_dabang/models/user/user_age.dart';
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
  @Deprecated('Use logScreenView instead')
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
    await setUserAge(user.userAge);
    await FirebaseAnalytics.instance.logLogin(loginMethod: 'kakao');
    await FirebaseAnalytics.instance.logEvent(name: 'init_user');
  }

  static Future<void> setUserAge(UserAge? userAge) async {
    await FirebaseAnalytics.instance.setUserProperty(
      name: 'age',
      value: userAge?.name ?? "null",
    );
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
    required String musicContentType,
    required String artistName,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_live_item',
      parameters: <String, Object>{
        'music_id': musicId,
        'title': title,
        'music_content_type': musicContentType,
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
    required String? firstMusicContentType,
    required int? firstMusicId,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_playlist',
      parameters: <String, Object>{
        'playlist_id': playlistId,
        'playlist_name': playlistName,
        if (firstMusicTitle != null) 'first_music_title': firstMusicTitle,
        if (firstMusicContentType != null)
          'first_music_content_type': firstMusicContentType,
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
    required String musicContentType,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_playlist_item',
      parameters: <String, Object>{
        'playlist_id': playlistId,
        'playlist_item_id': playlistItemId,
        'music_id': musicId,
        'title': title,
        'music_content_type': musicContentType,
        'index': index,
      },
    );
  }

  /// 음악 플레이어 변화 기록
  static Future<void> changeMusicPlayerStatus({
    required String musicPlayerStatus,
    required String userAction, // touch(사용자 터치), drag(사용자 드래그), auto(자동)
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'change_music_player_status',
      parameters: <String, Object>{
        'music_player_status': musicPlayerStatus,
        'user_action': userAction,
      },
    );
  }

  /// 비디오 오디오 전환
  static Future<void> toggleVideo({
    required bool showVideo,
    required int musicId,
    required String musicTitle,
    required String musicContentType,
    required String artistName,
    required Duration position,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'toggle_video',
      parameters: <String, Object>{
        'show_video': showVideo.toString(),
        'music_id': musicId,
        'music_title': musicTitle,
        'music_content_type': musicContentType,
        'artist_name': artistName,
        'position': position.inSeconds,
      },
    );
  }

  /// 뮤직 플레이어 버튼 터치
  static Future<void> touchMusicPlayerAction({
    required String action,
    required int? musicId,
    required String? musicTitle,
    required String? musicContentType,
    required String? artistName,
    required int? playlistId,
    required String? playlistName,
    required Duration? position,
    required bool playerExpanded, // 플레이어 확장 여부
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_music_player_button',
      parameters: <String, Object>{
        'action': action,
        if (musicId != null) 'music_id': musicId,
        if (musicTitle != null) 'music_title': musicTitle,
        if (musicContentType != null) 'music_content_type': musicContentType,
        if (artistName != null) 'artist_name': artistName,
        if (playlistId != null) 'playlist_id': playlistId,
        if (playlistName != null) 'playlist_name': playlistName,
        if (position != null) 'position': position.inSeconds,
        'player_expanded': playerExpanded.toString(),
      },
    );
  }

  /// 뮤직 플레이어 UI - 플레이리스트 상태 변경
  static Future<void> changeMusicPlayerPlaylistStatus({
    required String status,
    required String userAction, // auto, touch, drag
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'music_player_playlist_viewer_status',
      parameters: <String, Object>{
        'status': status,
        'user_action': userAction,
      },
    );
  }

  /// 뮤직 플레이어 UI - 플레이리스트 아이템 재생
  static Future<void> playMusicInPlaylist({
    required int? prevMusicId,
    required String? prevMusicTitle,
    required String? prevMusicContentType,
    required int? musicId,
    required String? musicTitle,
    required String? musicContentType,
    required int? playlistId,
    required String? playlistName,
    required Duration? position,
    required Duration? maxPosition,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'change_music_in_playlist_player',
      parameters: <String, Object>{
        if (prevMusicId != null) 'prev_music_id': prevMusicId,
        if (prevMusicTitle != null) 'prev_music_title': prevMusicTitle,
        if (prevMusicContentType != null)
          'prev_music_content_type': prevMusicContentType,
        if (musicId != null) 'music_id': musicId,
        if (musicTitle != null) 'music_title': musicTitle,
        if (musicContentType != null) 'music_content_type': musicContentType,
        if (playlistId != null) 'playlist_id': playlistId,
        if (playlistName != null) 'playlist_name': playlistName,
        if (position != null) 'position': position.inSeconds,
        if (maxPosition != null) 'max_position': maxPosition.inSeconds,
        'index': index,
      },
    );
  }

  /// 내 음악 재생
  static Future<void> touchMyMusicItem({
    required int? musicId,
    required String? musicTitle,
    required String? musicContentType,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_my_music_item',
      parameters: <String, Object>{
        if (musicId != null) 'music_id': musicId,
        if (musicTitle != null) 'music_title': musicTitle,
        if (musicContentType != null) 'music_content_type': musicContentType,
        'index': index,
      },
    );
  }

  /// 새로고침 행동
  static Future<void> refreshItems() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'refresh_items',
    );
  }

  /// 내 음악 삭제
  static Future<void> removeMyMusicItem({
    required int? musicId,
    required String? musicTitle,
    required String? musicContentType,
    required int index,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'remove_my_music_item',
      parameters: <String, Object>{
        if (musicId != null) 'music_id': musicId,
        if (musicTitle != null) 'music_title': musicTitle,
        if (musicContentType != null) 'music_content_type': musicContentType,
        'index': index,
      },
    );
  }

  /// 내 음악 순서 변경
  static Future<void> changeMyMusicListOrder({
    required int? musicId,
    required String? title,
    required String? musicContentType,
    required int fromIndex,
    required int toIndex,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'change_my_music_list_order',
      parameters: <String, Object>{
        if (musicId != null) 'music_id': musicId,
        if (title != null) 'title': title,
        if (musicContentType != null) 'music_content_type': musicContentType,
        'from_index': fromIndex,
        'to_index': toIndex,
      },
    );
  }

  /// '맨 위로' 버튼 터치
  static Future<void> touchToTopButton() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'touch_to_top_button',
    );
  }

  /// 오류 기록
  static Future<void> logError(String errorMessage) {
    return FirebaseAnalytics.instance.logEvent(
      name: 'error',
      parameters: <String, Object>{
        'error_message': errorMessage,
      },
    );
  }
}
