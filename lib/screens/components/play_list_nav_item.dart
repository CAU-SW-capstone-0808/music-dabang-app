import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

/// 참고: screens/components의 컴포넌트들은 ConsumerWidget
class PlayListNavItem extends ConsumerWidget {
  final PlaylistModel playlistModel;
  final void Function()? expandPlayerFunc;

  const PlayListNavItem({
    super.key,
    required this.playlistModel,
    this.expandPlayerFunc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var borderRadius = BorderRadius.circular(24);
    List<PlaylistItemModel> items =
        ref.watch(playlistItemsProvider(playlistModel.id));
    PlaylistItemModel? firstItem = items.isNotEmpty ? items[0] : null;
    if (items.length > 10) {
      items = items.sublist(0, 10);
    }
    return BouncingWidget(
      onPressed: () async {
        await ref
            .read(currentPlaylistProvider.notifier)
            .setPlaylist(playlistModel);
        expandPlayerFunc?.call();
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Container(
                      width: 120,
                      height: 120,
                      color: firstItem != null
                          ? Colors.white
                          : ColorTable.backGrey,
                      child: firstItem != null
                          ? Image.network(
                              firstItem.musicContent.thumbnailUrl,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: SizedBox(
                    height: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlistModel.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: items
                                  .map(
                                    (e) => Text(
                                      e.musicContent.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.25,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13.5),
              decoration: BoxDecoration(
                color: ColorTable.mRed,
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
          ],
        ),
      ),
    );
  }
}
