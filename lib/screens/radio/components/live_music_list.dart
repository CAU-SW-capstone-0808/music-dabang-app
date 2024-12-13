import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/models/radio/radio_music_model.dart';
import 'package:music_dabang/providers/radio/radio_musics_provider.dart';

class LiveMusicList extends ConsumerStatefulWidget {
  final int broadcastId;

  const LiveMusicList({super.key, required this.broadcastId});

  @override
  ConsumerState<LiveMusicList> createState() => _LiveMusicListState();
}

class _LiveMusicListState extends ConsumerState<LiveMusicList> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final musics = ref.watch(radioMusicsProvider(widget.broadcastId));
    final willPlayMusic = ref.watch(willPlayMusicProvider(widget.broadcastId));

    ref.listen(radioMusicsProvider(widget.broadcastId), (prev, next) {
      if ((prev?.length ?? 0) < next.length &&
          scrollController.position.pixels < 400) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width / 2 - 82,
      ),
      itemExtent: 164,
      scrollDirection: Axis.horizontal,
      itemCount: musics.length + (willPlayMusic != null ? 1 : 0),
      itemBuilder: (context, index) {
        late RadioMusicModel music;
        if (willPlayMusic != null) {
          if (index == 0) {
            music = willPlayMusic;
          } else {
            music = musics[index - 1];
          }
        } else {
          music = musics[index];
        }
        Widget album = Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: ColorTable.boxShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: CachedNetworkImage(
              imageUrl: music.albumImageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        );

        if (index == 0) {
          if (willPlayMusic != null) {
            album = Opacity(opacity: 0.5, child: album);
          } else {
            album = Stack(
              children: [
                Center(child: album),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36.0,
                      vertical: 28.0,
                    ),
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineScalePulseOut,
                      colors: [
                        ColorTable.border2.withOpacity(0.5),
                        ColorTable.inputBorderColor.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }

        return Column(
          children: [
            album,
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                music.title,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              music.artist,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        );
      },
    );
  }
}
