import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/components/cached_image.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

/// 참고: screens/components의 컴포넌트들은 ConsumerWidget
class PlayListNavItem extends ConsumerWidget {
  final PlaylistModel playlistModel;
  final int index;

  const PlayListNavItem({
    super.key,
    required this.playlistModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var borderRadius = BorderRadius.circular(24);
    List<PlaylistItemModel> items =
        ref.watch(playlistItemsProvider(playlistModel.id));
    int? itemsCount = ref.watch(playlistItemsCountProvider(playlistModel.id));
    PlaylistItemModel? firstItem = items.isNotEmpty ? items[0] : null;
    // if (items.length > 10) {
    //   items = items.sublist(0, 10);
    // }
    return BouncingWidget(
      onPressed: () async {
        await ref
            .read(currentPlaylistProvider.notifier)
            .setPlaylist(playlistModel);
        ref.read(musicPlayerStatusProvider.notifier).expand();
        FirebaseLogger.touchPlaylist(
          playlistId: playlistModel.id,
          playlistName: playlistModel.name,
          firstMusicTitle: firstItem?.musicContent.title,
          firstMusicContentType: firstItem?.musicContent.musicContentType.name,
          firstMusicId: firstItem?.musicContent.id,
          index: index,
        );
      },
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
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          // width: 120,
                          // height: 120,
                          color: firstItem != null
                              ? Colors.white
                              : ColorTable.backGrey,
                          child: firstItem != null
                              ? CachedImage(
                                  firstItem.musicContent.thumbnailUrl,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlistModel.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12.0),
                          if (firstItem != null)
                            Text(
                              firstItem.musicContent.title,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 24.0,
                                height: 1.25,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (itemsCount != null && itemsCount > 1)
                            Text(
                              "외 ${itemsCount - 1}곡",
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 24.0,
                                height: 1.25,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: ColorTable.kPrimaryColor,
                borderRadius: borderRadius.copyWith(
                  topLeft: const Radius.circular(0),
                  topRight: const Radius.circular(0),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "바로 재생",
                    style: TextStyle(
                      fontSize: 28.0,
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
          ],
        ),
      ),
    );
  }
}
