import '../../../../core/api/api_client.dart';
import '../../../../core/exceptions/exceptions.dart' as app_exceptions;
import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> createProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  });

  Future<UserProfileModel?> getProfileByUserId(String userId);

  Future<UserProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  });

  Future<void> deleteProfile(String userId);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final ApiClient _apiClient;
  static const String _tableName = 'user_profiles';

  UserProfileRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<UserProfileModel> createProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final data = {
        'user_id': userId,
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.post(_tableName, data);
      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.AppException('Failed to create user profile: $e');
    }
  }

  @override
  Future<UserProfileModel?> getProfileByUserId(String userId) async {
    try {
      final response = await _apiClient.get(
        _tableName,
        filterColumn: 'user_id',
        filterValue: userId,
        limit: 1,
      );

      if (response.isEmpty) return null;
      return UserProfileModel.fromJson(response.first);
    } catch (e) {
      throw app_exceptions.AppException('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      // Lấy profile hiện tại để có id
      final currentProfile = await getProfileByUserId(userId);
      if (currentProfile == null) {
        throw app_exceptions.AppException('User profile not found');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (email != null) updateData['email'] = email;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      final response = await _apiClient.update(_tableName, currentProfile.id, updateData);
      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.AppException('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      final profile = await getProfileByUserId(userId);
      if (profile != null) {
        await _apiClient.delete(_tableName, profile.id);
      }
    } catch (e) {
      throw app_exceptions.AppException('Failed to delete user profile: $e');
    }
  }
}

