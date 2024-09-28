import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/bouncing_widget.dart';
import 'package:music_dabang/components/logo_title.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:music_dabang/screens/login/phone_login_screen.dart';

class LoginHomeScreen extends ConsumerWidget {
  static const routeName = 'login_home';

  const LoginHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await ref.read(userProvider.notifier).loginWithKakao();
                UserApi.instance.unlink();
              },
              child: const LogoTitle(fontSize: 72),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BouncingWidget(
                onPressed: () async {
                  await ref.read(userProvider.notifier).loginWithKakao();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTable.kakaoYellow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/kakao_logo.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          '카카오로 1초만에 회원가입',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (kIsWeb)
              TextButton(
                onPressed: () {
                  context.goNamed(PhoneLoginScreen.routeName);
                },
                child: const Text("또는 휴대폰 번호로 로그인"),
              ),
          ],
        ),
      ),
    );
  }
}
