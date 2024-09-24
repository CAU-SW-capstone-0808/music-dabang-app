import 'package:flutter/material.dart';
import 'package:music_dabang/components/bouncing_widget.dart';

class ImageCard extends StatelessWidget {
  final double width;
  final String title;
  final String imageUrl;
  final String? artist;

  const ImageCard({
    super.key,
    this.width = 240,
    required this.title,
    required this.imageUrl,
    this.artist,
  });

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(24);
    return BouncingWidget(
      onPressed: () {},
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
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: Image.network(
                imageUrl,
                width: width,
                height: 163,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$title\n\n',
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 18,
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
