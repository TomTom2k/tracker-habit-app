import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Đăng ký với email và password
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Đăng nhập với email và password
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Đăng nhập bằng Google
  Future<UserEntity> signInWithGoogle();

  /// Đăng xuất
  Future<void> signOut();

  /// Lấy user hiện tại
  Future<UserEntity?> getCurrentUser();

  /// Kiểm tra user đã đăng nhập chưa
  bool isAuthenticated();
}

