import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/api_routes.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/dio_service.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl({
    Dio? dio,
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  })  : _dio = dio ?? DioService.instance.dio,
        _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client() {
    AppLogger.debug('🔄 AuthRepositoryImpl constructor called');
  }
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final http.Client _httpClient;
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';
  static const _deviceTokenKey = 'device_token';

  @override
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/api/auth/delete-account');
    } catch (e) {
      AppLogger.error('Error al eliminar la cuenta: $e');
      rethrow;
    }
  }

  @override
  Future<User> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final uri = Uri.parse('${AppConfig.instance.baseUrl}${ApiRoutes.login}');

      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'rememberMe': rememberMe,
        }),
      );

      if (response.statusCode != 200) {
        // Intentar decodificar como JSON primero
        try {
          final error = jsonDecode(response.body);
          final message = error['message'] ?? 'Error de autenticación';
          
          // Manejar códigos específicos
          if (response.statusCode == 403) {
            throw Exception('ACCOUNT_INACTIVE:$message');
          } else if (response.statusCode == 401) {
            throw Exception('INVALID_CREDENTIALS:$message');
          } else {
            throw Exception(message);
          }
        } catch (e) {
          // Si no es JSON, usar el texto directamente
          if (response.statusCode == 403) {
            throw Exception('ACCOUNT_INACTIVE:${response.body.trim()}');
          } else if (response.statusCode == 401) {
            throw Exception('INVALID_CREDENTIALS:${response.body.trim()}');
          } else {
            throw Exception(response.body.trim());
          }
        }
      }

      // Intentar decodificar la respuesta exitosa
      try {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String?;
        
        AppLogger.debug('🔄 Access Token: $token');
        AppLogger.debug('🔄 Refresh Token: ${refreshToken != null ? "present" : "null"}');
        
        await saveToken(token);
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken);
        }

        return User.fromJson(data['user']);
      } catch (e) {
        AppLogger.error('Error decodificando respuesta de login', error: e);
        throw Exception('Error procesando la respuesta del servidor');
      }
    } catch (e) {
      if (e is Exception) throw e;
      throw Exception('Error de conexión');
    }
  }

  @override
  Future<User?> register(String email, String password, String fullName) async {
    try {
      AppLogger.debug('🔄 [REPO-REGISTER] Starting registration request');
      AppLogger.debug('🔄 [REPO-REGISTER] Email: $email, FullName: $fullName');
      
      final uri = Uri.parse('${AppConfig.instance.baseUrl}${ApiRoutes.register}');
      AppLogger.debug('🔄 [REPO-REGISTER] Request URL: $uri');
      
      final requestBody = {
        'email': email,
        'password': password,
        'fullName': fullName,
      };
      AppLogger.debug('🔄 [REPO-REGISTER] Request body: ${requestBody.keys.toList()}');
      
      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      AppLogger.debug('🔄 [REPO-REGISTER] Response status: ${response.statusCode}');
      AppLogger.debug('🔄 [REPO-REGISTER] Response body: ${response.body}');

      // Intentar decodificar la respuesta
      try {
        final data = jsonDecode(response.body);
        AppLogger.debug('🔄 [REPO-REGISTER] Response decoded successfully');

        if (response.statusCode != 200 && response.statusCode != 201) {
          AppLogger.debug('❌ [REPO-REGISTER] Non-success status code: ${response.statusCode}');
          final errorMessage = data['message'] as String?;
          if (errorMessage != null) {
            AppLogger.debug('❌ [REPO-REGISTER] Error message from server: $errorMessage');
            throw Exception(errorMessage);
          }
          throw Exception('Error de registro');
        }

        AppLogger.debug('✅ [REPO-REGISTER] Registration successful');
        
        // Check if this is the new flow (no token, requires email verification)
        if (data['requiresEmailVerification'] == true) {
          AppLogger.debug('🔄 [REPO-REGISTER] Registration requires email verification');
          AppLogger.debug('🔄 [REPO-REGISTER] Returning null (no authentication yet)');
          // For the new flow, we don't get a token immediately
          // Return null to indicate successful registration but no authentication yet
          return null;
        }

        // Old flow - immediate token
        AppLogger.debug('🔄 [REPO-REGISTER] Old flow detected - token provided');
        final token = data['token'] as String;
        AppLogger.debug('🔄 [REPO-REGISTER] Token received, saving...');
        await saveToken(token);

        final user = User.fromJson(data['user']);
        AppLogger.debug('✅ [REPO-REGISTER] User created and token saved');
        return user;
      } catch (e) {
        AppLogger.debug('❌ [REPO-REGISTER] Error processing response: $e');
        if (response.statusCode != 200 && response.statusCode != 201) {
          try {
            final errorData = jsonDecode(response.body);
            throw Exception(errorData['message'] ?? response.body.trim());
          } catch (_) {
            throw Exception(response.body.trim());
          }
        }
        AppLogger.error('Error decodificando respuesta de registro', error: e);
        throw e; // Re-throw the original exception
      }
    } catch (e) {
      AppLogger.debug('❌ [REPO-REGISTER] Final catch block: $e');
      if (e is Exception) throw e;
      throw Exception('Error de conexión');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiRoutes.logout);
    } catch (e) {
      AppLogger.warning('Error al hacer logout en el servidor: ${e.toString()}');
    } finally {
      await deleteToken();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _dio.get(ApiRoutes.me);
      return User.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Error obteniendo usuario actual', error: e);
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      if (token == null) {
        AppLogger.debug('❌ Logging: No token found, user not authenticated');
        return false;
      }
      
      AppLogger.debug('🔍 Logging: Token found, validating with server');
      
      // Validar el token haciendo una llamada rápida al servidor
      final response = await _dio.get(ApiRoutes.me);
      
      if (response.statusCode == 200 && response.data != null) {
        AppLogger.debug('✅ Logging: Token is valid');
        return true;
      } else {
        AppLogger.debug('❌ Logging: Token validation failed - invalid response');
        await deleteToken();
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Logging: Error validating token', error: e);
      
      // Si hay error de red, mantener el token pero retornar false
      // para permitir intentos posteriores
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          AppLogger.debug('🔄 Logging: Token is invalid, removing');
          await deleteToken();
        } else {
          AppLogger.debug('🔄 Logging: Network error, keeping token for retry');
        }
      }
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    AppLogger.debug('🔄 Guardando token: ${token.substring(0, 10)}...');
    await _storage.write(key: _tokenKey, value: token);
    AppLogger.debug('🔄 Token guardado exitosamente');
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Refresh Token methods
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    AppLogger.debug('🔄 Guardando refresh token');
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    AppLogger.debug('🔄 Refresh token guardado exitosamente');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> deleteAllTokens() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
    ]);
  }

  // Auto-refresh token functionality
  Future<bool> refreshTokenIfNeeded() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        AppLogger.debug('❌ No refresh token found');
        return false;
      }

      AppLogger.debug('🔄 Attempting to refresh token');
      
      final response = await _dio.post('/api/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken = data['token'] as String;
        final newRefreshToken = data['refreshToken'] as String?;
        
        AppLogger.debug('✅ Token refreshed successfully');
        
        await saveToken(newAccessToken);
        if (newRefreshToken != null) {
          await saveRefreshToken(newRefreshToken);
        }
        
        return true;
      } else {
        AppLogger.debug('❌ Token refresh failed');
        await deleteAllTokens();
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Error refreshing token', error: e);
      
      // If refresh fails with 401, delete tokens
      if (e is DioException && e.response?.statusCode == 401) {
        await deleteAllTokens();
      }
      
      return false;
    }
  }

  // Método más liviano para verificar solo la existencia del token
  @override
  Future<bool> hasTokenLocally() async {
    final token = await getToken();
    return token != null;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post('/api/auth/request-reset', data: {
        'email': email,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post('/api/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> verifyEmail(String email, String token) async {
    try {
      AppLogger.debug('🔄 Verifying email with email: $email');
      AppLogger.debug('🔄 Verifying email with token: $token');
      
      await _dio.post('/api/auth/verify-email', data: {
        'email': email,
        'token': token,
      });
      
      AppLogger.debug('✅ Email verification successful from repository');
    } catch (e) {
      AppLogger.error('❌ Email verification failed in repository', error: e);
      throw _handleError(e);
    }
  }

  @override
  Future<void> resendEmailVerification(String email) async {
    try {
      await _dio.post('/auth/resend-verification', data: {
        'email': email,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateDeviceToken(String deviceToken) async {
    try {
      AppLogger.debug('🔄 Updating device token on server');
      await _dio.put(ApiRoutes.deviceToken, data: {
        'deviceToken': deviceToken,
      });
      AppLogger.debug('✅ Device token updated successfully');
    } catch (e) {
      AppLogger.error('❌ Error updating device token', error: e);
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    AppLogger.debug('🔄 _handleError called with error type: ${error.runtimeType}');
    
    if (error is DioException) {
      final response = error.response;
      
      if (response != null) {
        // Manejo seguro de diferentes tipos de response.data
        String? message;
        
        if (response.data is Map<String, dynamic>) {
          // Si es un Map (JSON), extraer el mensaje
          message = response.data['message'] as String?;
        } else if (response.data is String) {
          // Si es un String, usar directamente
          message = response.data as String;
        } else {
        }
        
        return Exception(message ?? 'Error de autenticación');
      }
    }
    
    AppLogger.debug('🔄 Returning generic connection error');
    return Exception('Error de conexión');
  }
  
  @override
  Future<String> uploadProfilePicture(String imagePath) async {
    AppLogger.debug('🔄 Iniciando subida de foto de perfil');
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final fileName = imagePath.split('/').last;
      final fileSize = bytes.length;
      
      // Paso 1: Solicitar URL presignada
      AppLogger.debug('🔄 Solicitando URL presignada');
      AppLogger.debug('🔄 URL: ${AppConfig.instance.baseUrl}/api/uploadthing?slug=profilePicture&actionType=upload');
      
      final requestBody = {
        'files': [
          {
            'name': fileName,
            'size': fileSize,
            'type': _getMimeType(fileName),
          }
        ]
      };
      
      AppLogger.debug('🔄 Request body antes de enviar: $requestBody');
      AppLogger.debug('🔄 Request body type: ${requestBody.runtimeType}');
      
      final presignedResponse = await _dio.post(
        '/api/uploadthing',
        queryParameters: {
          'slug': 'profilePicture',
          'actionType': 'upload',
        },
        data: {
          'files': requestBody['files'],
        },
      );

      AppLogger.debug('🔄 Response status: ${presignedResponse.statusCode}');
      AppLogger.debug('🔄 Response data: ${presignedResponse.data}');
      AppLogger.debug('🔄 Response data type: ${presignedResponse.data.runtimeType}');

      // Verificar si la respuesta es exitosa
      if (presignedResponse.statusCode != 200) {
        AppLogger.error('❌ Error del servidor: ${presignedResponse.statusCode}');
        AppLogger.error('❌ Response data: ${presignedResponse.data}');
        throw Exception('Error del servidor: ${presignedResponse.statusCode}');
      }

      // Con Dio, la respuesta ya está parseada
      final presignedData = presignedResponse.data;
      AppLogger.debug('🔄 Decoded data: $presignedData');
      AppLogger.debug('🔄 Decoded data type: ${presignedData.runtimeType}');
      
      // El servidor devuelve una lista directamente, no un objeto con 'data'
      dynamic uploadData;
      if (presignedData is List && presignedData.isNotEmpty) {
        uploadData = presignedData[0];
        AppLogger.debug('🔄 Using direct list access: ${presignedData[0]}');
      } else if (presignedData is Map && presignedData['data'] != null && presignedData['data'].isNotEmpty) {
        uploadData = presignedData['data'][0];
        AppLogger.debug('🔄 Using nested data access: ${presignedData['data'][0]}');
      } else {
        AppLogger.error('❌ No se pudo obtener URL presignada');
        AppLogger.debug('🔄 presignedData is null: ${presignedData == null}');
        if (presignedData != null) {
          AppLogger.debug('🔄 presignedData type: ${presignedData.runtimeType}');
          if (presignedData is Map) {
            AppLogger.debug('🔄 presignedData keys: ${presignedData.keys}');
          }
          if (presignedData is List) {
            AppLogger.debug('🔄 presignedData length: ${presignedData.length}');
          }
        }
        throw Exception('No se pudo obtener URL presignada');
      }
      AppLogger.debug('🔄 uploadData: $uploadData');
      AppLogger.debug('🔄 uploadData type: ${uploadData.runtimeType}');
      
      if (uploadData is Map) {
        AppLogger.debug('🔄 uploadData keys: ${uploadData.keys}');
        AppLogger.debug('🔄 uploadData[url]: ${uploadData['url']}');
        AppLogger.debug('🔄 uploadData[url] type: ${uploadData['url']?.runtimeType}');
        AppLogger.debug('🔄 uploadData[fields]: ${uploadData['fields']}');
        AppLogger.debug('🔄 uploadData[fields] type: ${uploadData['fields']?.runtimeType}');
        AppLogger.debug('🔄 uploadData[appUrl]: ${uploadData['appUrl']}');
        AppLogger.debug('🔄 uploadData[appUrl] type: ${uploadData['appUrl']?.runtimeType}');
      }
      
      AppLogger.debug('🔄 Intentando hacer cast de uploadData[url] a String');
      final presignedUrl = uploadData['url'] as String;
      AppLogger.debug('🔄 Cast de url exitoso: $presignedUrl');
      
      // Los campos van directamente en la URL presignada para UploadThing
      final fields = <String, dynamic>{};
      
      // La URL final se construye a partir del key
      final key = uploadData['key'] as String;
      final fileUrl = 'https://utfs.io/f/$key';
      AppLogger.debug('🔄 URL final del archivo: $fileUrl');

      // Paso 2: Subir archivo directamente a UploadThing
      AppLogger.debug('🔄 Subiendo archivo a UploadThing');
      
      // Crear FormData para la subida
      final uploadFormData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      // Realizar upload directo a UploadThing
      final uploadResponse = await _dio.put(
        presignedUrl,
        data: uploadFormData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      AppLogger.debug('✅ Foto de perfil subida exitosamente');
      return fileUrl;
    } on DioException catch (e) {
      AppLogger.error('❌ Error al subir foto de perfil', error: e);
      if (e.response?.data != null) {
        AppLogger.debug('Response data: ${e.response?.data}');
      }
      throw _handleError(e);
    } catch (e) {
      AppLogger.error('❌ Error inesperado al subir foto de perfil', error: e);
      throw Exception('Error al subir la foto de perfil: $e');
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Future<void> updateProfilePicture(String imageUrl) async {
    AppLogger.debug('📸 Logging: Profile picture URL received from UploadThing - no server update needed');
    // El backend ya actualiza automáticamente la profilePictureUrl cuando se sube a UploadThing
    // Este método ya no es necesario pero lo mantenemos por compatibilidad
    AppLogger.debug('📸 Logging: Profile picture update handled automatically by backend UserService');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    };
  }
} 