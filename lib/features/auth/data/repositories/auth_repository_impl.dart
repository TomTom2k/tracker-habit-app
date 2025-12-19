import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/services/supabase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserProfileRepository userProfileRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.userProfileRepository,
  });

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final user = await remoteDataSource.signUp(
      email: email,
      password: password,
      name: name,
    );

    // Tự động tạo user profile sau khi đăng ký
    try {
      await userProfileRepository.createProfile(
        userId: user.id,
        fullName: name,
        email: email,
      );
    } catch (e) {
      // Log error nhưng không throw để không block sign up
      print('Warning: Failed to create user profile: $e');
    }

    return user;
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.signIn(
      email: email,
      password: password,
    );

    // Kiểm tra và tạo user profile nếu chưa có
    await _ensureUserProfile(user);

    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final user = await remoteDataSource.signInWithGoogle();

    // Kiểm tra và tạo user profile nếu chưa có
    await _ensureUserProfile(user);

    return user;
  }

  /// Đảm bảo user profile tồn tại, nếu chưa có thì tạo mới
  Future<void> _ensureUserProfile(UserEntity user) async {
    try {
      final existingProfile = await userProfileRepository.getProfileByUserId(user.id);
      if (existingProfile == null) {
        // Tạo profile mới nếu chưa có
        await userProfileRepository.createProfile(
          userId: user.id,
          fullName: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        );
      } else {
        // Cập nhật profile nếu có thông tin mới từ auth
        await userProfileRepository.updateProfile(
          userId: user.id,
          fullName: user.name ?? existingProfile.fullName,
          email: user.email ?? existingProfile.email,
          avatarUrl: user.avatarUrl ?? existingProfile.avatarUrl,
        );
      }
    } catch (e) {
      // Log error nhưng không throw để không block sign in
      print('Warning: Failed to sync user profile: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  bool isAuthenticated() {
    return SupabaseService.isAuthenticated;
  }
}

