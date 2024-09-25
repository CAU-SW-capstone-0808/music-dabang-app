import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

class PlaylistItemPreviewList extends ConsumerWidget {
  final int playlistId;
  final String title;
  final int maxCount;
  final void Function()? onTap;

  const PlaylistItemPreviewList({
    super.key,
    required this.playlistId,
    required this.title,
    this.maxCount = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<PlaylistItemModel> items =
        ref.watch(playlistItemsProvider(playlistId));
    if (items.length > maxCount) {
      items = items.sublist(0, maxCount);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 32.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
        ...items.map(
          (e) => MusicListCard(
            title: e.musicContent.title,
            artist: e.musicContent.artist.name,
            imageUrl: e.musicContent.thumbnailUrl,
            onTap: () {
              ref.read(currentPlayingMusicProvider.notifier).playingMusic =
                  e.musicContent;
              onTap?.call();
            },
          ),
        ),
      ],
    );
  }
}
