import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/models/music/artist_model.dart';
import 'package:music_dabang/providers/music/artists_provider.dart';
import 'package:music_dabang/providers/post/fandom_provider.dart';

class ArtistSelector extends ConsumerWidget {
  final ScrollController? scrollController;
  final String searchQuery;

  const ArtistSelector({
    super.key,
    this.scrollController,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ArtistModel> artists = ref.watch(artistsProvider);
    final selectedArtistId = ref.watch(selectedArtistIdProvider);

    // search filtering
    if (searchQuery.isNotEmpty && selectedArtistId == null) {
      artists = artists.where((e) => e.name.contains(searchQuery)).toList();
    }

    // UI attributes by selectedArtistId
    double imageSize = selectedArtistId != null ? 64 : 96;
    double fontSize = selectedArtistId != null ? 12 : 16;
    double unselectedOpacity = selectedArtistId != null ? 0.5 : 1.0;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (selectedArtistId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(imageSize / 2),
                    child: CachedNetworkImage(
                      imageUrl: artists
                          .firstWhere((e) => e.id == selectedArtistId)
                          .profileImageUrl,
                      fit: BoxFit.cover,
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artists.firstWhere((e) => e.id == selectedArtistId).name,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ...artists.where((e) => e.id != selectedArtistId).map(
            (e) {
              return BouncingWidget(
                onPressed: () {
                  scrollController?.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  ref.read(selectedArtistIdProvider.notifier).select(e.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: unselectedOpacity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(imageSize / 2),
                          child: CachedNetworkImage(
                            imageUrl: e.profileImageUrl,
                            fit: BoxFit.cover,
                            width: imageSize,
                            height: imageSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.name,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
