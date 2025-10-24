import 'package:dio/dio.dart';
import '../../core/config/api_routes.dart';
import '../../core/services/dio_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl() : _dio = DioService.instance.dio {
    AppLogger.debug('🔄 UserRepositoryImpl constructor called');
  }

  final Dio _dio;

  @override
  Future<List<User>> getAllUsers({String? searchQuery}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      
      final response = await _dio.get(
        ApiRoutes.users,
        queryParameters: queryParams,
      );
      
      final List<dynamic> usersJson = response.data;
      final users = usersJson.map((json) => User.fromJson(json)).toList();
      AppLogger.debug('🔄 Successfully loaded ${users.length} users${searchQuery != null ? ' with search: "$searchQuery"' : ''}');
      return users;
    } catch (e, stack) {
      AppLogger.error('Error obteniendo usuarios', error: e, stackTrace: stack);
      throw _handleError(e);
    }
  }

  @override
  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get(ApiRoutes.user(id));
      return User.fromJson(response.data);
    } catch (e, stack) {
      AppLogger.error('Error obteniendo usuario por ID', error: e, stackTrace: stack);
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateUserStatus(String id, bool isActive) async {
    try {
      AppLogger.debug('🔄 Updating user status: id=$id, isActive=$isActive');
      final requestData = {'isActive': isActive};
      AppLogger.debug('🔄 Request data: $requestData');
      
      await _dio.patch(
        ApiRoutes.updateUserStatus(id),
        data: requestData,
      );
      AppLogger.debug('🔄 User status updated successfully');
    } catch (e, stack) {
      AppLogger.error('Error actualizando estado del usuario', error: e, stackTrace: stack);
      throw _handleError(e);
    }
  }

  @override
  Future<User> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        ApiRoutes.updateUser(id),
        data: userData,
      );
      return User.fromJson(response.data);
    } catch (e, stack) {
      AppLogger.error('Error actualizando usuario', error: e, stackTrace: stack);
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      AppLogger.debug('🔄 Logging: Sending DELETE request to server for user ID: $id');
      await _dio.delete(ApiRoutes.deleteUser(id));
      AppLogger.debug('✅ Logging: DELETE request completed successfully for user ID: $id');
    } catch (e, stack) {
      AppLogger.error('❌ Logging: Failed to delete user from server', error: e, stackTrace: stack);
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    AppLogger.debug('🔄 Handling error: $error');
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        AppLogger.debug('🔄 Error response data: ${response.data}');
        final message = response.data['message'] as String?;
        return Exception(message ?? 'Error en la operación');
      }
    }
    return Exception('Error de conexión');
  }
}
