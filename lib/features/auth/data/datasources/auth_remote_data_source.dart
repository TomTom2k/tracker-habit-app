import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/gotrue.dart';
import '../../../../core/exceptions/exceptions.dart' as app_exceptions;
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_parser.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase = SupabaseService.client;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'full_name': name} : null,
      );

      if (response.user == null) {
        throw const app_exceptions.AppAuthException(
          'Không thể tạo tài khoản. Vui lòng thử lại.',
        );
      }

      // Kiểm tra xem có session không (nếu email confirmation tắt thì sẽ có session)
      // Nếu không có session, có thể cần confirm email trước
      if (response.session == null) {
        print('Warning: No session after sign up. Email confirmation may be required.');
        // Nếu email confirmation được bật, user cần confirm email trước khi đăng nhập
        // Vẫn trả về user nhưng sẽ cần confirm email
        // User có thể đăng nhập sau khi confirm email
        throw const app_exceptions.AppAuthException(
          'Vui lòng kiểm tra email để xác nhận tài khoản trước khi đăng nhập.',
        );
      } else {
        print('Sign up successful with session');
        // Đảm bảo session được set trong Supabase client
        // Session đã được set tự động bởi Supabase Flutter SDK
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      // Parse Supabase AuthException thành app exception
      throw ErrorParser.parseError(e);
    } on app_exceptions.AppAuthException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ErrorParser.parseError(e);
    } catch (e) {
      // Parse generic error
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const app_exceptions.InvalidCredentialsException(
          'Email hoặc mật khẩu không đúng.',
        );
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      // Parse Supabase AuthException thành app exception
      throw ErrorParser.parseError(e);
    } on app_exceptions.AppAuthException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ErrorParser.parseError(e);
    } catch (e) {
      // Parse generic error
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sử dụng OAuth flow với redirect URL
      // Redirect URL phải khớp với cấu hình trong Supabase Dashboard
      // signInWithOAuth sẽ mở browser tự động
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.habittracker://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Browser sẽ được mở tự động bởi Supabase
      // App sẽ đợi deep link callback từ browser
      print('OAuth flow started, waiting for callback...');

      // Đợi session được tạo (sau khi redirect về app qua deep link)
      // Polling để đợi session được tạo từ deep link
      int attempts = 0;
      const maxAttempts = 60; // 60 giây timeout (tăng lên để đợi user đăng nhập)
      
      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        final session = _supabase.auth.currentSession;
        if (session != null) {
          final user = _supabase.auth.currentUser;
          if (user != null) {
            print('Google sign in successful');
            return UserModel.fromSupabaseUser(user);
          }
        }
        
        attempts++;
      }
      
      // Nếu không có session sau khi đợi, throw error
      throw const app_exceptions.AppAuthException(
        'Đăng nhập Google bị hủy hoặc quá thời gian. Vui lòng thử lại.',
      );
    } on AuthException catch (e) {
      throw ErrorParser.parseError(e);
    } on app_exceptions.AppAuthException {
      rethrow;
    } catch (e) {
      print('Google sign in error: $e');
      throw ErrorParser.parseError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw app_exceptions.AppAuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw app_exceptions.AppAuthException('Failed to get current user: ${e.toString()}');
    }
  }
}

