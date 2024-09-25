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

  CurrentPlayingMusicStateNotifier() : super(null);

  // 현재 재생 중인 음악 설정
  set playingMusic(MusicModel? music) {
    state = music;
    if (music != null) {
      _isPlayingVideo
          ? _playVideo(music.videoContentUrl)
          : _playMusic(music.musicContentUrl);
    } else {
      _audioPlayer.stop();
      _videoPlayerController?.dispose();
    }
  }

  // 오디오 재생 함수
  Future<void> _playMusic(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.setVolume(_volume); // 현재 볼륨 설정
      _audioPlayer.play();
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  // 비디오 재생 함수
  Future<void> _playVideo(String url) async {
    try {
      _videoPlayerController = VideoPlayerController.network(url);
      await _videoPlayerController!.initialize();
      _videoPlayerController!.play();
    } catch (e) {
      print('Error playing video: $e');
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
  }

  void pauseAudio() {
    _audioPlayer.pause();
  }

  void playAudio() {
    _audioPlayer.play();
  }

  void togglePlay() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
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
