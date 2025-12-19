import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/exceptions/exceptions.dart' as app_exceptions;
import '../../../../core/services/user_session_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository}) {
    _initialize();
  }

  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> _initialize() async {
    try {
      _user = await authRepository.getCurrentUser();
      
      // Nếu có user, lưu vào local storage
      if (_user != null) {
        await UserSessionService.saveUserSession(
          userId: _user!.id,
          email: _user!.email,
          name: _user!.name,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      
      // Lưu thông tin user vào local storage
      await UserSessionService.saveUserSession(
        userId: _user!.id,
        email: _user!.email,
        name: _user!.name,
      );
      
      _setLoading(false);
      return true;
    } on app_exceptions.AppAuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _user = await authRepository.signIn(
        email: email,
        password: password,
      );
      
      // Lưu thông tin user vào local storage
      await UserSessionService.saveUserSession(
        userId: _user!.id,
        email: _user!.email,
        name: _user!.name,
      );
      
      _setLoading(false);
      return true;
    } on app_exceptions.InvalidCredentialsException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } on app_exceptions.AppAuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      _user = await authRepository.signInWithGoogle();
      
      // Lưu thông tin user vào local storage
      await UserSessionService.saveUserSession(
        userId: _user!.id,
        email: _user!.email,
        name: _user!.name,
      );
      
      _setLoading(false);
      return true;
    } on app_exceptions.AppAuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Failed to sign in with Google';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      await authRepository.signOut();
      await UserSessionService.clearUserSession();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to sign out';
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Refresh user từ repository (dùng cho OAuth callback)
  Future<void> refreshUser() async {
    try {
      _user = await authRepository.getCurrentUser();
      
      if (_user != null) {
        await UserSessionService.saveUserSession(
          userId: _user!.id,
          email: _user!.email,
          name: _user!.name,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

