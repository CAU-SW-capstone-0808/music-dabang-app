import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/cached_image.dart';
import 'package:music_dabang/components/glass_interactor.dart';

class MusicListCard extends StatelessWidget {
  final String title;
  final String artist;
  final String? imageUrl;
  final void Function()? onTap;

  /// if not null, there exists a remove interaction
  final Future<void> Function()? onRemove;
  final bool isPlaying;

  const MusicListCard({
    super.key,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.onTap,
    this.onRemove,
    this.isPlaying = false,
  });

  Color get textColor => isPlaying ? Colors.white : Colors.black;

  Widget albumImage({
    double width = 76,
    double height = 76,
    double borderRadius = 12,
  }) =>
      ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl != null
            ? CachedImage(
                imageUrl!,
                width: width,
                height: height,
              )
            : Container(
                width: width,
                height: height,
                color: ColorTable.backGrey,
              ),
      );

  @override
  Widget build(BuildContext context) {
    var innerWidget = GlassMorphing(
      background: albumImage(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        borderRadius: 0,
      ),
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: isPlaying ? ColorTable.kPrimaryColor : Colors.transparent,
        ),
        child: Row(
          children: [
            albumImage(),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 22.0,
                      height: 1.25,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    artist,
                    style: TextStyle(
                      fontSize: 22.0,
                      height: 1.25,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  size: 54,
                  color: isPlaying ? Colors.white : ColorTable.kPrimaryColor,
                ),
                Text(
                  isPlaying ? "재생 중" : "재생",
                  style: TextStyle(
                    fontSize: 18.0,
                    height: 1.25,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (onRemove != null && key != null) {
      return Dismissible(
        key: key!,
        background: Container(
          color: Colors.red,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          try {
            await onRemove!();
            return true;
          } catch (e) {
            return false;
          }
        },
        child: innerWidget,
      );
    } else {
      return innerWidget;
    }
  }
}
