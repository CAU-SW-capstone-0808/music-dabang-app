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
            BouncingWidget(
              onPressed: () async {
                await ref.read(userProvider.notifier).loginWithKakao();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ColorTable.kakaoYellow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  '카카오로 1초만에 회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
