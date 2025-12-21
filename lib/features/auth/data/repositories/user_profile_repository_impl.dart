import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfileEntity> createProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    return await remoteDataSource.createProfile(
      userId: userId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<UserProfileEntity?> getProfileByUserId(String userId) async {
    return await remoteDataSource.getProfileByUserId(userId);
  }

  @override
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    return await remoteDataSource.updateProfile(
      userId: userId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> deleteProfile(String userId) async {
    await remoteDataSource.deleteProfile(userId);
  }
}



