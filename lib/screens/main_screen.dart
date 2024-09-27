import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class _MainScreenState extends ConsumerState<MainScreen> {
  final _panelController = SlidingUpPanelController();
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
    final musicPlayerExpanded = ref.watch(musicPlayerExpandedProvider);
    final navIndex = ref.watch(bottomNavProvider);

    return PopScope(
      canPop: !musicPlayerExpanded && canExitByAsk,
      onPopInvokedWithResult: (_, __) {
        if (musicPlayerExpanded) {
          _panelController.collapse();
          return;
        }
        if (_lastAskedToExit == null ||
            DateTime.now().difference(_lastAskedToExit!).inSeconds > 2) {
          setState(() => _lastAskedToExit = DateTime.now());
          Fluttertoast.showToast(msg: '앱을 종료하려면 한번 더 눌러주세요.');
        }
      },
      child: Scaffold(
        bottomNavigationBar: Stack(
          children: [
            if (user is UserModel)
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
            if (navIndex == 1)
              MyMusicListScreen(
                expandPlayerFunc: () => _panelController.expand(),
              ),
            MusicPlayerScreen(panelController: _panelController),
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
