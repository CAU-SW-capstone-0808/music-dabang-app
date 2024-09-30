import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/common/extensions.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

class PlaylistItemPreviewList extends ConsumerWidget {
  final PlaylistModel playlist;
  final int maxCount;
  final void Function()? onTap;

  const PlaylistItemPreviewList({
    super.key,
    required this.playlist,
    this.maxCount = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<PlaylistItemModel> items =
        ref.watch(playlistItemsProvider(playlist.id));
    if (items.length > maxCount) {
      items = items.sublist(0, maxCount);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          child: Text(
            playlist.name,
            style: const TextStyle(
              fontSize: 32.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
        ...items.mapWithIndex(
          (e, i) => MusicListCard(
            title: e.musicContent.title,
            artist: e.musicContent.artist.name,
            imageUrl: e.musicContent.thumbnailUrl,
            onTap: () async {
              await ref.read(currentPlaylistProvider.notifier).setPlaylist(
                    playlist,
                    itemToPlay: e,
                  );
              onTap?.call();
              FirebaseLogger.touchPlaylistItem(
                playlistId: playlist.id,
                playlistItemId: e.id,
                musicId: e.musicContent.id,
                title: e.musicContent.title,
                musicContentType: e.musicContent.musicContentType.name,
                index: i,
              );
            },
          ),
        ),
      ],
    );
  }
}
