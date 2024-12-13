import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/datetime_utils.dart';
import 'package:music_dabang/components/bouncing_widget.dart';

class RadioLiveCard extends StatelessWidget {
  final String title; // 방송 제목
  final String channelTitle; // 채널 제목
  final String channelImage; // 채널 이미지
  final int listenerCount; // 청취자 수
  final String status; // 방송 상태
  final DateTime startedAt;
  final void Function() onPressed;

  const RadioLiveCard({
    super.key,
    required this.title,
    required this.channelTitle,
    required this.channelImage,
    required this.listenerCount,
    required this.status,
    required this.startedAt,
    required this.onPressed,
  });

  Widget get listeners {
    return Row(
      children: [
        const Icon(
          Icons.person,
          size: 16.0,
          color: ColorTable.red2,
        ),
        const SizedBox(width: 4.0),
        Text(
          listenerCount.toString(),
          style: const TextStyle(
            fontSize: 14.0,
            color: ColorTable.red2,
          ),
        ),
      ],
    );
  }

  Widget get timeLabel {
    return Text(
      elapsedTime(startedAt),
      style: const TextStyle(
        fontSize: 14.0,
        color: ColorTable.textGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: ColorTable.boxShadow2,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                listeners,
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: [
                    if (channelImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: channelImage,
                          width: 32,
                          height: 32,
                        ),
                      )
                    else
                      const SizedBox(width: 32, height: 32),
                    const SizedBox(width: 8.0),
                    Text(channelTitle),
                  ],
                ),
                const Spacer(),
                timeLabel,
              ],
            )
          ],
        ),
      ),
    );
  }
}
