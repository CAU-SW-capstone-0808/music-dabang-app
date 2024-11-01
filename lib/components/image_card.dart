import 'package:flutter/material.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/components/cached_image.dart';

class ImageCard extends StatelessWidget {
  final double width;
  final String title;
  final String imageUrl;
  final String? artist;
  final void Function()? onTap;

  const ImageCard({
    super.key,
    this.width = 240,
    required this.title,
    required this.imageUrl,
    this.artist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(24);
    return BouncingWidget(
      onPressed: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: borderRadius.copyWith(
                  bottomLeft: const Radius.circular(0),
                  bottomRight: const Radius.circular(0),
                ),
                child: CachedImage(
                  imageUrl,
                  width: width,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$title\n',
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (artist != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    artist!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
