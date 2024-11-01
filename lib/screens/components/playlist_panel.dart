import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/components/music_list_card.dart';
import 'package:music_dabang/models/music/playlist_item_model.dart';
import 'package:music_dabang/models/music/playlist_model.dart';
import 'package:music_dabang/providers/common/page_scroll_controller.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/my_music_list_provider.dart';
import 'package:music_dabang/providers/music/playlist_items_provider.dart';

class PlaylistPanel extends ConsumerStatefulWidget {
  /// 매우 멍청한 SlidingUpPanel을 위해 viewPadding 정보를 직접 받는다.
  final EdgeInsets viewPadding;

  const PlaylistPanel({
    super.key,
    required this.viewPadding,
  });

  @override
  ConsumerState<PlaylistPanel> createState() => _PlaylistPanelState();
}

class _PlaylistPanelState extends ConsumerState<PlaylistPanel> {
  final SlidingUpPanelController panelController = SlidingUpPanelController();
  bool _touched = false; // 파이어베이스 로깅을 위해 필요함

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlaylist = ref.watch(currentPlaylistProvider);

    ref.listen(
      musicPlayerStatusProvider,
      (prev, next) {
        if (_touched) {
          _touched = false;
          return;
        }
        if (next != MusicDabangPlayerState.expandedWithPlaylist) {
          if (panelController.status != SlidingUpPanelStatus.collapsed) {
            AidolUtils.d('music_player_playlist collapse:auto');
            panelController.collapse();
          }
        } else {
          if (panelController.status != SlidingUpPanelStatus.expanded) {
            AidolUtils.d('music_player_playlist expand:auto');
            panelController.expand();
          }
        }
      },
    );

    var upperTitle = SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/playlist_icon.svg',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 8.0),
          const Text(
            '재생목록',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );

    return SlidingUpPanelWidget(
      controlHeight: 60,
      anchor: 0.8,
      panelController: panelController,
      onTap: () {
        var panelStatus = panelController.status;
        if (panelStatus == SlidingUpPanelStatus.collapsed) {
          setState(() => _touched = true);
          panelController.anchor();
          AidolUtils.d('music_player_playlist expand:touch');
          FirebaseLogger.changeMusicPlayerPlaylistStatus(
            status: 'expand',
            userAction: 'touch',
          );
        } else {
          // 닫힐 거라고 생각하고 터치하는 경우
          AidolUtils.d(
              'music_player_playlist expand_wrong_because_expected_to_collapse:touch');
          FirebaseLogger.changeMusicPlayerPlaylistStatus(
            status: 'expand_wrong_because_expected_to_collapse',
            userAction: 'touch',
          );
        }
      },
      onStatusChanged: (status) {
        // AidolUtils.d('골때리는 $status ${mpStatus}');
        if (status == SlidingUpPanelStatus.collapsed) {
          var mpStatus = ref.read(musicPlayerStatusProvider);
          // drag collapse
          if (mpStatus == MusicDabangPlayerState.expandedWithPlaylist) {
            AidolUtils.d('music_player_playlist collapse:drag');
            ref.read(musicPlayerStatusProvider.notifier).status =
                MusicDabangPlayerState.expanded;
            FirebaseLogger.changeMusicPlayerPlaylistStatus(
              status: 'collapse',
              userAction: 'drag',
            );
          }
        } else if (status == SlidingUpPanelStatus.anchored ||
            status == SlidingUpPanelStatus.expanded) {
          var mpStatus = ref.read(musicPlayerStatusProvider);
          // drag exapnd
          if (mpStatus != MusicDabangPlayerState.expandedWithPlaylist) {
            AidolUtils.d('music_player_playlist expand:drag');
            ref.read(musicPlayerStatusProvider.notifier).status =
                MusicDabangPlayerState.expandedWithPlaylist;
            FirebaseLogger.changeMusicPlayerPlaylistStatus(
              status: 'expand',
              userAction: 'drag',
            );
          }
        }
        // 이 자식 아주 멍청하기 때문에 upperBound 따위로 조정하려고 해서는 안 된다.
        if (status == SlidingUpPanelStatus.expanded) {
          panelController.anchor();
        }
      },
      child: Container(
        // bullshit: this container is fixed to media height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 재생 목록 손잡이 (height: 60)
            upperTitle,
            SizedBox(
              height: max(
                MediaQuery.of(context).size.height * 0.8 -
                    60 -
                    widget.viewPadding.vertical,
                0,
              ),
              child: _PlaylistItemListView(
                playlist: currentPlaylist,
                onTopScrollEnd: () {
                  if (panelController.status == SlidingUpPanelStatus.expanded) {
                    panelController.anchor();
                  } else {
                    panelController.collapse();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _PlaylistItemListView extends ConsumerStatefulWidget {
  final PlaylistModel? playlist;
  final void Function()? onTopScrollEnd;

  const _PlaylistItemListView({
    required this.playlist,
    this.onTopScrollEnd,
  });

  @override
  ConsumerState<_PlaylistItemListView> createState() =>
      _PlaylistItemListViewState();
}

class _PlaylistItemListViewState extends ConsumerState<_PlaylistItemListView> {
  final pageController = PageScrollController();

  Future<void> _logPlaylistItem({
    required PlaylistItemModel item,
    required int index,
  }) async {
    var currentMusic = ref.read(currentPlayingMusicProvider);
    var currentPlaylist = ref.read(currentPlaylistProvider);
    await FirebaseLogger.playMusicInPlaylist(
      prevMusicId: currentMusic?.id,
      prevMusicTitle: currentMusic?.title,
      prevMusicContentType: currentMusic?.musicContentType.name,
      musicId: item.musicContent.id,
      musicTitle: item.musicContent.title,
      musicContentType: item.musicContent.musicContentType.name,
      playlistId: currentPlaylist?.id,
      playlistName: currentPlaylist?.name,
      position: ref.read(currentPlayingMusicProvider.notifier).currentPosition,
      maxPosition: ref.read(currentPlayingMusicProvider.notifier).maxPosition,
      index: index,
    );
  }

  @override
  void initState() {
    super.initState();
    pageController.onEnd = () {
      ref.read(playlistItemsProvider(widget.playlist?.id).notifier).fetch();
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(playlistItemsProvider(widget.playlist?.id));
    int? currentItemId = ref
        .watch(currentPlayingMusicProvider.notifier)
        .currentPlayingPlaylistItemId;
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (pageController.offset <= 0) {
          widget.onTopScrollEnd?.call();
        }
        return true;
      },
      child: ListView.builder(
        controller: pageController,
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          // index == 0: playlist title
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: const BoxDecoration(
                color: ColorTable.backGrey,
              ),
              child: Text(
                '재생 중: ${widget.playlist?.name ?? '내 음악'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          index--;
          final item = items[index];
          return MusicListCard(
            key: Key('playlist_${item.id}'),
            title: item.musicContent.title,
            artist: item.musicContent.artist.name,
            imageUrl: item.musicContent.thumbnailUrl,
            isPlaying: currentItemId == item.id,
            onTap: () {
              _logPlaylistItem(item: item, index: index);
              ref
                  .read(currentPlayingMusicProvider.notifier)
                  .setCurrentPlayingPlaylistItem(item);
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
