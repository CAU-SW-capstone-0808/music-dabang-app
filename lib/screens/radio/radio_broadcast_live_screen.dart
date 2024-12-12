import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/providers/radio/radio_live_broadcast_provider.dart';

class RadioBroadcastLiveScreen extends ConsumerStatefulWidget {
  static const routeName = 'radio-broadcast-live';

  final int broadcastId;

  const RadioBroadcastLiveScreen({super.key, required this.broadcastId});

  @override
  ConsumerState<RadioBroadcastLiveScreen> createState() =>
      _RadioBroadcastLiveScreenState();
}

class _RadioBroadcastLiveScreenState
    extends ConsumerState<RadioBroadcastLiveScreen> {
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
    String labelContent = "$hours시간 $minutes분 ";
    return Text(
      labelContent,
      style: const TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
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

    return GestureDetector(
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
                  listeners(100),
                  const Spacer(),
                  timeLabel(100),
                  const SizedBox(width: 8.0),
                ],
              ),
              const SizedBox(height: 8.0),
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: liveStatus == RadioLiveStatus.connected
                            ? MediaQuery.of(context).size.width / 4 + 22
                            : 0,
                      ),
                      itemExtent: 164,
                      scrollDirection: Axis.horizontal,
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        if (liveStatus != RadioLiveStatus.connected) {
                          return Container();
                        }
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: ColorTable.boxShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://image.genie.co.kr/Y/IMAGE/IMG_ALBUM/082/638/032/82638032_1651479062721_1_600x600.JPG',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Polaroid',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '임영웅',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        );
                      },
                    ),
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
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: 100,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/202412/10/826b1850-b665-4e10-ac17-7aa5b37f2bd8.jpg',
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    "임영웅",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12.0),
                                    bottomLeft: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: ColorTable.stroke,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  "어머 노래가 너무 좋아요! " * 1,
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: sendStoryButton(onPressed: () {}),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0, thickness: 1),
              TextField(
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '채팅 입력...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    onPressed: () {},
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
    );
  }
}
