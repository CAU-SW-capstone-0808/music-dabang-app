import 'package:just_audio/just_audio.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:video_player/video_player.dart';

/// providers about music player

/// 플레이어가 전체 화면인지 여부
final musicPlayerExpandedProvider =
    StateNotifierProvider<MusicPlayerExpandedStateNotifier, bool>(
  (ref) => MusicPlayerExpandedStateNotifier(),
);

/// 플레이어에서 비디오를 보여주는지 여부
final musicPlayerShowingVideoProvider =
    StateNotifierProvider<MusicPlayerShowingVideoStateNotifier, bool>(
  (ref) => MusicPlayerShowingVideoStateNotifier(),
);

/// 플레이어에서 재생 중인 플레이리스트. 없으면 알고리즘에 따라 재생
final currentPlaylistProvider =
    StateNotifierProvider<CurrentPlayingPlaylistStateNotifier, PlaylistModel?>(
  (ref) => CurrentPlayingPlaylistStateNotifier(ref: ref),
);

/// 플레이어에서 재생 중인 음악
final currentPlayingMusicProvider =
    StateNotifierProvider<CurrentPlayingMusicStateNotifier, MusicModel?>(
  (ref) => CurrentPlayingMusicStateNotifier(ref: ref),
);

class MusicPlayerExpandedStateNotifier extends StateNotifier<bool> {
  MusicPlayerExpandedStateNotifier() : super(false);

  set expanded(bool value) => state = value;
}

class MusicPlayerShowingVideoStateNotifier extends StateNotifier<bool> {
  MusicPlayerShowingVideoStateNotifier() : super(false);

  set showingVideo(bool value) => state = value;
}

class CurrentPlayingPlaylistStateNotifier
    extends StateNotifier<PlaylistModel?> {
  final Ref ref;

  CurrentPlayingPlaylistStateNotifier({required this.ref}) : super(null);

  Future<void> setPlaylist(
    PlaylistModel? playlist, {
    PlaylistItemModel? itemToPlay,
  }) async {
    // if (playlist?.id == state?.id) {
    //   return;
    // }
    state = playlist;
    // 플레이리스트가 변경되면 플레이리스트 아이템 목록을 다시 불러옴 -> 현재 재생 중인 음악이 변경됨
    if (playlist != null) {
      // 지정된 아이템이 있으면 해당 아이템을 재생
      if (itemToPlay != null) {
        await ref
            .read(currentPlayingMusicProvider.notifier)
            .setCurrentPlayingPlaylistItem(itemToPlay);
      }
      // 없으면 첫 번째 아이템을 재생
      else {
        await ref
            .read(playlistItemsProvider(playlist.id).notifier)
            .refresh()
            .then((items) async {
          if (items.isNotEmpty) {
            await ref
                .read(currentPlayingMusicProvider.notifier)
                .setCurrentPlayingPlaylistItem(items[0]);
          }
        });
      }
    }
  }

  Future<PlaylistItemModel?> skipPrevious() async {
    int? currentPlayingItemId = ref
        .read(currentPlayingMusicProvider.notifier)
        .currentPlayingPlaylistItemId;
    if (state != null && currentPlayingItemId != null) {
      PlaylistItemModel? currentPlayingItem = ref
          .read(playlistItemsProvider(state!.id).notifier)
          .findById(currentPlayingItemId);
      if (currentPlayingItem != null) {
        PlaylistItemModel? prevItem = ref
            .read(playlistItemsProvider(state!.id).notifier)
            .getPrevious(currentPlayingItemId);
        if (prevItem != null) {
          await ref
              .read(currentPlayingMusicProvider.notifier)
              .setCurrentPlayingPlaylistItem(prevItem);
          return prevItem;
        }
      }
    }
    return null;
  }

  Future<PlaylistItemModel?> skipNext() async {
    int? currentPlayingItemId = ref
        .read(currentPlayingMusicProvider.notifier)
        .currentPlayingPlaylistItemId;
    print("skipNext $currentPlayingItemId");
    if (state != null && currentPlayingItemId != null) {
      PlaylistItemModel? currentPlayingItem = ref
          .read(playlistItemsProvider(state!.id).notifier)
          .findById(currentPlayingItemId);
      if (currentPlayingItem != null) {
        PlaylistItemModel? nextItem = ref
            .read(playlistItemsProvider(state!.id).notifier)
            .getNext(currentPlayingItemId);
        if (nextItem != null) {
          await ref
              .read(currentPlayingMusicProvider.notifier)
              .setCurrentPlayingPlaylistItem(nextItem);
          return nextItem;
        }
      }
    }
    return null;
  }
}

class CurrentPlayingMusicStateNotifier extends StateNotifier<MusicModel?> {
  final Ref ref;
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoPlayerController;
  bool _showVideo = false;
  double _volume = 1.0; // 기본 볼륨 설정
  int? _currentPlayingPlaylistItemId;

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// 현재 실행 중인 플레이리스트 아이템 ID
  int? get currentPlayingPlaylistItemId => _currentPlayingPlaylistItemId;

  /// 현재 실행 중인 플레이리스트 아이템 설정
  Future<void> setCurrentPlayingPlaylistItem(PlaylistItemModel? item) async {
    _currentPlayingPlaylistItemId = item?.id;
    await setPlayingMusic(item?.musicContent);
  }

  /// 사용자 요청에 따라 비디오를 보여주는 여부.
  bool get showVideo => _showVideo;

  /// 현재 재생 위치
  Duration get currentPosition => _audioPlayer.position;

  set showVideo(bool value) {
    _showVideo = value;
    if (value) {
      _playVideo(state!.videoContentUrl);
    } else {
      _videoPlayerController?.dispose();
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
    }
  }

  CurrentPlayingMusicStateNotifier({required this.ref}) : super(null) {
    _audioPlayer.playerStateStream.listen((PlayerState playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _handleMusicCompletion();
      }
    });
  }

  // 음악 재생 완료 시 처리
  void _handleMusicCompletion() {
    ref.read(currentPlaylistProvider.notifier).skipNext();
  }

  // 현재 재생 중인 음악 설정
  Future<void> setPlayingMusic(MusicModel? music) async {
    // if (music?.id == state?.id) {
    //   return;
    // }
    state = music;
    AidolUtils.d("set music ${music?.title}");
    if (music != null) {
      _playMusic(music.musicContentUrl);
      if (showVideo || music.musicContentType == MusicContentType.live) {
        _playVideo(music.videoContentUrl);
      } else {
        _videoPlayerController?.dispose();
        ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
      }
    } else {
      _audioPlayer.stop();
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  // 오디오 재생 함수 (위치 동기화 추가)
  Future<void> _playMusic(
    String url, [
    Duration startPosition = Duration.zero,
  ]) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.setVolume(_volume); // 현재 볼륨 설정
      if (startPosition != Duration.zero) {
        await _audioPlayer.seek(startPosition); // 현재 위치에서 시작
      }
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  // 비디오 재생 함수 (위치 동기화 추가)
  Future<void> _playVideo(
    String url, [
    Duration startPosition = Duration.zero,
  ]) async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        // 오디오 재생 중에 다른 오디오 재생 허용
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setVolume(0); // 오디오를 비활성화
      if (startPosition != Duration.zero) {
        await _videoPlayerController!.seekTo(startPosition); // 현재 위치에서 시작
      } else {
        // 오디오와 비디오 간 동기화
        await _videoPlayerController!.seekTo(_audioPlayer.position);
      }
      await _videoPlayerController!.play();
      // 5초까지 대기
      int waitForVideoToInit = 0;
      while (waitForVideoToInit < 500 &&
          !_videoPlayerController!.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 10));
        waitForVideoToInit++;
      }
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = true;
    } catch (e) {
      print('Error playing video: $e');
    }
  }

  // 오디오와 비디오 간 전환 함수
  Future<void> toggleAudioVideo(bool playVideo) async {
    if (playVideo == ref.read(musicPlayerShowingVideoProvider)) return;

    if (playVideo) {
      final currentPosition = _audioPlayer.position;
      await _playVideo(state!.videoContentUrl, currentPosition);
    } else {
      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
    }
  }

  // 볼륨 조정 함수
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(_volume);
  }

  // 특정 위치로 커서 이동 (seek)
  void seekAudio(Duration position) async {
    await _videoPlayerController?.seekTo(position);
    _audioPlayer.seek(position);
  }

  void pauseAudio() {
    _audioPlayer.pause();
    _videoPlayerController?.pause();
  }

  void playAudio() async {
    await _videoPlayerController?.seekTo(_audioPlayer.position);
    await _videoPlayerController?.play();
    _audioPlayer.play();
  }

  void togglePlay() {
    if (_audioPlayer.playing ||
        _videoPlayerController?.value.isPlaying == true) {
      pauseAudio();
    } else {
      playAudio();
    }
  }

  // 재생 상태 스트림
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // 현재 재생 위치 스트림
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  // 전체 재생 시간 스트림
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // 상태 해제 시 리소스 정리
  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
