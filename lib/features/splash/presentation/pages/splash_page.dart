import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/supabase_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Đợi một chút để app khởi động hoàn toàn
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    // Kiểm tra session từ Supabase
    final supabase = SupabaseService.client;
    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;

    // Nếu có session và user, refresh auth provider và navigate đến home
    if (session != null && user != null) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUser();
        
        if (mounted) {
          context.go('/home');
          return;
        }
      } catch (e) {
        // Nếu có lỗi, vẫn navigate đến login
        if (mounted) {
          context.go('/login');
        }
        return;
      }
    }

    // Nếu không có session, navigate đến login
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Habit Tracker',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build better habits, one day at a time',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

