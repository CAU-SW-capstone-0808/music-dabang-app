import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/dialog.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcast_provider.dart';
import 'package:music_dabang/providers/user/user_provider.dart';
import 'package:music_dabang/screens/radio/components/live_chatting_list.dart';
import 'package:music_dabang/screens/radio/components/live_music_list.dart';

class RadioBroadcastLiveScreen extends ConsumerStatefulWidget {
  static const routeName = 'radio-broadcast-live';

  final int broadcastId;
  final int channelId;

  const RadioBroadcastLiveScreen({
    super.key,
    required this.broadcastId,
    required this.channelId,
  });

  @override
  ConsumerState<RadioBroadcastLiveScreen> createState() =>
      _RadioBroadcastLiveScreenState();
}

class _RadioBroadcastLiveScreenState
    extends ConsumerState<RadioBroadcastLiveScreen> {
  final chatController = TextEditingController();

  RadioLiveBroadcastProvider get _radioLiveBroadcastProvider =>
      ref.read(radioLiveBroadcastProvider(widget.broadcastId).notifier);

  Widget get loadingPage => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 16.0),
          Text(
            "연결 중입니다. 잠시만 기다려주세요.",
            style: TextStyle(
              fontSize: 22.0,
              color: ColorTable.textInfoColor,
            ),
          ),
        ],
      );

  Widget get errorPage => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outlined,
            size: 48.0,
            color: ColorTable.textInfoColor,
          ),
          const SizedBox(height: 8.0),
          const Text(
            "오류가 발생했습니다. 다시 시도해주세요.",
            style: TextStyle(
              fontSize: 22.0,
              color: ColorTable.textInfoColor,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _radioLiveBroadcastProvider.init();
            },
            child: const Text("다시 시도"),
          ),
        ],
      );

  Widget listeners(int listenerCount) {
    if (listenerCount < 0) {
      return Container();
    }
    return Row(
      children: [
        const Icon(
          Icons.person,
          size: 18.0,
          color: ColorTable.red2,
        ),
        const SizedBox(width: 4.0),
        Text(
          listenerCount.toString(),
          style: const TextStyle(
            fontSize: 16.0,
            color: ColorTable.red2,
          ),
        ),
      ],
    );
  }

  Widget timeLabel(int elapsedMinutes) {
    int hours = elapsedMinutes ~/ 60;
    int minutes = elapsedMinutes % 60;
    String labelContent = "";
    if (hours > 0) {
      labelContent += "$hours시간 ";
    }
    labelContent =
        "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
    return Row(
      children: <Widget>[
        Text(
          labelContent,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4.0),
        const Icon(Icons.access_time_rounded, size: 18.0),
      ],
    );
  }

  Widget sendStoryButton({required void Function() onPressed}) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: ColorTable.kPrimaryColor,
                width: 1.0,
              ),
              boxShadow: ColorTable.boxShadow2,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '사연 보내기',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(width: 4.0),
                Icon(
                  Icons.post_add_rounded,
                  color: ColorTable.kPrimaryColor,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    await _radioLiveBroadcastProvider.init();
  }

  void sendChat() {
    String message = chatController.value.text;
    if (message.isEmpty) {
      return;
    }
    _radioLiveBroadcastProvider.addChat(message);
    chatController.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(radioLiveBroadcastProvider(widget.broadcastId));
    final liveStatus = liveState.status;
    final liveBroadcast = liveState.broadcast;
    final liveChannel = liveState.channel;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _radioLiveBroadcastProvider.disconnect();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: liveChannel != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: liveChannel.channelImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : null,
            title: Text(liveBroadcast != null ? liveBroadcast.title : '라디오 방송'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(CupertinoIcons.xmark),
              )
            ],
          ),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8.0),
                    listeners(liveBroadcast?.listenerCount ?? -1),
                    const Spacer(),
                    timeLabel(liveBroadcast?.elapsedMinutes ?? 0),
                    const SizedBox(width: 8.0),
                  ],
                ),
                const SizedBox(height: 8.0),
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      child: LiveMusicList(broadcastId: widget.broadcastId),
                    ),
                    if (liveStatus.isLoading)
                      Positioned.fill(child: loadingPage)
                    else if (liveStatus == RadioLiveStatus.error)
                      Positioned.fill(child: errorPage),
                  ],
                ),
                const Divider(height: 0),
                Expanded(
                  child: Stack(
                    children: [
                      LiveChattingList(
                        broadcastId: widget.broadcastId,
                        channelId: widget.channelId,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: sendStoryButton(onPressed: () {
                          final me = ref.read(userProvider);
                          if (me is! UserModel) {
                            AidolUtils.showErrorToast(message: '로그인 후 이용해주세요.');
                            return;
                          }
                          showPromptDialog(
                            context: context,
                            infoText: '사연 보내기',
                            onConfirm: (value) {
                              if (value.isEmpty) {
                                return;
                              }
                              _radioLiveBroadcastProvider.addStory(
                                content: value,
                                userName: me.nickname,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0, thickness: 1),
                TextField(
                  controller: chatController,
                  maxLines: 1,
                  onSubmitted: (_) => sendChat(),
                  decoration: InputDecoration(
                    hintText: '채팅 입력...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16.0),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      onPressed: sendChat,
                      icon: Transform.rotate(
                        angle: -3.14 / 5,
                        child: const Icon(
                          Icons.send_rounded,
                          color: ColorTable.kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
