import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/models/radio/broadcast_model.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';
import 'package:music_dabang/models/radio/radio_chat_model.dart';
import 'package:music_dabang/models/radio/radio_music_model.dart';
import 'package:music_dabang/models/radio/radio_response_model.dart';
import 'package:music_dabang/models/radio/radio_story_model.dart';
import 'package:music_dabang/models/radio/radio_tts_model.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/radio/live_stories_provider.dart';
import 'package:music_dabang/providers/radio/radio_channels_provider.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcast_chats_provider.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcasts_provider.dart';
import 'package:music_dabang/providers/radio/radio_musics_provider.dart';
import 'package:music_dabang/providers/secret_value_provider.dart';
import 'package:music_dabang/providers/user/user_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// 라이브 연결 상태
enum RadioLiveStatus {
  none, // 초기화 상태
  yet, // 연결 시작 전, 객체만 보유한 상태
  connecting, // 연결 중
  connected, // 연결 및 입장 완료
  disconnected, // 연결 종료
  error; // 오류 발생

  bool get isLoading => this == none || this == yet || this == connecting;
}

/// 라이브 상태 관리에 쓰이는 객체
class RadioLiveState {
  final RadioLiveStatus status;
  final BroadcastLiveModel? broadcast;
  final RadioChannelModel? channel;

  const RadioLiveState({
    this.status = RadioLiveStatus.none,
    this.broadcast,
    this.channel,
  });

  @override
  bool operator ==(Object other) {
    return other is RadioLiveState &&
        other.status == status &&
        other.broadcast == broadcast &&
        other.channel == channel;
  }

  @override
  int get hashCode {
    return status.hashCode ^ broadcast.hashCode ^ channel.hashCode;
  }

  RadioLiveState copyWith({
    RadioLiveStatus? status,
    BroadcastLiveModel? broadcast,
    RadioChannelModel? channel,
  }) {
    return RadioLiveState(
      status: status ?? this.status,
      broadcast: broadcast,
      channel: channel,
    );
  }
}

final radioLiveBroadcastProvider = StateNotifierProviderFamily<
    RadioLiveBroadcastProvider, RadioLiveState, int>(
  (ref, id) {
    return RadioLiveBroadcastProvider(
      ref: ref,
      broadcastId: id,
    );
  },
);

class RadioLiveBroadcastProvider extends StateNotifier<RadioLiveState> {
  final Ref ref;
  final int broadcastId;
  IO.Socket? socket;
  final audioPlayer = AudioPlayer();

  set status(RadioLiveStatus status) {
    state = state.copyWith(
      status: status,
      broadcast: state.broadcast,
      channel: state.channel,
    );
  }

  RadioLiveStatus get status => state.status;

  RadioLiveBroadcastProvider({
    required this.ref,
    required this.broadcastId,
  }) : super(const RadioLiveState());

  Future<void> init() async {
    BroadcastLiveModel? broadcast;
    RadioChannelModel? channel;
    final lives = ref.read(radioLiveBroadcastsProvider);
    for (final live in lives) {
      if (live.id == broadcastId) {
        broadcast = live;
        final channels = ref.read(radioChannelsProvider);
        for (final ch in channels) {
          if (ch.id == live.channelId) {
            channel = ch;
          }
        }
      }
    }
    if (broadcast == null || channel == null) {
      status = RadioLiveStatus.error;
      return;
    }
    state = state.copyWith(
      status: RadioLiveStatus.yet,
      broadcast: broadcast,
      channel: channel,
    );
    await initData();
    await disconnect();
    await _connect();
  }

  Future<void> initData() async {
    await Future.wait([
      ref.read(radioLiveBroadcastChatsProvider(broadcastId).notifier).fetch(),
      ref.read(liveStoriesProvider(broadcastId).notifier).fetch(),
      ref.read(radioMusicsProvider(broadcastId).notifier).fetch(refresh: true),
    ]);
  }

  Future<void> _connect() async {
    String? accessToken =
        await ref.read(secretValueProvider('accessToken').notifier).fetchIf();
    if (accessToken == null) {
      status = RadioLiveStatus.error;
      return;
    }

    status = RadioLiveStatus.connecting;
    socket = IO.io(
      'https://mdradio.jdn.kr:443',
      IO.OptionBuilder().setTransports(['websocket', 'polling']).build(),
    );

    socket!.onConnect((x) {
      print('socketio connect $x');
      socket!.emit('init', {
        'broadcast_id': broadcastId,
        'token': accessToken,
      });
    });

    socket!.on('init_response', (data) {
      final initModel = RadioInitResponseModel.fromJson(data);
      print('socketio init_response: $data');
      if (initModel.status == 'success') {
        state = state.copyWith(
          status: RadioLiveStatus.connected,
          broadcast: state.broadcast?.copyWith(
            listenerCount: initModel.listenersCount,
          ),
          channel: state.channel,
        );
        ref.read(willPlayMusicProvider(broadcastId).notifier).music =
            initModel.willPlayMusic?.toRadioMusicModel;

        // 입장 시 음악, TTS 재생
        if (initModel.playingMusic != null) {
          final music = initModel.playingMusic!;
          playMusic(music, directPlay: false);
        }
        if (initModel.playingTTS != null) {
          final tts = initModel.playingTTS!;
          playTTS(tts, directPlay: false);
        }
      } else {
        print('init_response error: ${data['message']}');
        status = RadioLiveStatus.error;
      }
    });

    socket!.on('broadcast_status', (data) {
      print('broadcast_status: $data');
      if (data['listener_count'] != null && data['listener_count'] is int) {
        final updatedListenerCount = data['listener_count'] as int;
        if (state.broadcast != null &&
            state.broadcast!.listenerCount != updatedListenerCount) {
          print('listener_count updated: ${state.channel}');
          state = state.copyWith(
            broadcast: state.broadcast!.copyWith(
              listenerCount: updatedListenerCount,
            ),
            channel: state.channel,
          );
        }
      }
    });

    socket!.on('chat', (data) {
      final chat = RadioChatModel.fromJson(data);
      ref
          .read(radioLiveBroadcastChatsProvider(broadcastId).notifier)
          .addChat(chat);
    });

    // 사연 선정됨
    socket!.on('story_selected', (data) {
      print('socket_io story: $data');
      final story = RadioStoryModel.fromJson(data);
      final me = ref.read(userProvider);
      if (me is UserModel && me.id.toString() == story.userId) {
        AidolUtils.showToast('사연이 선정되었습니다. 축하드립니다!');
      }
      // ref.read(liveStoriesProvider(broadcastId).notifier).addStory(story);
    });

    // 사연 전송됨
    socket!.on('story_received', (data) {
      print('socket_io story: $data');
      if (data["status"] == "success") {
        AidolUtils.showToast('사연이 성공적으로 전송되었습니다.');
      } else {
        AidolUtils.showToast('이미 사연을 전송하셨습니다.');
      }
    });

    socket!.on('tts', (data) {
      print('socketio tts: $data');
      final ttsModel = RadioTTSModel.fromJson(data);
      playTTS(ttsModel);
    });

    socket!.on('music_track', (data) {
      print('socketio music_track: $data');
      final musicModel = RadioMusicModel.fromJson(data);
      ref.read(radioMusicsProvider(broadcastId).notifier).addMusic(musicModel);
      playMusic(musicModel);
    });

    socket!.on('will_play_music', (data) {
      print('socketio will_play_music: $data');
      final musicModel = RadioWillPlayMusicModel.fromJson(data);
      ref.read(willPlayMusicProvider(broadcastId).notifier).music =
          musicModel.toRadioMusicModel;
    });

    socket!.onDisconnect((x) {
      print('socketio disconnect $x');
      socket!.clearListeners();
      socket = null;
      audioPlayer.stop();
    });

    socket!.onError((e) {
      print('socketio error $e');
      status = RadioLiveStatus.error;
    });
  }

  void addChat(String message) {
    socket?.emit('chat', {
      'message': message,
    });
  }

  void addStory({
    required String content,
    required String userName,
  }) {
    socket?.emit('story', {
      'user_name': userName,
      'title': '사연',
      'content': content,
    });
  }

  Future<void> playTTS(
    RadioTTSModel tts, {
    bool directPlay = true,
  }) async {
    audioPlayer.setVolume(1.0);
    final diff = DateTime.now().difference(tts.timestamp);
    print("playTTS diff: $diff");
    if (directPlay) {
      if (audioPlayer.playerState.playing) {
        await audioPlayer.stop();
      }
      await audioPlayer.setUrl(tts.ttsContentUrl);
      await audioPlayer.play();
      return;
    } else {
      if (diff.inMilliseconds < tts.durationMs - 100) {
        if (audioPlayer.playerState.playing) {
          await audioPlayer.stop();
        }
        await audioPlayer.setUrl(tts.ttsContentUrl);
        await audioPlayer.seek(diff).then((_) => audioPlayer.play());
      }
    }
  }

  Future<void> playMusic(
    RadioMusicModel music, {
    bool directPlay = true,
  }) async {
    ref.read(willPlayMusicProvider(broadcastId).notifier).music = null;
    audioPlayer.setVolume(0.5);
    final diff = DateTime.now().difference(music.timestamp);
    print("playMusic diff: $diff");
    if (directPlay) {
      if (audioPlayer.playerState.playing) {
        await audioPlayer.stop();
      }
      await audioPlayer.setUrl(music.contentUrl);
      await audioPlayer.play();
    } else {
      if (diff.inMilliseconds < 3000) {
        if (audioPlayer.playerState.playing) {
          await audioPlayer.stop();
        }
        await audioPlayer.setUrl(music.contentUrl);
        await audioPlayer.seek(diff).then((_) => audioPlayer.play());
      }
    }
  }

  Future<void> disconnect() async {
    socket?.disconnect();
    socket?.close();
    while (socket != null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    ref.read(radioLiveBroadcastsProvider.notifier).fetch();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
