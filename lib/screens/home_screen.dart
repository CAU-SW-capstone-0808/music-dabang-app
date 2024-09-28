import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/components/arrow_button.dart';
import 'package:music_dabang/components/custom_search_bar.dart';
import 'package:music_dabang/components/image_card.dart';
import 'package:music_dabang/components/logo_title.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/music/music_live_items_provider.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/music/playlist_main_provider.dart';
import 'package:music_dabang/providers/music_player_size_provider.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:music_dabang/screens/components/play_list_nav_item.dart';
import 'package:music_dabang/screens/components/playlist_item_preview_list.dart';
import 'package:music_dabang/screens/search_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  Widget carouselList({required List<Widget> children}) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 1,
        viewportFraction: 0.9,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        enlargeFactor: 0.2,
      ),
      items: children,
    );
  }

  /// 상하 8px, 좌우 16px padding
  /// 자식들 간의 간격 8px
  Widget vertList({required List<Widget> children}) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: children
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
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
    final currentPlayingMusic = ref.watch(currentPlayingMusicProvider);

    var livePlayItems = carouselList(
      children: livePlaylists
          .sublist(0, min(10, livePlaylists.length))
          .map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ImageCard(
                  width: double.infinity,
                  title: p.title,
                  imageUrl: p.thumbnailUrl,
                  onTap: () async {
                    await ref
                        .read(currentPlayingMusicProvider.notifier)
                        .setPlayingMusic(p);
                    widget.expandPlayerFunc?.call();
                  },
                ),
              ))
          .toList(),
    );
    var playlists = mainPlaylists.where((p) => p.userVisible).map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: PlayListNavItem(
              playlistModel: p,
              expandPlayerFunc: widget.expandPlayerFunc,
            ),
          ),
        );
    var playlistItems = mainPlaylists.map(
      (p) => PlaylistItemPreviewList(
        playlist: p,
        onTap: widget.expandPlayerFunc,
      ),
    );
    var title1 = ph16(
      child: titleLink(
        title: "임영웅의 공연영상",
        onPressed: null,
      ),
    );
    var title2 = ph16(
      child: titleLink(
        title: "임영웅 재생목록",
        onPressed: null,
      ),
    );

    // Widget scrollView = SingleChildScrollView(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       appBar,
    //       const SizedBox(height: 8.0),
    //       title1,
    //       livePlayItems,
    //       const SizedBox(height: 20.0),
    //       title2,
    //       const SizedBox(height: 12.0),
    //       ...playlists,
    //       const SizedBox(height: 24),
    //       ...playlistItems,
    //       const SizedBox(height: 24),
    //       if (currentPlayingMusic != null) const SizedBox(height: 60),
    //     ],
    //   ),
    // );

    Widget scrollView = CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const LogoTitle(),
          floating: true,
          snap: true,
          expandedHeight: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withOpacity(0.12),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  const CustomSearchBar(
                    autofocus: false,
                    readOnly: true,
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () async {
                        final musicSelected = await context
                            .pushNamed<bool>(SearchScreen.routeName);
                        if (musicSelected == true) {
                          widget.expandPlayerFunc?.call();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const SizedBox(height: 12.0),
              title1,
              livePlayItems,
              const SizedBox(height: 20.0),
              title2,
              const SizedBox(height: 12.0),
              ...playlists,
              const SizedBox(height: 24),
              ...playlistItems,
              const SizedBox(height: 24),
              if (currentPlayingMusic != null) const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: scrollView,
      ),
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }
}
