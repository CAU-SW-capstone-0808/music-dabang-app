import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';

/// 실행 중인 음악 (하단 바)
class PlayingMusicBar extends StatelessWidget {
  final String title;
  final String artist;
  final bool isPlaying;

  final double? height;

  /// 스크롤 영역의 크기: 0.0 ~ 1.0
  /// 이에 따라 배치, 투명도가 변함.
  /// 0.15 ~ 0.25: 투명도 변화
  /// 0.25 ~ 1.0: 배치 변화
  final double size;

  final void Function()? onPrevious;
  final void Function()? onPlay;
  final void Function()? onNext;

  /// 음악의 진행도
  final double progress;

  const PlayingMusicBar({
    super.key,
    required this.title,
    required this.artist,
    this.height,
    this.isPlaying = false,
    this.size = 0.0,
    this.onPrevious,
    this.onPlay,
    this.onNext,
    this.progress = 0,
  });

  double? albumSize({required double deviceWidth}) {
    if (height != null) {
      return min(deviceWidth - 32, height! - 8);
    }
    return deviceWidth - 32;
  }

  bool get sizeOver0_15 => size > 0.15;

  bool get sizeOver0_25 => size > 0.25;

  double get textOpacity {
    if (size < 0.15) return 1.0;
    if (size < 0.25) return 1 - size / 0.25;
    return 0.0;
  }

  Color get backgroundColor {
    return ColorTable.backGrey;
    return Color.lerp(
          ColorTable.backGrey,
          Colors.white,
          1 - textOpacity,
        ) ??
        ColorTable.backGrey;
  }

  Widget albumImage({
    double? width = 96,
    double? height = 96,
  }) =>
      ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/example_album_image.jpg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );

  Widget get actionButtons {
    /// 아이콘 + 레이블
    Widget withLabel({
      required String label,
      required Widget child,
      void Function()? onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                child,
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18.0,
                    height: 1.25,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        withLabel(
          label: '이전곡',
          onTap: onPrevious,
          child: const Icon(
            Icons.skip_previous_rounded,
            size: 36.0,
            color: ColorTable.kPrimaryColor,
          ),
        ),
        withLabel(
          label: '  재생  ', // 사이즈를 맞추기 위한 공백
          onTap: onPlay,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 36.0,
            color: ColorTable.kPrimaryColor,
          ),
        ),
        withLabel(
          label: '다음곡',
          onTap: onNext,
          child: const Icon(
            Icons.skip_next_rounded,
            size: 36.0,
            color: ColorTable.kPrimaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final deviceWidth = MediaQuery.of(context).size.width;
    if (sizeOver0_25) return Container();
    // if (sizeOver0_25) {
    //   return Container(
    //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    //     decoration: BoxDecoration(color: backgroundColor),
    //     child: Row(
    //       children: [
    //         albumImage(
    //           width: albumSize(deviceWidth: deviceWidth),
    //           height: albumSize(deviceWidth: deviceWidth),
    //         ),
    //       ],
    //     ),
    //   );
    // }
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: textOpacity,
        // opacity: 1,
        child: Stack(
          children: [
            Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 4),
              decoration: BoxDecoration(color: backgroundColor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // albumImage(
                  //   width: albumSize(deviceWidth: deviceWidth),
                  //   height: albumSize(deviceWidth: deviceWidth),
                  // ),
                  // const SizedBox(width: 20.0),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              title,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 22.0,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            artist,
                            style: const TextStyle(
                              fontSize: 18.0,
                              height: 1.25,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actionButtons,
                ],
              ),
            ),
            Positioned(
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * progress,
                height: 8,
                decoration: const BoxDecoration(
                  color: ColorTable.kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
