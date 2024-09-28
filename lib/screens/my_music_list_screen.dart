import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/my_music_list_provider.dart';

class MyMusicListScreen extends ConsumerStatefulWidget {
  const MyMusicListScreen({super.key});

  @override
  ConsumerState<MyMusicListScreen> createState() => _MyMusicListScreenState();
}

class _MyMusicListScreenState extends ConsumerState<MyMusicListScreen> {
  @override
  Widget build(BuildContext context) {
    final List<PlaylistItemModel> items = ref.watch(myMusicListProvider);
    final currentPlayingMusic = ref.watch(currentPlayingMusicProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 음악',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(myMusicListProvider.notifier).refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return SizedBox(height: currentPlayingMusic != null ? 84 : 0);
            }
            return MusicListCard(
              title: items[index].musicContent.title,
              artist: items[index].musicContent.artist.name,
              imageUrl: items[index].musicContent.thumbnailUrl,
              onTap: () async {
                await ref
                    .read(currentPlayingMusicProvider.notifier)
                    .setPlayingMusic(items[index].musicContent);
                ref.read(musicPlayerStatusProvider.notifier).expand();
              },
            );
          },
        ),
      ),
    );
  }
}
