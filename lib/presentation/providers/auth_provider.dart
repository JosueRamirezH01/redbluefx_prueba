import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redbluefx/core/services/loginStorage.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../core/utils/logger.dart';
import '../../core/services/firebase_messaging_service.dart';
import '../../core/services/auth_persistence_service.dart';
import 'package:dio/dio.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initializeFromPersistedState();
  }
  final AuthRepository _repository;

  Future<void> _initializeFromPersistedState() async {
    try {
      final persistedState = await AuthPersistenceService.loadAuthState();
      
      if (persistedState != null && persistedState.isAuthenticated) {
        final hasValidToken = await _repository.hasTokenLocally();
        
        if (hasValidToken) {
          state = persistedState.copyWith(isLoading: false);
          _scheduleBackgroundAuthCheck();
        } else {
          await AuthPersistenceService.clearAuthState();
          await _repository.deleteToken();
        }
      }
    } catch (e) {
      AppLogger.error('Error initializing from persisted state', error: e);
    }
  }

  Future<void> _scheduleBackgroundAuthCheck() async {
    try {
      final shouldCheck = await AuthPersistenceService.shouldPerformFullAuthCheck();
      if (shouldCheck) {
        final currentUser = await _repository.getCurrentUser();
        if (currentUser == null) {
          await logout();
        } else {
          await AuthPersistenceService.updateLastAuthCheck();
        }
      }
    } catch (e) {
      AppLogger.error('Error in background auth check', error: e);
    }
  }

  Future<void> checkAuthStatus() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final isAuthenticated = await _repository.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await _repository.getCurrentUser();
        
        if (user != null) {
          final newState = state.copyWith(
            isAuthenticated: true,
            currentUser: user,
            isLoading: false,
            error: null,
          );
          state = newState;
          
          await _persistState(newState);
          
          _updateDeviceToken();
          
          return;
        }
      }

      final newState = state.copyWith(
        isAuthenticated: false,
        currentUser: null,
        isLoading: false,
        error: null,
      );
      state = newState;
      
      await AuthPersistenceService.clearAuthState();
    } catch (e) {
      final newState = state.copyWith(
        isAuthenticated: false,
        currentUser: null,
        error: e.toString(),
        isLoading: false,
      );
      state = newState;
      
      await AuthPersistenceService.clearAuthState();
    }
  }

  Future<void> _persistState(AuthState authState) async {
    try {
      await AuthPersistenceService.saveAuthState(authState);
    } catch (e) {
      AppLogger.error('Error persisting auth state', error: e);
    }
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.login(email, password, rememberMe: rememberMe);
      final newState = state.copyWith(
        isAuthenticated: true,
        currentUser: user,
        isLoading: false,
        error: null,
      );
      state = newState;
      
      await _persistState(newState);

      _updateDeviceToken();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
        currentUser: null,
      );
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(email, password, fullName);
      
      if (user != null) {
        final newState = state.copyWith(
          isAuthenticated: true,
          currentUser: user,
          isLoading: false,
          error: null,
        );
        state = newState;
        
        await _persistState(newState);
        
        _updateDeviceToken();
      } else {
        final newState = state.copyWith(
          isAuthenticated: false,
          currentUser: null,
          isLoading: false,
          error: null,
        );
        state = newState;
        
        await AuthPersistenceService.clearAuthState();
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
        currentUser: null,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.logout();
      
      await AuthPersistenceService.clearAuthState();
      await LoginStorage.clearCredentials();
      state = const AuthState();
    } catch (e) {
      await AuthPersistenceService.clearAuthState();
      
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.requestPasswordReset(email);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(token, newPassword);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> resetPasswordInter(String currentPassword,String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPasswordInter(currentPassword, newPassword);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> verifyEmail(String email, String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.verifyEmail(email, token);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> resendEmailVerification(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resendEmailVerification(email);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final token = await _repository.getToken();
      if (token == null) {
        throw Exception('No estás autenticado. Por favor, inicia sesión nuevamente.');
      }
      
      await _repository.deleteAccount();
      
      state = const AuthState();
    } on DioException catch (e) {
      String errorMessage = 'Error al eliminar la cuenta';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'No tienes permisos para realizar esta acción.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Usuario no encontrado.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Error interno del servidor. Intenta de nuevo más tarde.';
      } else if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? errorMessage;
        }
      }
      
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Error inesperado al eliminar la cuenta. Intenta de nuevo.',
        isLoading: false,
      );
    }
  }

  Future<void> _updateDeviceToken() async {
    try {
      AppLogger.debug('🔄 Logging: Starting device token update process');
      
      // Pequeño delay para asegurar que el token de auth esté guardado
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verificar que tenemos el token de autenticación antes de proceder
      final authToken = await _repository.getToken();
      AppLogger.debug('🔄 Logging: Auth token check before device token update - ${authToken != null ? 'Available' : 'Not available'}');
      
      if (authToken == null) {
        AppLogger.debug('⚠️ Logging: No auth token available, skipping device token update');
        return;
      }
      
      final token = await FirebaseMessagingService.instance.getToken();
      if (token != null) {
        AppLogger.debug('🔄 Logging: FCM token obtained, proceeding with server update');
        await FirebaseMessagingService.instance.updateTokenOnServer(_repository);
        AppLogger.debug('✅ Logging: Device token update completed successfully');
      } else {
        AppLogger.debug('⚠️ Logging: FCM token is null, skipping update');
      }
    } catch (e) {
      AppLogger.error('❌ Logging: Error in device token update process', error: e);
    }
  }

  void updateCurrentUser(User user) {
    state = state.copyWith(currentUser: user);
  }
} 