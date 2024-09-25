import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bottom_nav_bar.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/bottom_nav_provider.dart';
import 'package:music_dabang/providers/music/music_player_provider.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:music_dabang/screens/home_screen.dart';
import 'package:music_dabang/screens/music_player_screen.dart';
import 'package:music_dabang/screens/my_music_list_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  static const routeName = 'main';

  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  final _panelController = SlidingUpPanelController();

  // Widget musicPlayerSheet2(bool expanded) => SlidingUpPanelWidget(
  //       panelController: _panelController,
  //       animationController: musicPlayerAnimationController,
  //       controlHeight: 90,
  //       enableOnTap: true,
  //       onTap: () {
  //         if (_panelController.status == SlidingUpPanelStatus.collapsed) {
  //           _panelController.expand();
  //         }
  //       },
  //       onStatusChanged: (status) {
  //         // print('status: $status');
  //         if (status == SlidingUpPanelStatus.collapsed) {
  //           ref.read(musicPlayerExpandedProvider.notifier).expanded = false;
  //         } else if (status == SlidingUpPanelStatus.anchored ||
  //             status == SlidingUpPanelStatus.expanded) {
  //           ref.read(musicPlayerExpandedProvider.notifier).expanded = true;
  //         }
  //       },
  //       anchor: 1.0,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: expanded ? Colors.white : ColorTable.backGrey,
  //         ),
  //         child: AnimatedBuilder(
  //           animation: musicPlayerAnimationController,
  //           builder: (context, child) {
  //             return MusicPlayerScreen();
  //           },
  //         ),
  //       ),
  //     );

  @override
  void initState() {
    super.initState();
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
    final musicPlayerExpanded = ref.watch(musicPlayerExpandedProvider);
    final navIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      bottomNavigationBar: Stack(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: musicPlayerExpanded ? 0 : 1,
              child: Opacity(
                opacity: musicPlayerExpanded ? 0 : 1,
                child: BottomNavBar(
                  userName: user.nickname,
                  userProfileImageUrl: user.profileImageUrl,
                  selectedIndex: navIndex,
                  onTap: (x) {
                    if (x < 2) {
                      ref.read(bottomNavProvider.notifier).select(x);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (navIndex == 0)
            HomeScreen(
              expandPlayerFunc: () => _panelController.expand(),
            ),
          if (navIndex == 1) MyMusicListScreen(),
          MusicPlayerScreen(panelController: _panelController),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
