import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/providers/common/page_scroll_controller.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

class MyMusicListScreen extends ConsumerStatefulWidget {
  const MyMusicListScreen({super.key});

  @override
  ConsumerState<MyMusicListScreen> createState() => _MyMusicListScreenState();
}

class _MyMusicListScreenState extends ConsumerState<MyMusicListScreen> {
  final scrollPageController = PageScrollController();

  Widget get noItemsWidget {
    if (ref.read(playlistItemsProvider(null).notifier).loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(playlistItemsProvider(null).notifier).refresh();
        FirebaseLogger.refreshItems();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/playlists_icon.svg',
                width: 80,
                height: 80,
                colorFilter: const ColorFilter.mode(
                  Colors.black54,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '내음악을 추가해보세요!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black54,
                ),
              ),
              const Text(
                "음악 재생 > \"내음악에 추가\" 버튼 터치",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    scrollPageController.onEnd = () async {
      await ref.read(playlistItemsProvider(null).notifier).fetch();
    };
  }

  @override
  Widget build(BuildContext context) {
    final List<PlaylistItemModel> items =
        ref.watch(playlistItemsProvider(null));
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
      body: items.isEmpty
          ? noItemsWidget
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(playlistItemsProvider(null).notifier).refresh(),
              child: ReorderableListView.builder(
                scrollController: scrollPageController,
                padding: EdgeInsets.only(
                  bottom: currentPlayingMusic != null ? 84 : 0,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) async {
                  print('oldIndex: $oldIndex, newIndex: $newIndex');
                  await ref
                      .read(playlistItemsProvider(null).notifier)
                      .changeOrder(
                        oldIndex: oldIndex,
                        newIndex: oldIndex < newIndex ? newIndex - 1 : newIndex,
                      );
                },
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return MusicListCard(
                    key: Key('mymusic_${item.id}'),
                    title: item.musicContent.title,
                    artist: item.musicContent.artist.name,
                    imageUrl: item.musicContent.thumbnailUrl,
                    onTap: () async {
                      print('나요 나');
                      await ref
                          .read(currentPlaylistProvider.notifier)
                          .setPlaylist(null, itemToPlay: item);
                      // await ref
                      //     .read(currentPlayingMusicProvider.notifier)
                      //     .setPlayingMusic(item.musicContent);
                      ref.read(musicPlayerStatusProvider.notifier).expand();
                      FirebaseLogger.touchMyMusicItem(
                        musicId: item.musicContent.id,
                        musicTitle: item.musicContent.title,
                        musicContentType:
                            item.musicContent.musicContentType.name,
                        index: index,
                      );
                    },
                    onRemove: () async {
                      await ref
                          .read(playlistItemsProvider(null).notifier)
                          .removeItems(itemIds: [item.id]);
                      FirebaseLogger.removeMyMusicItem(
                        musicId: item.musicContent.id,
                        musicTitle: item.musicContent.title,
                        musicContentType:
                            item.musicContent.musicContentType.name,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
