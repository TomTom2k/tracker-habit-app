import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  /// Khởi tạo Supabase client
  /// [supabaseUrl] và [supabaseAnonKey] có thể được truyền vào hoặc lấy từ .env
  static Future<void> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    if (_initialized) return;

    try {
      // Lấy URL và Anon Key từ parameters, .env, hoặc environment variables
      final url = supabaseUrl ?? 
                  dotenv.env['SUPABASE_URL'] ?? 
                  SupabaseConfig.supabaseUrl;
      final anonKey = supabaseAnonKey ?? 
                     dotenv.env['SUPABASE_ANON_KEY'] ?? 
                     SupabaseConfig.supabaseAnonKey;

      if (url.isEmpty || anonKey.isEmpty) {
        throw Exception(
          'Supabase URL and Anon Key must be provided. '
          'Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env file, '
          'environment variables, or pass them as parameters.',
        );
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true, // Set false in production
        // Supabase Flutter tự động persist session trong secure storage
        // và auto refresh token, không cần cấu hình thêm
      );

      _client = Supabase.instance.client;
      _initialized = true;
      
      // Kiểm tra và restore session nếu có
      final session = _client?.auth.currentSession;
      if (session != null) {
        print('Supabase initialized with existing session for user: ${session.user.email}');
      } else {
        print('Supabase initialized successfully (no existing session)');
      }
    } catch (e) {
      print('Error initializing Supabase: $e');
      rethrow;
    }
  }

  /// Lấy Supabase client instance
  static SupabaseClient get client {
    if (!_initialized || _client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Kiểm tra xem Supabase đã được khởi tạo chưa
  static bool get isInitialized => _initialized;

  /// Lấy current user
  static User? get currentUser => _client?.auth.currentUser;

  /// Kiểm tra user đã đăng nhập chưa
  static bool get isAuthenticated => currentUser != null;

  /// Đăng xuất
  static Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}

