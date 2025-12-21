import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_profile_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/user_profile_repository_impl.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../../features/habit/data/datasources/habit_remote_data_source.dart';
import '../../features/habit/data/repositories/habit_repository_impl.dart';
import '../../features/habit/presentation/providers/habit_provider.dart';
import '../../features/todo/data/datasources/todo_remote_data_source.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/presentation/providers/todo_provider.dart';
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

  /// Khởi tạo và trả về HabitProvider
  static HabitProvider getHabitProvider() {
    // API Client (shared)
    final apiClient = ApiClient();

    // Data sources
    final habitRemoteDataSource = HabitRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    // Repositories
    final habitRepository = HabitRepositoryImpl(
      remoteDataSource: habitRemoteDataSource,
    );

    // Providers
    return HabitProvider(habitRepository: habitRepository);
  }

  /// Khởi tạo và trả về TodoProvider
  static TodoProvider getTodoProvider() {
    // API Client (shared)
    final apiClient = ApiClient();

    // Data sources
    final todoRemoteDataSource = TodoRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    final habitRemoteDataSource = HabitRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    // Repositories
    final habitRepository = HabitRepositoryImpl(
      remoteDataSource: habitRemoteDataSource,
    );
    final todoRepository = TodoRepositoryImpl(
      remoteDataSource: todoRemoteDataSource,
      habitRepository: habitRepository,
    );

    // Providers
    return TodoProvider(todoRepository: todoRepository);
  }
}

