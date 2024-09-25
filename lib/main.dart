import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/firebase_options.dart';
import 'package:music_dabang/providers/router_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  KakaoSdk.init(
    nativeAppKey: '77e0c7bca12daad215f23b6a143c962b',
    javaScriptAppKey: '7c9a44473ebe4bec739fe0dea137871f',
  );

  runApp(
    const ProviderScope(
      child: MusicDabang(),
    ),
  );
}

class MusicDabang extends ConsumerWidget {
  const MusicDabang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '뮤직다방',
      debugShowCheckedModeBanner: false,

      /// 라우팅 설정
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
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
        colorScheme: ColorScheme.fromSeed(seedColor: ColorTable.kPrimaryColor),
        fontFamily: 'Roboto',
        useMaterial3: true,
        textTheme: const TextTheme(),
      ),
    );
  }
}
