import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/components/playing_music_bar.dart';
import 'package:music_dabang/providers/music_player_size_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  final void Function()? onToggle;

  const MusicPlayerScreen({
    super.key,
    this.onToggle,
  });

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  Widget get albumImage {
    final albumWidth = MediaQuery.of(context).size.width - 32;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/example_album_image.jpg',
        width: albumWidth,
        height: albumWidth,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget get topTitle => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: widget.onToggle,
            icon: const Icon(CupertinoIcons.chevron_down),
          ),
          const Text(
            "사랑은 늘 도망가",
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
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

  Widget get middleButtons => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: iconWithTextButton(
                icon: SvgPicture.asset(
                  'assets/icons/playlists_icon.svg',
                  width: 24,
                  height: 24,
                ),
                text: '내 음악에 추가',
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: iconWithTextButton(
                icon: null,
                text: '뮤직비디오',
                onPressed: () {},
              ),
            ),
          ],
        ),
      );

  Widget get artistName => Text(
        "임영웅",
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget iconWithTextButton({
    required Widget? icon,
    required String text,
    required void Function()? onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorTable.stroke,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 8.0)],
            Text(
              text,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget progressBar({
    required int maxSec,
    required int curSec,
  }) =>
      Column(
        children: [
          Slider(
            value: curSec.toDouble(),
            min: 0,
            max: maxSec.toDouble(),
            onChanged: (double value) {
              setState(() {});
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

  Widget withLabel({
    required String text,
    required Widget child,
  }) {
    return Column(
      children: [
        child,
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18.0,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicPlayerSize = ref.watch(musicPlayerSizeProvider);
    final musicPlayerHeight = ref.read(musicPlayerHeightProvider);
    bool musicPlayerSizeOver0_25 = musicPlayerSize > 0.25;
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (musicPlayerSizeOver0_25)
            Align(
              heightFactor: (musicPlayerSize - 0.25) / 0.75,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: topTitle,
                    ),
                    const SizedBox(height: 4.0),
                    artistName,
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          PlayingMusicBar(
            title: '사랑은 늘 도망가',
            artist: '임영웅',
            height: musicPlayerHeight,
            size: musicPlayerSize,
            onPlayerToggle: widget.onToggle,
            onPrevious: () {},
            onPlay: () {},
            onNext: () {},
          ),
          if (musicPlayerSizeOver0_25)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 18),
                    middleButtons,
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: BouncingWidget(
                    //     onPressed: () {},
                    //     child: Container(
                    //       width: double.infinity,
                    //       padding: const EdgeInsets.symmetric(vertical: 9.5),
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(12.0),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.24),
                    //             offset: Offset.zero,
                    //             blurRadius: 4,
                    //           ),
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.12),
                    //             offset: const Offset(0, 1),
                    //             blurRadius: 8,
                    //           ),
                    //         ],
                    //       ),
                    //       child: const Center(
                    //         child: Text(
                    //           '가사 보기',
                    //           style: TextStyle(
                    //             fontSize: 22.0,
                    //             fontWeight: FontWeight.bold,
                    //             height: 1.25,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const Text(
                    //   "내 아름다운 사람아",
                    //   style: TextStyle(
                    //     fontSize: 22.0,
                    //     fontWeight: FontWeight.bold,
                    //     height: 1.25,
                    //   ),
                    // ),
                    // Text(
                    //   "사랑이란 게 참 쓰린 거더라",
                    //   style: TextStyle(
                    //     fontSize: 18.0,
                    //     fontWeight: FontWeight.bold,
                    //     height: 1.25,
                    //     color: Colors.black.withOpacity(0.5),
                    //   ),
                    // ),
                    const Spacer(),
                    progressBar(
                      curSec: 61,
                      maxSec: 271,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              print('asd??');
                            },
                            child: Ink(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/shuffle_icon.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const Text(
                                    "섞기",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          withLabel(
                            text: '이전곡',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {},
                              child: const Icon(
                                Icons.skip_previous_rounded,
                                size: 80.0,
                                color: ColorTable.kPrimaryColor,
                              ),
                            ),
                          ),
                          withLabel(
                            text: '재생',
                            child: BouncingWidget(
                              onPressed: () {},
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: ColorTable.blueGradient45,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 48.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          withLabel(
                            text: '다음곡',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {},
                              child: const Icon(
                                Icons.skip_next_rounded,
                                size: 80.0,
                                color: ColorTable.kPrimaryColor,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              print('asd??');
                            },
                            child: Ink(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/repeat_icon.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const Text(
                                    "반복",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 42.0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
