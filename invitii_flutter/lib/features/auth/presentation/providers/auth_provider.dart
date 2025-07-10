import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/user.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error) {
      state = AsyncValue.data(null);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final authResponse = await _authRepository.signIn(
        LoginRequest(email: email, password: password),
      );
      
      // Store tokens
      await _storeTokens(authResponse.token, authResponse.refreshToken);
      
      state = AsyncValue.data(authResponse.user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password, {String? phoneNumber}) async {
    state = const AsyncValue.loading();
    
    try {
      final authResponse = await _authRepository.signUp(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
        ),
      );
      
      // Store tokens
      await _storeTokens(authResponse.token, authResponse.refreshToken);
      
      state = AsyncValue.data(authResponse.user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      await _clearTokens();
      state = const AsyncValue.data(null);
    } catch (error) {
      // Even if sign out fails on server, clear local data
      await _clearTokens();
      state = const AsyncValue.data(null);
    }
  }

  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }
      
      final authResponse = await _authRepository.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );
      
      await _storeTokens(authResponse.token, authResponse.refreshToken);
      state = AsyncValue.data(authResponse.user);
    } catch (error) {
      // If refresh fails, sign out user
      await signOut();
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _authRepository.updateProfile(
        UpdateProfileRequest(
          name: name,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
        ),
      );
      
      state = AsyncValue.data(updatedUser);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _authRepository.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authRepository.forgotPassword(
        ForgotPasswordRequest(email: email),
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _authRepository.resetPassword(
        ResetPasswordRequest(
          token: token,
          newPassword: newPassword,
        ),
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> _storeTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, token);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove('refresh_token');
    await prefs.remove(AppConstants.userDataKey);
  }

  // Getters for convenience
  User? get currentUser => state.value;
  bool get isAuthenticated => state.value != null;
  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  Object? get error => state.error;
  
  // Permission helpers
  bool get canCreateEvents => currentUser?.canCreateEvents ?? false;
  bool get canManageGuests => currentUser?.canManageGuests ?? false;
  bool get canScanQRCodes => currentUser?.canScanQRCodes ?? false;
  bool get canViewAnalytics => currentUser?.canViewAnalytics ?? false;
  bool get canManageUsers => currentUser?.canManageUsers ?? false;
}