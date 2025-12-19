import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý user session và lưu thông tin user locally
class UserSessionService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Lưu thông tin user vào local storage
  static Future<void> saveUserSession({
    required String userId,
    String? email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setBool(_isLoggedInKey, true);
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
    if (name != null) {
      await prefs.setString(_userNameKey, name);
    }
  }

  /// Lấy user ID từ local storage
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Lấy email từ local storage
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Lấy tên user từ local storage
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Kiểm tra user đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Xóa thông tin user session
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}

