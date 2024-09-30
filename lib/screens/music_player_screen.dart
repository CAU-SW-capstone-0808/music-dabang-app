import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/components/cached_image.dart';
import 'package:music_dabang/components/playing_music_bar.dart';
import 'package:music_dabang/models/music/music_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/my_music_list_provider.dart';
import 'package:music_dabang/screens/components/playlist_panel.dart';
import 'package:video_player/video_player.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController musicPlayerAnimationController;
  final panelController = SlidingUpPanelController();

  CurrentPlayingMusicStateNotifier get musicNotifier =>
      ref.read(currentPlayingMusicProvider.notifier);

  CurrentPlayingPlaylistStateNotifier get playlistNotifier =>
      ref.read(currentPlaylistProvider.notifier);

  /// [중앙 미디어 위젯]
  /// target : 30px horizontal padding
  Widget centerMedia({
    required double size,
    String? imageUrl,
    bool showingVideo = false,
    bool hasMusicVideo = true,
  }) {
    final albumWidth = MediaQuery.of(context).size.width * size - 60;
    late Widget innerWidget;
    if (showingVideo) {
      final videoController = musicNotifier.videoPlayerController;
      if (videoController?.value.isInitialized ?? false) {
        innerWidget = SizedBox(
          height: albumWidth,
          child: Center(
            child: AspectRatio(
              aspectRatio: videoController!.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          ),
        );
      } else {
        innerWidget = SizedBox(height: albumWidth);
      }
    } else {
      innerWidget = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imageUrl != null
            ? CachedImage(
                imageUrl,
                width: albumWidth,
                height: albumWidth,
              )
            : Container(
                color: ColorTable.backGrey,
                width: albumWidth,
                height: albumWidth,
              ),
      );
    }
    if (hasMusicVideo && size > 0.8) {
      Widget mvButton = Opacity(
        opacity: (size - 0.8) / 0.2,
        child: Theme(
          data: ThemeData(
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 24,
            ),
          ),
          child: AnimatedToggleSwitch<bool>.dual(
            current: showingVideo,
            first: false,
            second: true,
            onChanged: (value) async {
              await ref
                  .read(currentPlayingMusicProvider.notifier)
                  .toggleAudioVideo(value);
            },
            textBuilder: (value) {
              return Text(
                value ? '뮤직비디오 재생 중' : '뮤직비디오 보기',
                style: const TextStyle(
                  fontSize: 18.0,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
            iconBuilder: (value) => SvgPicture.asset(
              value
                  ? 'assets/icons/music_video_icon.svg'
                  : 'assets/icons/music_lyric_icon.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            borderWidth: 0,
            height: 50,
            spacing: 120,
            indicatorSize: const Size.fromWidth(50),
            style: ToggleStyle(
              backgroundColor: Colors.white,
              indicatorColor: ColorTable.kPrimaryColor,
              indicatorBorder: Border.all(
                color: Colors.white,
                width: 4,
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
          ),
        ),
      );
      return Stack(
        children: [
          Center(child: innerWidget),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BouncingWidget(child: mvButton),
            ),
          ),
        ],
      );
    } else {
      return innerWidget;
    }
  }

  /// 주의: 파이어베이스 로깅만을 위한 변수. 이해하기 번거로우면 지울 것.
  bool _touchedToChangeMusicPlayer = false;
  Widget topTitle(String title) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() => _touchedToChangeMusicPlayer = true);
              ref.read(musicPlayerStatusProvider.notifier).collapse();
              AidolUtils.d('music_player collapse:touch');
              panelController.collapse();
              FirebaseLogger.changeMusicPlayerStatus(
                musicPlayerStatus: 'collapse',
                userAction: 'touch',
              );
            },
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
                  // colorFilter: const ColorFilter.mode(
                  //   ColorTable.kPrimaryColor,
                  //   BlendMode.srcIn,
                  // ),
                ),
                text: '내음악에 추가',
                onPressed: () async {
                  if (currentMusic != null) {
                    await ref
                        .read(myMusicListProvider.notifier)
                        .addItem(musicId: currentMusic.id);
                    AidolUtils.showToast('내음악에 추가되었습니다.');
                    _logEvent('add_to_my_music');
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
                onPressed: () {
                  _logEvent('show_lyrics');
                  AidolUtils.showToast('가사보기는 아직 지원되지 않습니다.');
                },
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
              onTap: skipPrevious,
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
              onPressed: togglePlay,
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
              onTap: skipNext,
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

  void _logEvent(String action) {
    var currentPosition = musicNotifier.currentPosition;
    var currentMusic = ref.read(currentPlayingMusicProvider);
    var currentPlaylist = ref.read(currentPlaylistProvider);
    var musicPlayerStatus = ref.read(musicPlayerStatusProvider);
    FirebaseLogger.touchMusicPlayerAction(
      action: action,
      musicId: currentMusic?.id,
      musicTitle: currentMusic?.title,
      musicContentType: currentMusic?.musicContentType.name,
      artistName: currentMusic?.artist.name,
      playlistId: currentPlaylist?.id,
      playlistName: currentPlaylist?.name,
      position: currentPosition,
      playerExpanded: musicPlayerStatus.full,
    );
  }

  void skipNext() async {
    final item = await playlistNotifier.skipNext();
    if (item == null) {
      AidolUtils.showToast('다음 곡이 없습니다.');
    }
    _logEvent('skip_next');
  }

  void skipPrevious() async {
    // 3초 이상이면 처음으로, 아니면 이전곡
    var currentPosition = musicNotifier.currentPosition;
    if (currentPosition.inMilliseconds > 3000) {
      musicNotifier.seekAudio(Duration.zero);
    } else {
      final item = await playlistNotifier.skipPrevious();
      // 이전곡이 없으면 처음으로
      if (item == null) {
        musicNotifier.seekAudio(Duration.zero);
        AidolUtils.showToast('첫 번째 곡입니다.');
      }
    }
    _logEvent('skip_previous');
  }

  void togglePlay() {
    musicNotifier.togglePlay();
    _logEvent('toggle_play');
  }

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
    final mpStatus = ref.watch(musicPlayerStatusProvider);

    ref.listen(musicPlayerStatusProvider, (prev, next) {
      if (prev != next) {
        if (_touchedToChangeMusicPlayer) {
          _touchedToChangeMusicPlayer = false;
          return;
        }
        if (next.full) {
          if (prev != null && prev.full) {
            return;
          }
          if (panelController.status != SlidingUpPanelStatus.expanded) {
            panelController.expand();
            AidolUtils.d('music_player expand:auto');
            FirebaseLogger.changeMusicPlayerStatus(
              musicPlayerStatus: 'expand',
              userAction: 'auto',
            );
          }
        } else {
          if (panelController.status != SlidingUpPanelStatus.collapsed) {
            panelController.collapse();
            AidolUtils.d('music_player collapse:auto');
            FirebaseLogger.changeMusicPlayerStatus(
              musicPlayerStatus: 'collapse',
              userAction: 'auto',
            );
          }
        }
      }
    });

    return SlidingUpPanelWidget(
      panelController: panelController,
      animationController: musicPlayerAnimationController,
      controlHeight: currentPlaying != null ? 90 : 0,
      // controlHeight: 90,
      enableOnTap: false,
      anchor: 1.0,
      upperBound: 1.0,
      onStatusChanged: (status) {
        // print('status: $status');
        var mpStatus = ref.read(musicPlayerStatusProvider);
        if (status == SlidingUpPanelStatus.collapsed) {
          if (mpStatus != MusicDabangPlayerState.collapsed) {
            // 드래그에 의해 닫힌 경우
            AidolUtils.d('music_player collapse:drag');
            ref.read(musicPlayerStatusProvider.notifier).status =
                MusicDabangPlayerState.collapsed;
            // 파이어베이스 로깅
            FirebaseLogger.changeMusicPlayerStatus(
              musicPlayerStatus: 'collapse',
              userAction: 'drag',
            );
          }
        } else if (status == SlidingUpPanelStatus.anchored ||
            status == SlidingUpPanelStatus.expanded) {
          // 드래그에 의해 확장된 경우
          if (mpStatus != MusicDabangPlayerState.expanded &&
              mpStatus != MusicDabangPlayerState.expandedWithPlaylist) {
            AidolUtils.d('music_player($mpStatus) expand:drag');
            ref.read(musicPlayerStatusProvider.notifier).status =
                MusicDabangPlayerState.expanded;
            // 파이어베이스 로깅
            FirebaseLogger.changeMusicPlayerStatus(
              musicPlayerStatus: 'expand',
              userAction: 'drag',
            );
          } else if (mpStatus == MusicDabangPlayerState.expandedWithPlaylist) {
            ref.read(musicPlayerStatusProvider.notifier).status =
                MusicDabangPlayerState.expanded;
          }
        }
      },
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: musicPlayerAnimationController,
            builder: (context, child) {
              final musicPlayerSize = musicPlayerAnimationController.value;
              final musicPlayerHeight =
                  musicPlayerSize * MediaQuery.of(context).size.height;
              bool musicPlayerSizeOver0_25 = musicPlayerSize > 0.25;
              return Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (musicPlayerSizeOver0_25)
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: topTitle(currentPlaying?.title ?? '-'),
                          ),
                          const SizedBox(height: 4.0),
                          artistName(currentPlaying?.artist.name ?? ''),
                          const SizedBox(height: 8.0),
                          if (musicPlayerSizeOver0_25)
                            centerMedia(
                              size: musicPlayerSize,
                              imageUrl: currentPlaying?.thumbnailUrl,
                              showingVideo: isPlayingVideo,
                              hasMusicVideo:
                                  currentPlaying?.videoContentUrl != null,
                            ),
                          // Expanded(
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(24),
                          //     child: currentPlaying?.thumbnailUrl != null
                          //         ? CachedImage(currentPlaying!.thumbnailUrl)
                          //         : Container(color: ColorTable.backGrey),
                          //   ),
                          // ),
                        ],
                      ),
                    StreamBuilder(
                      stream: musicNotifier.playerStateStream,
                      builder: (context, playerStateAsync) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() => _touchedToChangeMusicPlayer = true);
                            ref
                                .read(musicPlayerStatusProvider.notifier)
                                .expand();
                            panelController.expand();
                            AidolUtils.d('music_player exapnd:touch');
                            FirebaseLogger.changeMusicPlayerStatus(
                              musicPlayerStatus: 'expand',
                              userAction: 'touch',
                            );
                          },
                          child: PlayingMusicBar(
                            isPlaying: playerStateAsync.data?.playing ?? false,
                            title: currentPlaying?.title ?? '음악 재생 대기 중',
                            artist: currentPlaying?.artist.name ?? '',
                            height: musicPlayerHeight,
                            size: musicPlayerSize,
                            onPrevious: () {
                              skipPrevious();
                            },
                            onPlay: togglePlay,
                            onNext: skipNext,
                          ),
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
                              Expanded(child: middleButtons(currentPlaying)),
                              // seeLyricButton,
                              const SizedBox(height: 12.0),
                              StreamBuilder(
                                stream: musicNotifier.durationStream,
                                builder: (context, maxDuration) {
                                  return StreamBuilder(
                                    stream: musicNotifier.positionStream,
                                    builder: (context, curDuration) {
                                      return progressBar(
                                        curMilliSec:
                                            curDuration.data?.inMilliseconds ??
                                                0,
                                        maxMilliSec:
                                            maxDuration.data?.inMilliseconds ??
                                                0,
                                      );
                                    },
                                  );
                                },
                              ),
                              Expanded(
                                flex: 2,
                                child: StreamBuilder(
                                  stream: musicNotifier.playerStateStream,
                                  builder: (context, playerStateAsync) {
                                    return bottomButtonGroup(
                                      isPlaying:
                                          playerStateAsync.data?.playing ??
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
          if (mpStatus.full)
            PlaylistPanel(
              viewPadding: MediaQuery.of(context).viewPadding,
            ),
        ],
      ),
    );
  }
}
