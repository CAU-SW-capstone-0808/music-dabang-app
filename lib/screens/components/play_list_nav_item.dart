import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

/// 참고: screens/components의 컴포넌트들은 ConsumerWidget
class PlayListNavItem extends ConsumerWidget {
  final int playlistId;
  final String name;

  const PlayListNavItem({
    super.key,
    required this.playlistId,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var borderRadius = BorderRadius.circular(24);
    final items = ref.watch(playlistItemsProvider(playlistId));
    PlaylistItemModel? firstItem = items.isNotEmpty ? items[0] : null;
    return BouncingWidget(
      onPressed: () {},
      child: Container(
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
            const SizedBox(height: 12.0),
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                width: 121,
                height: 121,
                color: firstItem != null ? Colors.white : ColorTable.backGrey,
                child: firstItem != null
                    ? Image.network(
                        firstItem.musicContent.thumbnailUrl,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 29.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 13.5,
                  horizontal: 39.5,
                ),
                decoration: BoxDecoration(
                  color: ColorTable.skyBlue,
                  borderRadius: borderRadius,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "바로 재생",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36.0,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26.0),
          ],
        ),
      ),
    );
  }
}
