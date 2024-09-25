import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/components/arrow_button.dart';
import 'package:music_dabang/components/custom_search_bar.dart';
import 'package:music_dabang/components/image_card.dart';
import 'package:music_dabang/components/logo_title.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/music/music_live_items_provider.dart';
import 'package:music_dabang/providers/music/playlist_main_provider.dart';
import 'package:music_dabang/providers/music_player_size_provider.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:music_dabang/screens/components/play_list_nav_item.dart';
import 'package:music_dabang/screens/components/playlist_item_preview_list.dart';
import 'package:music_dabang/screens/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = 'home';

  final void Function()? expandPlayerFunc;

  const HomeScreen({
    super.key,
    this.expandPlayerFunc,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _dragController = DraggableScrollableController();
  double playerHeight = -1;
  double playerSizeFraction = 0.1;
  double minPlayerHeight = 90;
  double minPlayerSize = 0.1;
  bool mpFullSize = false;

  Widget get appBar => SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: LogoTitle(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Hero(
                tag: 'search-bar',
                child: CustomSearchBar(
                  onTap: () {
                    context.goNamed(SearchScreen.routeName);
                  },
                  autofocus: false,
                  readOnly: true,
                ),
              ),
            ),
          ],
        ),
      );

  /// 상하 8px, 좌우 16px padding
  /// 자식들 간의 간격 8px
  Widget horizList({required List<Widget> children}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
      child: Row(
        children: children
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: e,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget ph16({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: child,
    );
  }

  Widget ph16v6({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: child,
    );
  }

  Widget titleLink({
    required String title,
    required void Function()? onPressed,
  }) {
    final titleWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 32.0,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
    );
    if (onPressed == null) {
      return titleWidget;
    }
    return ArrowButton(
      onPressed: onPressed,
      arrowSize: 54.0,
      arrowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 48, 8),
        child: titleWidget,
      ),
    );
  }

  Future<void> togglePlayer() {
    if (_dragController.size == 1) {
      return _dragController.animateTo(
        0.1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      return _dragController.animateTo(
        1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _dragController.addListener(() {
      ref
          .read(musicPlayerSizeProvider.notifier)
          .setPlayerSize(_dragController.size);
      ref
          .read(musicPlayerHeightProvider.notifier)
          .setPlayerHeight(_dragController.pixels);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /// --- Data ---
    final user = ref.watch(userProvider);
    if (user is! UserModel) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final mainPlaylists = ref.watch(playlistMainProvider);
    final livePlaylists = ref.watch(musicLiveItemsProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        print('asd!!!');
        if (mpFullSize) {
          togglePlayer();
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appBar,
                const SizedBox(height: 8.0),
                ph16(
                  child: titleLink(
                    title: "임영웅의 공연영상",
                    onPressed: () {},
                  ),
                ),
                horizList(
                  children: livePlaylists
                      .sublist(0, min(5, livePlaylists.length))
                      .map((p) => ImageCard(
                            title: p.title,
                            imageUrl: p.thumbnailUrl,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28.0),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: ChipSelector(
                //     items: ["임영웅", "송가인", "송호현", "김호중", "김호중", "김호중"],
                //     selectedIndexes: [0],
                //     onSelected: (index) {},
                //   ),
                // ),
                const SizedBox(height: 8.0),
                ph16(
                  child: titleLink(
                    title: "임영웅 재생목록",
                    onPressed: null,
                  ),
                ),
                const SizedBox(height: 12.0),
                horizList(
                  children: mainPlaylists
                      .where((p) => p.userVisible)
                      .map((p) => PlayListNavItem(
                            playlistId: p.id,
                            name: '${p.name} 모음',
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                ...mainPlaylists.map(
                  (p) => PlaylistItemPreviewList(
                    playlistId: p.id,
                    title: '임영웅의 ${p.name}',
                    onTap: widget.expandPlayerFunc,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }
}
