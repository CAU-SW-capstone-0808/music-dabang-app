import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bouncing_widget.dart';

class RadioChannelCard extends StatelessWidget {
  final String channelTitle;
  final String channelImageUrl;
  final String description;
  final bool onLive;
  final int subscriberCount;
  final void Function() onPressed;

  const RadioChannelCard({
    super.key,
    required this.channelTitle,
    required this.channelImageUrl,
    required this.description,
    required this.onLive,
    required this.subscriberCount,
    required this.onPressed,
  });

  String get subscriberCountText {
    if (subscriberCount < 1000) {
      return subscriberCount.toString();
    } else if (subscriberCount < 10000) {
      return "${(subscriberCount / 1000).toStringAsFixed(1)}천";
    } else {
      return "${(subscriberCount / 10000).toStringAsFixed(1)}만";
    }
  }

  Widget get channelProfileImage {
    Widget innerWidget = ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: CachedNetworkImage(
        imageUrl: channelImageUrl,
        width: 50,
        height: 50,
      ),
    );

    if (onLive) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorTable.kPrimaryColor,
                width: 4.0,
              ),
            ),
            child: innerWidget,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: ColorTable.kPrimaryColor,
              ),
              child: const Text(
                "라이브",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return innerWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BouncingWidget(
          onPressed: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: ColorTable.inputBorderColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    channelProfileImage,
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            channelTitle,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            "구독자 $subscriberCountText",
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: ColorTable.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "\"",
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: ColorTable.inputBorderColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: ColorTable.textInfoColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const Text(
                "\"",
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: ColorTable.inputBorderColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
