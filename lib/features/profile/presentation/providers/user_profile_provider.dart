import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../auth/domain/repositories/user_profile_repository.dart';
import '../../../../core/services/supabase_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileRepository userProfileRepository;

  UserProfileProvider({required this.userProfileRepository}) {
    _initialize();
  }

  UserProfileEntity? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _initialize() async {
    await loadProfile();
  }

  /// Load profile từ database
  Future<void> loadProfile() async {
    _setLoading(true);
    _error = null;

    try {
      // Lấy user ID từ auth
      final userId = await _getCurrentUserId();
      if (userId == null) {
        _error = 'User not authenticated';
        _setLoading(false);
        return;
      }

      _profile = await userProfileRepository.getProfileByUserId(userId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
      _setLoading(false);
    }
  }

  /// Cập nhật profile
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        _error = 'User not authenticated';
        _setLoading(false);
        return false;
      }

      _profile = await userProfileRepository.updateProfile(
        userId: userId,
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Lấy current user ID từ Supabase
  Future<String?> _getCurrentUserId() async {
    try {
      final user = SupabaseService.currentUser;
      return user?.id;
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

