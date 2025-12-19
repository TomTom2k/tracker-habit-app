class SupabaseConfig {
  // Lấy từ environment variables hoặc hardcode cho development
  // Trong production, nên sử dụng flutter_dotenv hoặc build config
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Hoặc sử dụng với flutter_dotenv
  static String? getUrlFromEnv() {
    // Sẽ được load từ .env file
    return null;
  }

  static String? getAnonKeyFromEnv() {
    // Sẽ được load từ .env file
    return null;
  }
}

