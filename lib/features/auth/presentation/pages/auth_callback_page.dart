import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/auth_provider.dart';

/// Page để xử lý OAuth callback từ deep link
class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      // Đợi một chút để Supabase xử lý session từ URL fragments
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Kiểm tra session - Supabase tự động parse từ URL
      final supabase = SupabaseService.client;
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;
      
      if (session != null && user != null) {
        // Refresh auth provider để cập nhật user state
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Refresh user state từ session hiện tại
        await authProvider.refreshUser();
        
        // Navigate to home
        if (mounted) {
          context.go('/home');
          return;
        }
      } else {
        // Nếu không có session, đợi thêm một chút
        await Future.delayed(const Duration(seconds: 2));
        final retrySession = supabase.auth.currentSession;
        final retryUser = supabase.auth.currentUser;
        
        if (retrySession != null && retryUser != null) {
          // Refresh auth provider
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.refreshUser();
          
          if (mounted) {
            context.go('/home');
          }
        } else {
          // Nếu vẫn không có session, quay về login
          if (mounted) {
            context.go('/login');
          }
        }
      }
    } catch (e) {
      print('Error handling OAuth callback: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

