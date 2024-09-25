import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
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
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return MusicListCard(
            title: items[index].musicContent.title,
            artist: items[index].musicContent.artist.name,
          );
        },
      ),
    );
  }
}
