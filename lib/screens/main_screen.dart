import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/components/bottom_nav_bar.dart';
import 'package:music_dabang/dialogs/showConfirmDialog.dart';
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

class _MainScreenState extends ConsumerState<MainScreen> {
  DateTime? _lastAskedToExit;

  bool get canExitByAsk {
    return _lastAskedToExit != null &&
        DateTime.now().difference(_lastAskedToExit!) <
            const Duration(seconds: 2);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// --- Data ---
    final user = ref.watch(userProvider);
    // if (user is! UserModel) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
    final musicPlayerState = ref.watch(musicPlayerStatusProvider);
    final navIndex = ref.watch(bottomNavProvider);

    return PopScope(
      canPop: !musicPlayerState.full && canExitByAsk,
      onPopInvokedWithResult: (_, __) {
        if (musicPlayerState == MusicDabangPlayerState.expanded) {
          ref.read(musicPlayerStatusProvider.notifier).status =
              MusicDabangPlayerState.collapsed;
          return;
        } else if (musicPlayerState ==
            MusicDabangPlayerState.expandedWithPlaylist) {
          ref.read(musicPlayerStatusProvider.notifier).status =
              MusicDabangPlayerState.expanded;
          return;
        }
        if (!musicPlayerState.full && _lastAskedToExit == null ||
            DateTime.now().difference(_lastAskedToExit!).inSeconds > 2) {
          setState(() => _lastAskedToExit = DateTime.now());
          AidolUtils.showToast('앱을 종료하려면 한번 더 눌러주세요.');
        }
      },
      child: Scaffold(
        bottomNavigationBar: Stack(
          children: [
            if (user is UserModel)
              ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: musicPlayerState.full ? 0 : 1,
                  child: Opacity(
                    opacity: musicPlayerState.full ? 0 : 1,
                    child: BottomNavBar(
                      userName: user.nickname,
                      userProfileImageUrl: user.profileImageUrl,
                      selectedIndex: navIndex,
                      onTap: (x) {
                        if (x < 2) {
                          ref.read(bottomNavProvider.notifier).select(x);
                        } else if (x == 2) {
                          showConfirmDialog(
                            context,
                            title: '로그아웃하시겠습니까?',
                            onConfirm: () =>
                                ref.read(userProvider.notifier).logout(),
                          );
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
            if (navIndex == 0) HomeScreen(),
            if (navIndex == 1) MyMusicListScreen(),
            // Align(
            //   heightFactor: currentPlaying != null ? 1 : 0,
            //   child: Opacity(
            //     opacity: currentPlaying != null ? 1 : 0,
            //     child: MusicPlayerScreen(),
            //   ),
            // ),
            MusicPlayerScreen(),
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
