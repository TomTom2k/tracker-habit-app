import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/auth_callback_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../services/deep_link_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: DeepLinkService.navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationPage(),
      ),
      // Route để handle OAuth callback từ deep link
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => const AuthCallbackPage(),
      ),
    ],
    // Handle deep links và redirect errors
    redirect: (context, state) {
      // Nếu là deep link callback, redirect đến callback page
      final uri = state.uri.toString();
      if (uri.contains('io.supabase.habittracker://login-callback') ||
          uri.contains('login-callback')) {
        return '/auth/callback';
      }
      return null;
    },
    errorBuilder: (context, state) {
      // Nếu có lỗi routing với deep link, redirect đến callback
      final uri = state.uri.toString();
      if (uri.contains('io.supabase.habittracker://') ||
          uri.contains('login-callback')) {
        return const AuthCallbackPage();
      }
      return const Scaffold(
        body: Center(child: Text('Page not found')),
      );
    },
  );
}

