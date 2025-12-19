import 'package:gotrue/gotrue.dart';
import 'package:postgrest/postgrest.dart';
import '../exceptions/exceptions.dart' as app_exceptions;

/// Utility class để parse và convert Supabase errors thành app exceptions
class ErrorParser {
  /// Parse error từ Supabase và convert thành app exception
  static app_exceptions.AppException parseError(dynamic error) {
    // Handle AuthApiException từ Supabase
    if (error is AuthException) {
      return _parseAuthException(error);
    }

    // Handle PostgrestException
    if (error is PostgrestException) {
      return _parsePostgrestException(error);
    }

    // Handle generic Exception
    if (error is Exception) {
      return app_exceptions.AppException(error.toString());
    }

    // Handle String errors
    if (error is String) {
      return _parseStringError(error);
    }

    // Default: convert to string
    return app_exceptions.AppException(error.toString());
  }

  /// Parse AuthException từ Supabase
  static app_exceptions.AppException _parseAuthException(AuthException error) {
    final message = error.message.toLowerCase();
    final originalMessage = error.message;

    // Parse error message - ưu tiên message vì nó chứa thông tin chi tiết
    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('invalid_credentials')) {
      return const app_exceptions.InvalidCredentialsException(
        'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.',
      );
    }

    if (message.contains('email already') ||
        message.contains('already registered') ||
        message.contains('user already registered')) {
      return const app_exceptions.EmailAlreadyExistsException(
        'Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.',
      );
    }

    if (message.contains('weak password') ||
        message.contains('password is too weak') ||
        message.contains('password')) {
      return const app_exceptions.WeakPasswordException(
        'Mật khẩu không đủ mạnh. Vui lòng sử dụng mật khẩu có ít nhất 6 ký tự.',
      );
    }

    if (message.contains('email not confirmed')) {
      return const app_exceptions.AppAuthException(
        'Email chưa được xác nhận. Vui lòng kiểm tra email và xác nhận tài khoản.',
      );
    }

    if (message.contains('network') || message.contains('connection')) {
      return const app_exceptions.NetworkException(
        'Không thể kết nối đến server. Vui lòng kiểm tra kết nối internet.',
      );
    }

    if (message.contains('too many requests') || message.contains('rate limit')) {
      return const app_exceptions.AppAuthException(
        'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau vài phút.',
      );
    }

    // Default: return friendly message
    return app_exceptions.AppAuthException(
      _getFriendlyMessage(originalMessage),
    );
  }

  /// Parse PostgrestException
  static app_exceptions.AppException _parsePostgrestException(
    PostgrestException error,
  ) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return const app_exceptions.InvalidCredentialsException();
    }

    if (message.contains('already registered')) {
      return const app_exceptions.EmailAlreadyExistsException();
    }

    return app_exceptions.ServerException(
      'Lỗi server: ${error.message}',
    );
  }

  /// Parse String error
  static app_exceptions.AppException _parseStringError(String error) {
    final message = error.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return const app_exceptions.InvalidCredentialsException();
    }

    if (message.contains('email already')) {
      return const app_exceptions.EmailAlreadyExistsException();
    }

    if (message.contains('network') || message.contains('connection')) {
      return const app_exceptions.NetworkException(
        'Không thể kết nối đến server. Vui lòng kiểm tra kết nối internet.',
      );
    }

    return app_exceptions.AppException(_getFriendlyMessage(error));
  }

  /// Convert technical error message thành friendly message
  static String _getFriendlyMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }

    final lowerMessage = message.toLowerCase();

    // Map technical messages to friendly Vietnamese messages
    if (lowerMessage.contains('authapiexception')) {
      if (lowerMessage.contains('invalid login credentials')) {
        return 'Email hoặc mật khẩu không đúng.';
      }
      if (lowerMessage.contains('email already')) {
        return 'Email này đã được sử dụng.';
      }
      return 'Lỗi xác thực. Vui lòng thử lại.';
    }

    if (lowerMessage.contains('network') || lowerMessage.contains('connection')) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối internet.';
    }

    if (lowerMessage.contains('timeout')) {
      return 'Kết nối quá lâu. Vui lòng thử lại.';
    }

    // Remove technical prefixes
    String friendly = message;
    friendly = friendly.replaceAll('AuthApiException(', '');
    friendly = friendly.replaceAll('message: ', '');
    friendly = friendly.replaceAll('statusCode: ', '');
    friendly = friendly.replaceAll('code: ', '');
    friendly = friendly.replaceAll(RegExp(r'\d+'), '');
    friendly = friendly.replaceAll('()', '');
    friendly = friendly.trim();

    // If message is still too technical, return generic message
    if (friendly.contains('AuthApiException') ||
        friendly.contains('statusCode') ||
        friendly.length > 100) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }

    return friendly;
  }
}

