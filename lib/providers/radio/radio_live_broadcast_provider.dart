import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/broadcast_model.dart';
import 'package:music_dabang/models/radio/radio_channel_model.dart';
import 'package:music_dabang/providers/radio/radio_channels_provider.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcasts_provider.dart';

/// 라이브 연결 상태
enum RadioLiveStatus {
  none, // 초기화 상태
  yet, // 연결 시작 전, 객체만 보유한 상태
  connecting, // 연결 중
  connected, // 연결 완료
  disconnected, // 연결 종료
  error; // 연결 중

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
    await _connect();
  }

  Future<void> _connect() async {
    await Future.delayed(const Duration(seconds: 2));
    status = RadioLiveStatus.connecting;
    await Future.delayed(const Duration(seconds: 2));
    status = RadioLiveStatus.connected;
  }
}
