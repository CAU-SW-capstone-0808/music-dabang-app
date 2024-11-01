import 'package:audio_service/audio_service.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/common/my_audio_handler.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:video_player/video_player.dart';

/// providers about music player

/// 음악 플레이어 상태
final musicPlayerStatusProvider = StateNotifierProvider<
    MusicPlayerExpandedStateNotifier, MusicDabangPlayerState>(
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

enum MusicDabangPlayerState {
  /// 플레이어가 접혀 있음
  collapsed(false),

  /// 플레이어가 확장됨
  expanded(true),

  /// 플레이어가 확장됨 + 플레이리스트가 확장된 상태
  expandedWithPlaylist(true);

  /// 전체 화면 여부
  final bool full;

  const MusicDabangPlayerState(this.full);
}

class MusicPlayerExpandedStateNotifier
    extends StateNotifier<MusicDabangPlayerState> {
  MusicPlayerExpandedStateNotifier() : super(MusicDabangPlayerState.collapsed);

  set status(MusicDabangPlayerState value) => state = value;

  void expand() {
    state = MusicDabangPlayerState.expanded;
  }

  void collapse() {
    state = MusicDabangPlayerState.collapsed;
  }

  void expandWithPlaylist() {
    state = MusicDabangPlayerState.expandedWithPlaylist;
  }
}

class MusicPlayerShowingVideoStateNotifier extends StateNotifier<bool> {
  MusicPlayerShowingVideoStateNotifier() : super(false);

  set showingVideo(bool value) => state = value;
}

/// 현재 재생 중인 플레이리스트 상태
class CurrentPlayingPlaylistStateNotifier
    extends StateNotifier<PlaylistModel?> {
  final Ref ref;

  CurrentPlayingPlaylistStateNotifier({required this.ref}) : super(null) {
    MyAudioHandler.instance.onSkipToPrevious = skipPrevious;
    MyAudioHandler.instance.onSkipToNext = skipNext;
  }

  Future<void> setPlaylist(
    PlaylistModel? playlist, {
    PlaylistItemModel? itemToPlay,
  }) async {
    // if (playlist?.id == state?.id) {
    //   return;
    // }
    state = playlist;
    // 플레이리스트가 변경되면 플레이리스트 아이템 목록을 다시 불러옴 -> 현재 재생 중인 음악이 변경됨
    // 지정된 아이템이 있으면 해당 아이템을 재생
    if (itemToPlay != null) {
      await ref
          .read(currentPlayingMusicProvider.notifier)
          .setCurrentPlayingPlaylistItem(itemToPlay);
    } else {
      // 지정된 아이템이 없으면+플레이리스트가 있으면 첫 번째 아이템을 재생
      if (playlist != null) {
        await ref
            .read(playlistItemsProvider(state?.id).notifier)
            .refresh()
            .then((items) async {
          if (items.isNotEmpty) {
            await ref
                .read(currentPlayingMusicProvider.notifier)
                .setCurrentPlayingPlaylistItem(items[0]);
          }
        });
      }
      // 지정된 아이템이 없음 + 플레이리스트 없음.
      else {
        await ref
            .read(currentPlayingMusicProvider.notifier)
            .setCurrentPlayingPlaylistItem(null);
      }
    }
  }

  Future<PlaylistItemModel?> skipPrevious() async {
    int? currentPlayingItemId = ref
        .read(currentPlayingMusicProvider.notifier)
        .currentPlayingPlaylistItemId;
    if (currentPlayingItemId != null) {
      PlaylistItemModel? currentPlayingItem = ref
          .read(playlistItemsProvider(state?.id).notifier)
          .findById(currentPlayingItemId);
      if (currentPlayingItem != null) {
        PlaylistItemModel? prevItem = ref
            .read(playlistItemsProvider(state?.id).notifier)
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
    if (currentPlayingItemId != null) {
      PlaylistItemModel? currentPlayingItem = ref
          .read(playlistItemsProvider(state?.id).notifier)
          .findById(currentPlayingItemId);
      if (currentPlayingItem != null) {
        PlaylistItemModel? nextItem = ref
            .read(playlistItemsProvider(state?.id).notifier)
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

  AudioPlayer get _audioPlayer => MyAudioHandler.instance.player;
  VideoPlayerController? _videoPlayerController;
  FlickManager? _flickManager;
  double _volume = 1.0; // 기본 볼륨 설정
  int? _currentPlayingPlaylistItemId;

  // VideoPlayerController? get videoPlayerController => _videoPlayerController;

  FlickManager? get flickManager => _flickManager;

  /// 현재 실행 중인 플레이리스트 아이템 ID
  int? get currentPlayingPlaylistItemId => _currentPlayingPlaylistItemId;

  /// 현재 실행 중인 플레이리스트 아이템 설정
  Future<void> setCurrentPlayingPlaylistItem(PlaylistItemModel? item) async {
    _currentPlayingPlaylistItemId = item?.id;
    await setPlayingMusic(item?.musicContent);
  }

  /// 사용자 요청에 따라 비디오를 보여주는 여부.
  bool get showVideo => ref.read(musicPlayerShowingVideoProvider);

  /// 현재 재생 위치
  Duration get currentPosition => _audioPlayer.position;

  /// 전체 재생 시간
  Duration? get maxPosition => _audioPlayer.duration;

  set showVideo(bool value) {
    if (value && state?.videoContentUrl != null) {
      _playVideo(state!.videoContentUrl!);
    } else {
      _disposeVideo();
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
    }
  }

  /// 생성자
  CurrentPlayingMusicStateNotifier({required this.ref}) : super(null) {
    // 이벤트 등록
    _audioPlayer.playerStateStream.listen((PlayerState playerState) {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.completed) {
        _handleMusicCompletion();
      }
      // firebase analytics
      if (processingState == ProcessingState.ready ||
          processingState == ProcessingState.completed) {
        FirebaseLogger.audioPlayerStatus(
          eventName: processingState.name,
          isPlaying: playerState.playing,
          playlistId: ref.read(currentPlaylistProvider)?.id,
          musicId: state?.id,
          title: state?.title,
          position: _audioPlayer.position,
        );
      }
    });
    MyAudioHandler.instance.onPlay = playAudio;
    MyAudioHandler.instance.onPause = pauseAudio;
  }

  // 음악 재생 완료 시 처리
  void _handleMusicCompletion() {
    ref.read(currentPlaylistProvider.notifier).skipNext();
  }

  // 현재 재생 중인 음악 설정
  Future<void> setPlayingMusic(MusicModel? music) async {
    AidolUtils.d("set music ${music?.title}");
    // if (music?.id == state?.id) {
    //   return;
    // }
    state = music;
    if (music != null) {
      await _playMusic(music);
      if ((showVideo || music.musicContentType == MusicContentType.live) &&
          music.videoContentUrl != null) {
        await _playVideo(music.videoContentUrl!);
      } else {
        await _disposeVideo();
        ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
      }
    } else {
      await _audioPlayer.stop();
      await _disposeVideo();
    }
  }

  // 오디오 재생 함수 (위치 동기화 추가)
  Future<void> _playMusic(
    MusicModel music, [
    Duration startPosition = Duration.zero,
  ]) async {
    try {
      var mediaItem = MediaItem(
        id: music.musicContentUrl,
        title: music.title,
        displayTitle: music.title,
        artist: music.artist.name,
        artUri: Uri.parse(music.thumbnailUrl),
      );
      await MyAudioHandler.instance.playMediaItem(mediaItem);
      // await _audioPlayer.setUrl(url);
      // await _audioPlayer.setVolume(_volume); // 현재 볼륨 설정
      if (startPosition != Duration.zero) {
        await _audioPlayer.seek(startPosition); // 현재 위치에서 시작
      }
      // await _audioPlayer.play();
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  bool wasBuffering = false;

  // 비디오 재생 함수 (위치 동기화 추가)
  Future<void> _playVideo(
    String url, [
    Duration startPosition = Duration.zero,
  ]) async {
    try {
      if (_videoPlayerController != null) {
        ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
        await _disposeVideo();
      }
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        // 오디오 재생 중에 다른 오디오 재생 허용
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false, // 백그라운드 재생 비허용
        ),
      );
      _flickManager = FlickManager(
        videoPlayerController: _videoPlayerController!,
        autoInitialize: false,
        autoPlay: true,
      );
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setVolume(0); // 오디오를 비활성화
      if (startPosition != Duration.zero) {
        await _videoPlayerController!.seekTo(startPosition); // 현재 위치에서 시작
      } else {
        // 오디오와 비디오 간 동기화
        await _videoPlayerController!.seekTo(_audioPlayer.position);
      }
      // 5초까지 대기
      int waitForVideoToInit = 0;
      while (waitForVideoToInit < 500 &&
          !_videoPlayerController!.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 10));
        waitForVideoToInit++;
      }
      if (_audioPlayer.playing) {
        await _videoPlayerController!.play();
      }
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = true;

      _videoPlayerController!.addListener(() {
        bool isBuffering = _videoPlayerController?.value.isBuffering ?? false;

        // Buffering state changed
        if (isBuffering != wasBuffering) {
          if (isBuffering) {
            // Video started buffering
            AidolUtils.d('Video started buffering');
            // Pause the audio player to maintain synchronization
            if (_audioPlayer.playing) {
              _audioPlayer.pause();
            }
          } else {
            // Video buffering ended
            AidolUtils.d('Video buffering ended');
            // Sync audio player to the video's current position
            final videoPosition = _videoPlayerController!.value.position;
            final audioPosition = _audioPlayer.position;

            // 200 ms 이상 차이가 나면 오디오 위치를 비디오 위치에 맞춤
            if ((videoPosition - audioPosition).inMilliseconds.abs() > 200) {
              // Adjust audio position to match video
              _audioPlayer.seek(videoPosition);
            }

            // Resume the audio player if it's paused
            if (!_audioPlayer.playing) {
              _audioPlayer.play();
            }
          }
          // Update the previous buffering state
          wasBuffering = isBuffering;
        }
      });
    } catch (e) {
      print('Error playing video: $e');
      FirebaseLogger.logError(e.toString());
    }
  }

  // 오디오와 비디오 간 전환 함수
  Future<void> toggleAudioVideo(bool playVideo) async {
    if (playVideo == ref.read(musicPlayerShowingVideoProvider)) return;

    if (state != null) {
      FirebaseLogger.toggleVideo(
        showVideo: playVideo,
        musicId: state!.id,
        musicTitle: state!.title,
        musicContentType: state!.musicContentType.name,
        artistName: state!.artist.name,
        position: _audioPlayer.position,
      );
    }

    if (playVideo && state?.videoContentUrl != null) {
      final currentPosition = _audioPlayer.position;
      await _playVideo(state!.videoContentUrl!, currentPosition);
    } else {
      // await _videoPlayerController?.pause();
      // await _videoPlayerController?.dispose();
      // _videoPlayerController = null;
      ref.read(musicPlayerShowingVideoProvider.notifier).showingVideo = false;
      await _disposeVideo();
    }
  }

  bool isFullScreen = false;

  Future<void> toggleFullscreen(bool value) async {
    AidolUtils.d('toggle fullscreen(value=$value)');
    isFullScreen = value;
    if (value) {
      _flickManager?.flickControlManager?.enterFullscreen();
    } else {
      _flickManager?.flickControlManager?.exitFullscreen();
    }
  }

  // 볼륨 조정 함수
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(_volume);
  }

  // 특정 위치로 커서 이동 (seek)
  Future<void> seekAudio(Duration position) async {
    await Future.wait([
      if (_videoPlayerController != null)
        _videoPlayerController!.seekTo(position).then((_) {
          if (_audioPlayer.playing) {
            _videoPlayerController!.play();
          }
        }),
      _audioPlayer.seek(position),
    ]);
  }

  Future<void> pauseAudio() async {
    await Future.wait([
      _audioPlayer.pause(),
      if (_videoPlayerController != null) _videoPlayerController!.pause(),
    ]);
  }

  Future<void> playAudio() async {
    await _videoPlayerController?.seekTo(_audioPlayer.position);
    await _videoPlayerController?.play();
    await _audioPlayer.play();
  }

  Future<void> togglePlay() async {
    if (_audioPlayer.playing ||
        _videoPlayerController?.value.isPlaying == true) {
      await pauseAudio();
    } else {
      await playAudio();
    }
  }

  // 재생 상태 스트림
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // 현재 재생 위치 스트림
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  // 전체 재생 시간 스트림
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> _disposeVideo() async {
    // await _videoPlayerController?.dispose();
    await _flickManager?.dispose();
    _flickManager = null;
    _videoPlayerController = null;
  }

  // 상태 해제 시 리소스 정리
  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }
}
