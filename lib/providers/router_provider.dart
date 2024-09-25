import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:music_dabang/screens/home_screen.dart';
import 'package:music_dabang/screens/login/login_home_screen.dart';
import 'package:music_dabang/screens/login/phone_join_screen.dart';
import 'package:music_dabang/screens/login/phone_login_screen.dart';
import 'package:music_dabang/screens/main_screen.dart';
import 'package:music_dabang/screens/search_screen.dart';
import 'package:music_dabang/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final currentPath = state.uri.path;
    if (currentPath.contains('login') || currentPath.contains('join')) {
      return null;
    }

    final UserModelBase user = ref.watch(userProvider);
    debugPrint('redirect - from=${state.uri} user: $user');

    if (user is UserModelLoading) {
      debugPrint('redirect result: ');
      return '/splash';
    } else if (user is UserModelNone || user is UserModelError) {
      debugPrint('redirect result: /login');
      return '/login';
    } else if (user is UserModel) {
      if (currentPath == '/login' || currentPath == '/splash') {
        debugPrint('redirect result: /');
        return '/';
      }
    }

    debugPrint('redirect result: no redirect');
    return null;
  }

  return GoRouter(
    redirect: redirect,
    routes: [
      GoRoute(
        path: '/',
        name: MainScreen.routeName,
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'search',
            name: SearchScreen.routeName,
            builder: (context, state) => const SearchScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/splash',
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: LoginHomeScreen.routeName,
        builder: (context, state) => const LoginHomeScreen(),
        routes: [
          GoRoute(
            path: 'phone',
            name: PhoneLoginScreen.routeName,
            builder: (context, state) => const PhoneLoginScreen(),
            routes: [
              GoRoute(
                path: 'join',
                name: PhoneJoinScreen.routeName,
                builder: (context, state) => const PhoneJoinScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
