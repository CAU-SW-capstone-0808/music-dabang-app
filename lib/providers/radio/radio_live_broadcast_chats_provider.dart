import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/models/radio/radio_chat_model.dart';
import 'package:music_dabang/repository/radio_repository.dart';
import 'package:synchronized/synchronized.dart';

final radioLiveBroadcastChatsProvider = StateNotifierProviderFamily<
    RadioLiveBroadcastChatsProvider, List<RadioChatModel>, int>(
  (ref, broadcastId) {
    return RadioLiveBroadcastChatsProvider(
      broadcastId: broadcastId,
      radioRepository: ref.watch(radioRepositoryProvider),
    );
  },
);

/// 1. 최초 접속 시 채팅 목록을 가져옴
/// 2. 이후 채팅이 추가될 때마다 채팅 목록을 갱신
class RadioLiveBroadcastChatsProvider
    extends StateNotifier<List<RadioChatModel>> {
  final int broadcastId;
  final RadioRepository radioRepository;
  final _lock = Lock();

  RadioLiveBroadcastChatsProvider({
    required this.broadcastId,
    required this.radioRepository,
  }) : super([]);

  Future<List<RadioChatModel>> fetch() async {
    var chats =
        await radioRepository.getBroadcastChats(broadcastId: broadcastId);
    return state = [...chats.reversed];
  }

  /// 실제 전송은 웹소켓을 통함
  Future<void> addChat(RadioChatModel chat) async {
    await _lock.synchronized(() async {
      if (state.isEmpty || chat.id > state.first.id) {
        state = [chat, ...state];
      }
    });
  }
}
