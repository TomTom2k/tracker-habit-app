import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Service để xử lý deep links từ OAuth callback
class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Khởi tạo listener cho deep links
  static void initialize() {
    // Listen cho deep links khi app đang chạy
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );

    // Xử lý deep link khi app được mở từ link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  /// Xử lý deep link từ OAuth callback
  static Future<void> _handleDeepLink(Uri uri) async {
    print('Received deep link: $uri');

    // Kiểm tra xem có phải OAuth callback không
    if (uri.scheme == 'io.supabase.habittracker' &&
        (uri.host == 'login-callback' || uri.host.isEmpty)) {
      // Navigate đến callback page để xử lý OAuth
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Chuyển đổi deep link URI thành route
        context.go('/auth/callback');
      } else {
        print('Navigator context not available');
      }
    }
  }

  /// Dispose listener
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

