// File: lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import screens for app template
import '../../View/Screens/On_Boarding/intro_screen.dart';
import '../../View/Screens/On_Boarding/landing_login.dart';
import '../../View/Screens/On_Boarding/splash_screen.dart';
import '../../View/Screens/home/home_screen.dart';
import '../../View/Screens/profile/profile_screen.dart';

class AppRouter {
  // Define route names as constants for better maintainability
  static const String splash = '/';
  static const String intro = '/intro';
  static const String landing = '/landing';
  static const String home = '/home';
  static const String profile = '/profile';

  // Create a custom transition
  static CustomTransitionPage buildTransition({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  final GoRouter router;

  AppRouter() : router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: intro,
        pageBuilder: (context, state) => buildTransition(
          key: state.pageKey,
          child: const IntroductionScreenExample(),
        ),
      ),
      GoRoute(
        path: landing,
        pageBuilder: (context, state) => buildTransition(
          key: state.pageKey,
          child: const LandingPage(),
        ),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => buildTransition(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: profile,
        pageBuilder: (context, state) => buildTransition(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
    ],
  );
}