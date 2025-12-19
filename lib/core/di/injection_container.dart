import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_profile_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/user_profile_repository_impl.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../api/api_client.dart';

/// Dependency Injection Container
class InjectionContainer {
  /// Khởi tạo và trả về AuthProvider với tất cả dependencies
  static AuthProvider getAuthProvider() {
    // API Client (shared)
    final apiClient = ApiClient();

    // Data sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final userProfileRemoteDataSource = UserProfileRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    // Repositories
    final userProfileRepository = UserProfileRepositoryImpl(
      remoteDataSource: userProfileRemoteDataSource,
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      userProfileRepository: userProfileRepository,
    );

    // Providers
    return AuthProvider(authRepository: authRepository);
  }

  /// Khởi tạo và trả về UserProfileProvider
  static UserProfileProvider getUserProfileProvider() {
    // API Client (shared)
    final apiClient = ApiClient();

    // Data sources
    final userProfileRemoteDataSource = UserProfileRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    // Repositories
    final userProfileRepository = UserProfileRepositoryImpl(
      remoteDataSource: userProfileRemoteDataSource,
    );

    // Providers
    return UserProfileProvider(userProfileRepository: userProfileRepository);
  }
}

