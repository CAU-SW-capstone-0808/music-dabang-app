import 'package:audio_service/audio_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/my_audio_handler.dart';
import 'package:music_dabang/firebase_options.dart';
import 'package:music_dabang/providers/router_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 디버깅 모드 여부를 사용자 속성으로 설정
  await FirebaseAnalytics.instance.setUserProperty(
    name: 'debug_mode',
    value: kDebugMode.toString(),
  );
  KakaoSdk.init(
    nativeAppKey: '77e0c7bca12daad215f23b6a143c962b',
    javaScriptAppKey: '7c9a44473ebe4bec739fe0dea137871f',
  );

  // 세로 모드만 허용
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await MyAudioHandler.init();
  // MyAudioHandler audioHandler = await AudioService.init<MyAudioHandler>(
  //   builder: () => MyAudioHandler(),
  //   config: AudioServiceConfig(
  //     androidNotificationChannelId:
  //         'com.anarchyadventure.music_dabang.channel.audio',
  //     androidNotificationChannelName: 'Music Dabang Audio Player',
  //     androidNotificationOngoing: true,
  //   ),
  // );

  runApp(const ProviderScope(child: MusicDabang()));
}

class MusicDabang extends ConsumerWidget with WidgetsBindingObserver {
  const MusicDabang({super.key});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 전환될 때
      print('App went to the background.');
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 다시 포그라운드로 전환될 때
      print('App returned to the foreground.');
    } else if (state == AppLifecycleState.inactive) {
      // 앱이 비활성화될 때
      print('App is inactive.');
    } else if (state == AppLifecycleState.detached) {
      // 앱이 완전히 종료되기 전에 호출
      print('App is detached.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.0,
            ), // 최소 1.0, 최대 1.5배까지만 확대
        size: MediaQuery.of(context).size,
        devicePixelRatio: 1.0,
      ),
      child: MaterialApp.router(
        title: '뮤직다방',
        debugShowCheckedModeBanner: false,
        routerConfig: router,

        /// 라우팅 설정
        // routerDelegate: router.routerDelegate,
        // routeInformationParser: router.routeInformationParser,
        // routeInformationProvider: router.routeInformationProvider,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          sliderTheme: const SliderThemeData(
            activeTrackColor: ColorTable.sliderColor,
            inactiveTrackColor: ColorTable.backGrey,
            thumbColor: ColorTable.sliderColor,
            trackHeight: 8.0,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 5.0,
              elevation: 0,
              pressedElevation: 0,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 16.0,
            ),
          ),
          colorScheme:
              ColorScheme.fromSeed(seedColor: ColorTable.kPrimaryColor),
          fontFamily: 'Roboto',
          useMaterial3: true,
          textTheme: const TextTheme(),
        ),
      ),
    );
  }
}
