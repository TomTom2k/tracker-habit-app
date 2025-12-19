import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  /// Tạo user profile mới
  Future<UserProfileEntity> createProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  });

  /// Lấy user profile theo userId
  Future<UserProfileEntity?> getProfileByUserId(String userId);

  /// Cập nhật user profile
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  });

  /// Xóa user profile
  Future<void> deleteProfile(String userId);
}

