import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:riverpod/riverpod.dart';

/// providers about music player

/// 플레이어가 전체 화면인지 여부
final musicPlayerExpandedProvider =
    StateNotifierProvider<MusicPlayerExpandedStateNotifier, bool>(
  (ref) => MusicPlayerExpandedStateNotifier(),
);

/// 플레이어에서 재생 중인 음악
final currentPlayingMusicProvider =
    StateNotifierProvider<CurrentPlayingMusicStateNotifier, MusicModel?>(
  (ref) => CurrentPlayingMusicStateNotifier(),
);

class MusicPlayerExpandedStateNotifier extends StateNotifier<bool> {
  MusicPlayerExpandedStateNotifier() : super(false);

  set expanded(bool value) => state = value;
}

class CurrentPlayingMusicStateNotifier extends StateNotifier<MusicModel?> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoPlayerController;
  bool _isPlayingVideo = false; // 비디오 재생 여부
  double _volume = 1.0; // 기본 볼륨 설정

  bool get isPlayingVideo => _isPlayingVideo;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  CurrentPlayingMusicStateNotifier() : super(null);

  // 현재 재생 중인 음악 설정
  set playingMusic(MusicModel? music) {
    if (music?.id == state?.id) {
      return;
    }
    state = music;
    if (music != null) {
      _playMusic(music.musicContentUrl);
      if (_isPlayingVideo || music.musicContentType == MusicContentType.live) {
        _playVideo(music.videoContentUrl);
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
        videoPlayerOptions: VideoPlayerOptions(),
      );
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setVolume(0); // 오디오를 비활성화
      if (startPosition != Duration.zero) {
        await _videoPlayerController!.seekTo(startPosition); // 현재 위치에서 시작
      }
      await _videoPlayerController!.play();
    } catch (e) {
      print('Error playing video: $e');
    }
  }

  // 오디오와 비디오 간 전환 함수
  Future<void> toggleAudioVideo(bool playVideo) async {
    if (playVideo == _isPlayingVideo) return;

    _isPlayingVideo = playVideo;
    final currentPosition = _audioPlayer.position;

    if (_isPlayingVideo) {
      await _playVideo(state!.videoContentUrl, currentPosition);
    } else {
      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  // 볼륨 조정 함수
  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(_volume);
  }

  // 특정 위치로 커서 이동 (seek)
  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
    if (_isPlayingVideo) {
      _videoPlayerController?.seekTo(position);
    }
  }

  void pauseAudio() {
    _audioPlayer.pause();
    _videoPlayerController?.pause();
  }

  void playAudio() async {
    _audioPlayer.play();
    await _videoPlayerController?.seekTo(_audioPlayer.position);
    await _videoPlayerController?.play();
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
