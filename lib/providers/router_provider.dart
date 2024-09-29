import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/firebase_logger.dart';
import 'package:music_dabang/common/firebase_route_observer.dart';
import 'package:music_dabang/models/user/user_model.dart';
import 'package:music_dabang/providers/user/user_provider.dart';
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

    String? redirectTo;
    if (user is UserModelLoading) {
      redirectTo = '/splash';
    } else if (user is UserModelNone || user is UserModelError) {
      redirectTo = '/login';
    } else if (user is UserModel) {
      if (currentPath == '/login' || currentPath == '/splash') {
        redirectTo = '/';
      }
    }

    if (redirectTo != null) {
      FirebaseLogger.redirect(from: state.uri.path, to: redirectTo);
      debugPrint('redirect result: $redirectTo');
      return redirectTo;
    }

    debugPrint('redirect result: no redirect');
    return null;
  }

  return GoRouter(
    initialLocation: '/splash',
    routerNeglect: true,
    redirect: redirect,
    observers: [
      FirebaseAnalyticsGoRouterObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [
      GoRoute(
        path: '/splash',
        name: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: MainScreen.routeName,
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'search',
            name: SearchScreen.routeName,
            builder: (context, state) => const SearchScreen(),
            pageBuilder: (context, state) => createSlideGoRoute(
              const SearchScreen(),
            ),
          ),
        ],
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

CustomTransitionPage createSlideGoRoute(
  Widget child, {
  bool opaque = true,
}) {
  return CustomTransitionPage(
    child: child,
    opaque: opaque,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
