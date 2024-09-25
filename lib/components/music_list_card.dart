import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/glass_interactor.dart';

class MusicListCard extends StatelessWidget {
  final String title;
  final String artist;
  final String? imageUrl;
  final void Function()? onTap;

  const MusicListCard({
    super.key,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.onTap,
  });

  Widget albumImage({
    double width = 76,
    double height = 76,
    double borderRadius = 12,
  }) =>
      ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                width: width,
                height: height,
                fit: BoxFit.cover,
              )
            : Container(
                width: width,
                height: height,
                color: ColorTable.backGrey,
              ),
      );

  @override
  Widget build(BuildContext context) {
    return GlassMorphing(
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
        // decoration: const BoxDecoration(
        //   color: Colors.transparent,
        // ),
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
                    style: const TextStyle(
                      fontSize: 22.0,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    artist,
                    style: const TextStyle(
                      fontSize: 22.0,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  size: 54,
                  color: ColorTable.kPrimaryColor,
                ),
                Text(
                  "재생",
                  style: TextStyle(
                    fontSize: 18.0,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
