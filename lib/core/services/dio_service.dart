import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'auth_persistence_service.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  static DioService get instance => _instance;
  
  late final Dio dio;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  DioService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          AppLogger.debug('🔄 Logging: Token existence check in interceptor - ${token != null ? 'Exists' : 'Does not exist'}');
          
          if (token != null) {
            // Log more details about the token for debugging
            AppLogger.debug('🔄 Logging: Token prefix: ${token.length > 10 ? token.substring(0, 10) : token}...');
            AppLogger.debug('🔄 Logging: Token length: ${token.length}');
            AppLogger.debug('🔄 Logging: Adding Authorization header to request');
            
            options.headers['Authorization'] = 'Bearer $token';
            
            // Log the final headers for debugging
            AppLogger.debug('🔄 Logging: Request headers contain Authorization: ${options.headers.containsKey('Authorization')}');
          } else {
            AppLogger.debug('⚠️ Logging: No token available, request will be unauthenticated');
          }
          
          // Log request details with special attention to device token updates
          AppLogger.debug('🔄 Logging: Making request to: ${options.method} ${options.path}');
          if (options.path.contains('device-token')) {
            AppLogger.debug('📱 Logging: DEVICE TOKEN UPDATE REQUEST - Auth header present: ${options.headers.containsKey('Authorization')}');
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          AppLogger.debug('❌ Logging: Request failed with status: ${error.response?.statusCode}');
          
          if (error.response?.statusCode == 401) {
            AppLogger.debug('❌ Logging: 401 Unauthorized error detected');
            
            // Intentar auto-refresh si no es el endpoint de refresh
            if (!error.requestOptions.path.contains('/api/auth/refresh')) {
              AppLogger.debug('🔄 Attempting auto-refresh token');
              
              final refreshSuccessful = await _attemptTokenRefresh();
              
              if (refreshSuccessful) {
                AppLogger.debug('✅ Token refreshed, retrying original request');
                
                // Actualizar el token en la solicitud original
                final newToken = await _storage.read(key: _tokenKey);
                if (newToken != null) {
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  
                  try {
                    // Reintentar la solicitud original
                    final response = await dio.fetch(error.requestOptions);
                    return handler.resolve(response);
                  } catch (e) {
                    AppLogger.debug('❌ Retry failed after token refresh');
                    // Si falla el reintento, continuar con el error original
                  }
                }
              } else {
                AppLogger.debug('❌ Token refresh failed, clearing auth state');
                await _clearAuthState();
              }
            } else {
              AppLogger.debug('❌ Refresh endpoint failed, clearing auth state');
              await _clearAuthState();
            }
            
            // Log extra details for device token requests
            if (error.requestOptions.path.contains('device-token')) {
              AppLogger.debug('📱 Logging: 401 ERROR ON DEVICE TOKEN REQUEST');
              AppLogger.debug('📱 Logging: Request had auth header: ${error.requestOptions.headers.containsKey('Authorization')}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        AppLogger.debug('❌ No refresh token found');
        return false;
      }

      AppLogger.debug('🔄 Attempting to refresh token');
      
      // Crear una nueva instancia de Dio para evitar recursión infinita
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));
      
      final response = await refreshDio.post('/api/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        
        if (newAccessToken != null) {
          AppLogger.debug('✅ Token refreshed successfully');
          
          await _storage.write(key: _tokenKey, value: newAccessToken);
          if (newRefreshToken != null) {
            await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
          }
          
          return true;
        }
      }
      
      AppLogger.debug('❌ Token refresh failed - invalid response');
      return false;
    } catch (e) {
      AppLogger.error('❌ Error refreshing token', error: e);
      return false;
    }
  }

  Future<void> _clearAuthState() async {
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _refreshTokenKey),
        AuthPersistenceService.clearAuthState(),
      ]);
      AppLogger.debug('🧹 Auth state cleared');
    } catch (e) {
      AppLogger.error('❌ Error clearing auth state', error: e);
    }
  }
} 