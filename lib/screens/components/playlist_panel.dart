import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';

class PlaylistPanel extends ConsumerStatefulWidget {
  final SlidingUpPanelController panelController;

  const PlaylistPanel({
    super.key,
    required this.panelController,
  });

  @override
  ConsumerState<PlaylistPanel> createState() => _PlaylistPanelState();
}

class _PlaylistPanelState extends ConsumerState<PlaylistPanel> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanelWidget(
      controlHeight: 60,
      anchor: 0.8,
      panelController: widget.panelController,
      onTap: () {
        if (widget.panelController.status == SlidingUpPanelStatus.collapsed ||
            widget.panelController.status == SlidingUpPanelStatus.expanded) {
          widget.panelController.anchor();
        }
      },
      onStatusChanged: (status) {
        if (status == SlidingUpPanelStatus.collapsed) {
          ref.read(musicPlayerStatusProvider.notifier).status =
              MusicDabangPlayerState.expanded;
        } else if (status == SlidingUpPanelStatus.anchored ||
            status == SlidingUpPanelStatus.expanded) {
          ref.read(musicPlayerStatusProvider.notifier).status =
              MusicDabangPlayerState.expandedWithPlaylist;
        }
      },
      child: Container(
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
          children: [
            GestureDetector(
              onTap: () {
                var panelStatus = widget.panelController.status;
                if (panelStatus == SlidingUpPanelStatus.collapsed) {
                  widget.panelController.anchor();
                } else if (panelStatus == SlidingUpPanelStatus.expanded ||
                    panelStatus == SlidingUpPanelStatus.anchored) {
                  widget.panelController.collapse();
                }
              },
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.5,
                ),
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
              ),
            ),
            NotificationListener<ScrollEndNotification>(
              onNotification: (notf) {
                if (scrollController.offset <= 0) {
                  widget.panelController.collapse();
                }
                return true;
              },
              child: Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: List.generate(20, (index) {
                      return ListTile(
                        title: Text('title $index'),
                        subtitle: Text('subtitle $index'),
                      );
                    }),
                  ),
                ),
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
    scrollController.dispose();
  }
}
