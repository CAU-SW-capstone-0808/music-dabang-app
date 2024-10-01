import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_dabang/common/utils.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  static late MyAudioHandler instance;
  final player = AudioPlayer();

  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<Object?> Function()? onSkipToPrevious;
  Future<Object?> Function()? onSkipToNext;

  MyAudioHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  static Future<void> init() async {
    instance = await AudioService.init<MyAudioHandler>(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId:
            'com.anarchyadventure.music_dabang.channel.audio',
        androidNotificationChannelName: 'Music Dabang Audio Player',
        androidNotificationChannelDescription: '뮤직다방',
        androidShowNotificationBadge: true,
        androidNotificationOngoing: true,
      ),
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    // print(
    //     "PlaybackState - updatePosition: ${player.position}, updateTime: ${DateTime.now()}");

    return PlaybackState(
      // setup and allow which control item in the control panel in the phone's lock screen
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      // setup the action can be used, it will show the buttons in the phone's lock screen
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToPrevious,
        MediaAction.pause,
        MediaAction.play,
        MediaAction.skipToNext,
        MediaAction.playPause,
      },
      // for android lock screen control buttons
      // androidCompactActionIndices: const [3],
      androidCompactActionIndices: const [0, 1, 2],
      // map the audio service processing state to just audio
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing, // is playing status
      updatePosition: player.position, // the current playing position
      bufferedPosition:
          player.duration ?? player.bufferedPosition, // the buffered position
      speed: player.speed, // player speed
      queueIndex: event.currentIndex, // the index of the current queue
      // queueIndex: 0,
      updateTime: DateTime.now(), // 마지막 업데이트 시간
    );
  }

  // The most common callbacks:
  Future<void> play() async => await onPlay?.call();
  Future<void> pause() async => await onPause?.call();
  Future<void> stop() => player.stop();

  Future<void> seek(Duration position) async {
    await player.seek(position);
    await super.seek(position);
  }

  Future<void> skipToQueueItem(int i) => player.seek(Duration.zero, index: i);

  @override
  Future<void> skipToPrevious() async {
    print('skip to prev');
    if (player.position.inSeconds <= 3) {
      final item = await onSkipToPrevious?.call();
      if (item == null) {
        AidolUtils.showToast('첫 번째 곡입니다.');
      }
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToNext() async {
    print('skip to next');
    onSkipToNext?.call();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    await player.setUrl(mediaItem.id);
    await player.play();
  }
}
