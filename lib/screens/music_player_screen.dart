import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/components/playing_music_bar.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/my_music_list_provider.dart';
import 'package:video_player/video_player.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  final SlidingUpPanelController panelController;

  const MusicPlayerScreen({
    super.key,
    required this.panelController,
  });

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController musicPlayerAnimationController;
  final _playlistPanelController = SlidingUpPanelController();

  CurrentPlayingMusicStateNotifier get musicNotifier =>
      ref.read(currentPlayingMusicProvider.notifier);

  CurrentPlayingPlaylistStateNotifier get playlistNotifier =>
      ref.read(currentPlaylistProvider.notifier);

  /// target : 30px horizontal padding
  Widget albumImage({
    required double size,
    String? imageUrl,
    bool showingVideo = false,
    bool hasMusicVideo = true,
  }) {
    final albumWidth = MediaQuery.of(context).size.width * size - 60;
    late Widget innerWidget;
    if (showingVideo) {
      final videoController = musicNotifier.videoPlayerController;
      innerWidget = (videoController?.value.isInitialized ?? false)
          ? SizedBox(
              height: albumWidth,
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoController!.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            )
          : Container();
    } else {
      innerWidget = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                width: albumWidth,
                height: albumWidth,
                fit: BoxFit.cover,
              )
            : Container(
                color: ColorTable.backGrey,
                width: albumWidth,
                height: albumWidth,
              ),
      );
    }
    if (hasMusicVideo && size > 0.8) {
      var mvButton = BouncingWidget(
        onPressed: () async {
          await musicNotifier.toggleAudioVideo(!showingVideo);
          setState(() {});
        },
        child: Opacity(
          opacity: (size - 0.8) / 0.2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    padding: const EdgeInsets.all(7.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorTable.palePink,
                    ),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: SvgPicture.asset(
                        'assets/icons/music_video_icon.svg',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9.0),
                const Text(
                  '뮤직비디오 보기',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12.0),
              ],
            ),
          ),
        ),
      );
      return Stack(
        children: [
          Center(child: innerWidget),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: mvButton,
          //   ),
          // ),
        ],
      );
    } else {
      return innerWidget;
    }
  }

  Widget topTitle(String title) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => widget.panelController.collapse(),
            icon: Transform.rotate(
              angle: 3.141592 / 2,
              child: const Icon(
                Symbols.arrow_forward_ios_rounded,
                fill: 1,
                weight: 400,
                grade: 0.25,
                opticalSize: 24,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.transparent,
            ),
          ),
        ],
      );

  Widget middleButtons(MusicModel? currentMusic) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: iconWithTextButton(
                icon: SvgPicture.asset(
                  'assets/icons/playlists_icon.svg',
                  width: 48,
                  height: 48,
                ),
                text: '내음악에 추가',
                onPressed: () async {
                  if (currentMusic != null) {
                    await ref
                        .read(myMusicListProvider.notifier)
                        .addItem(musicId: currentMusic.id);
                    Fluttertoast.showToast(msg: '내음악에 추가되었습니다.');
                  }
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: iconWithTextButton(
                icon: SvgPicture.asset(
                  'assets/icons/music_lyric_icon.svg',
                  width: 48,
                  height: 48,
                ),
                text: '가사보기',
                onPressed: () {},
              ),
            ),
          ],
        ),
      );

  Widget artistName(String name) => Text(
        name,
        style: const TextStyle(
          fontSize: 22.0,
        ),
      );

  Widget bottomButtonGroup({required bool isPlaying}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // InkWell(
          //   borderRadius: BorderRadius.circular(12),
          //   onTap: () {},
          //   child: Ink(
          //     padding: const EdgeInsets.all(12.0),
          //     child: Column(
          //       children: [
          //         SvgPicture.asset(
          //           'assets/icons/shuffle_icon.svg',
          //           width: 24,
          //           height: 24,
          //         ),
          //         const Text(
          //           "섞기",
          //           style: TextStyle(
          //             fontSize: 15.0,
          //             height: 1.25,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const Spacer(),
          withLabel(
            text: '이전곡',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                // 3초 이상이면 처음으로, 아니면 이전곡
                if (musicNotifier.currentPosition.inMilliseconds > 3000) {
                  musicNotifier.seekAudio(Duration.zero);
                } else {
                  final item = await playlistNotifier.skipPrevious();
                  // 이전곡이 없으면 처음으로
                  if (item == null) {
                    musicNotifier.seekAudio(Duration.zero);
                    Fluttertoast.showToast(msg: '첫 번째 곡입니다.');
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 18.0,
                ),
                child: SvgPicture.asset(
                  'assets/icons/play_prev_icon.svg',
                  width: 60,
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    ColorTable.iconBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          withLabel(
            text: '재생',
            child: BouncingWidget(
              onPressed: () {
                musicNotifier.togglePlay();
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTable.kPrimaryColor,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 48.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          withLabel(
            text: '다음곡',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                final item = await playlistNotifier.skipNext();
                if (item == null) {
                  Fluttertoast.showToast(msg: '다음 곡이 없습니다.');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 18.0,
                ),
                child: SvgPicture.asset(
                  'assets/icons/play_next_icon.svg',
                  width: 60,
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    ColorTable.iconBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // InkWell(
          //   borderRadius: BorderRadius.circular(12),
          //   onTap: () {},
          //   child: Ink(
          //     padding: const EdgeInsets.all(12.0),
          //     child: Column(
          //       children: [
          //         SvgPicture.asset(
          //           'assets/icons/repeat_icon.svg',
          //           width: 24,
          //           height: 24,
          //         ),
          //         const Text(
          //           "반복",
          //           style: TextStyle(
          //             fontSize: 15.0,
          //             height: 1.25,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      );

  Widget get seeLyricButton => Padding(
        padding: const EdgeInsets.all(16.0),
        child: BouncingWidget(
          onPressed: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.24),
                  offset: Offset.zero,
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: const Offset(0, 1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '가사 보기',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
      );

  Widget iconWithTextButton({
    required Widget? icon,
    required String text,
    required void Function()? onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.0),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              offset: Offset.zero,
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 1),
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) Expanded(child: icon),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18.0,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget progressBar({
    required int maxMilliSec,
    required int curMilliSec,
  }) {
    int maxSec = maxMilliSec ~/ 1000;
    int curSec = curMilliSec ~/ 1000;
    return Column(
      children: [
        Slider(
          value: curMilliSec.toDouble(),
          min: 0,
          max: maxMilliSec.toDouble() + 20, // 오차로 인한 20ms의 여백
          onChanged: (double value) {
            print('value: $value');
            musicNotifier.seekAudio(Duration(milliseconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${curSec ~/ 60}:${(curSec % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 15.0,
                  height: 1.25,
                ),
              ),
              Text(
                "${maxSec ~/ 60}:${(maxSec % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 15.0,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget withLabel({
    required String text,
    required Widget child,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: child),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    musicPlayerAnimationController =
        SlidingUpPanelWidget.createAnimationController(this);
    // musicPlayerAnimationController.addListener(() {
    //   print('value: ${musicPlayerAnimationController.value}');
    // });
  }

  @override
  Widget build(BuildContext context) {
    final currentPlaying = ref.watch(currentPlayingMusicProvider);
    bool isPlayingVideo = ref.watch(musicPlayerShowingVideoProvider);

    return SlidingUpPanelWidget(
      panelController: widget.panelController,
      animationController: musicPlayerAnimationController,
      controlHeight: currentPlaying != null ? 90 : 0,
      enableOnTap: true,
      onTap: () {
        if (widget.panelController.status == SlidingUpPanelStatus.collapsed) {
          widget.panelController.expand();
        }
      },
      onStatusChanged: (status) {
        // print('status: $status');
        if (status == SlidingUpPanelStatus.collapsed) {
          ref.read(musicPlayerExpandedProvider.notifier).expanded = false;
        } else if (status == SlidingUpPanelStatus.anchored ||
            status == SlidingUpPanelStatus.expanded) {
          ref.read(musicPlayerExpandedProvider.notifier).expanded = true;
        }
      },
      anchor: 1.0,
      child: currentPlaying == null
          ? Container()
          : PopScope(
              canPop: _playlistPanelController.status ==
                  SlidingUpPanelStatus.collapsed,
              onPopInvokedWithResult: (_, __) {
                if (_playlistPanelController.status !=
                    SlidingUpPanelStatus.collapsed) {
                  _playlistPanelController.collapse();
                }
              },
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _playlistPanelController.collapse(),
                    child: AnimatedBuilder(
                      animation: musicPlayerAnimationController,
                      builder: (context, child) {
                        final musicPlayerSize =
                            musicPlayerAnimationController.value;
                        final musicPlayerHeight = musicPlayerSize *
                            MediaQuery.of(context).size.height;
                        bool musicPlayerSizeOver0_25 = musicPlayerSize > 0.25;
                        return Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (musicPlayerSizeOver0_25)
                                SafeArea(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: topTitle(
                                            currentPlaying?.title ?? '-'),
                                      ),
                                      const SizedBox(height: 4.0),
                                      artistName(
                                          currentPlaying?.artist.name ?? ''),
                                      const SizedBox(height: 8.0),
                                      if (musicPlayerSizeOver0_25)
                                        albumImage(
                                          size: musicPlayerSize,
                                          imageUrl:
                                              currentPlaying?.thumbnailUrl,
                                          showingVideo: isPlayingVideo,
                                        ),
                                    ],
                                  ),
                                ),
                              StreamBuilder(
                                stream: musicNotifier.playerStateStream,
                                builder: (context, playerStateAsync) {
                                  return PlayingMusicBar(
                                    isPlaying:
                                        playerStateAsync.data?.playing ?? false,
                                    title:
                                        currentPlaying?.title ?? '음악 재생 대기 중',
                                    artist: currentPlaying?.artist.name ?? '',
                                    height: musicPlayerHeight,
                                    size: musicPlayerSize,
                                    onPrevious: () {
                                      playlistNotifier.skipPrevious();
                                    },
                                    onPlay: () {
                                      musicNotifier.togglePlay();
                                    },
                                    onNext: () {
                                      playlistNotifier.skipNext();
                                    },
                                  );
                                },
                              ),
                              if (musicPlayerSizeOver0_25)
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: <Widget>[
                                        const SizedBox(height: 20),
                                        Expanded(
                                            child:
                                                middleButtons(currentPlaying)),
                                        // seeLyricButton,
                                        const SizedBox(height: 12.0),
                                        StreamBuilder(
                                          stream: musicNotifier.durationStream,
                                          builder: (context, maxDuration) {
                                            return StreamBuilder(
                                              stream:
                                                  musicNotifier.positionStream,
                                              builder: (context, curDuration) {
                                                return progressBar(
                                                  curMilliSec: curDuration.data
                                                          ?.inMilliseconds ??
                                                      0,
                                                  maxMilliSec: maxDuration.data
                                                          ?.inMilliseconds ??
                                                      0,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: StreamBuilder(
                                            stream:
                                                musicNotifier.playerStateStream,
                                            builder:
                                                (context, playerStateAsync) {
                                              return bottomButtonGroup(
                                                isPlaying: playerStateAsync
                                                        .data?.playing ??
                                                    false,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 60),

                                        // const SizedBox(height: 42.0),
                                        // Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //     vertical: 12.5,
                                        //   ),
                                        //   decoration: const BoxDecoration(
                                        //     color: ColorTable.palePink,
                                        //     borderRadius: BorderRadius.only(
                                        //       topLeft: Radius.circular(24),
                                        //       topRight: Radius.circular(24),
                                        //     ),
                                        //   ),
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.center,
                                        //     children: [
                                        //       SvgPicture.asset(
                                        //         'assets/icons/playlist_icon.svg',
                                        //         width: 32,
                                        //         height: 32,
                                        //       ),
                                        //       const SizedBox(width: 8.0),
                                        //       const Text(
                                        //         '재생목록',
                                        //         style: TextStyle(
                                        //           fontSize: 18.0,
                                        //           fontWeight: FontWeight.w600,
                                        //           height: 1.25,
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SlidingUpPanelWidget(
                    controlHeight: 60,
                    anchor: 0.8,
                    panelController: _playlistPanelController,
                    onTap: () {
                      if (_playlistPanelController.status ==
                              SlidingUpPanelStatus.collapsed ||
                          _playlistPanelController.status ==
                              SlidingUpPanelStatus.expanded) {
                        _playlistPanelController.anchor();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.24),
                            offset: Offset.zero,
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            offset: const Offset(0, 1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              var panelStatus = _playlistPanelController.status;
                              if (panelStatus ==
                                  SlidingUpPanelStatus.collapsed) {
                                _playlistPanelController.anchor();
                              } else if (panelStatus ==
                                      SlidingUpPanelStatus.expanded ||
                                  panelStatus ==
                                      SlidingUpPanelStatus.anchored) {
                                _playlistPanelController.collapse();
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              width: double.infinity,
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/playlist_icon.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Text(
                                    '재생목록',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(20, (index) {
                                  return ListTile(
                                    title: Text('title $index'),
                                    subtitle: Text('subtitle $index'),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
