import 'package:dio/dio.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../core/config/api_routes.dart';
import '../../core/services/dio_service.dart';
import '../../core/utils/logger.dart';

class AlertRepositoryImpl implements AlertRepository {

  AlertRepositoryImpl({Dio? dio}) : _dio = dio ?? DioService.instance.dio;
  final Dio _dio;

  @override
  Future<List<Alert>> getAlerts({int page = 1, int limit = 20, AlertType? type, String? search,}) async {
    try {
      AppLogger.debug('🔄 AlertRepositoryImpl getAlerts - type: $type');
      
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type.name,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      
      if (type == null) {
        queryParams['type'] = '';
      }
      
      AppLogger.debug('🔄 AlertRepositoryImpl getAlerts - queryParams: $queryParams');

      final response = await _dio.get(
        ApiRoutes.alerts,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      AppLogger.debug('🔄 AlertRepositoryImpl getAlerts - received ${data.length} alerts');
      if (data.isNotEmpty) {
        AppLogger.debug('🔄 AlertRepositoryImpl getAlerts - first alert type: ${data[0]['type']}');
      }
      
      return data.map((json) => Alert.fromJson(json)).toList();
    } catch (e, stack) {
      AppLogger.error(
        'Error en getAlerts',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }

  @override
  Future<Alert> getAlertById(String id) async {
    try {
      final response = await _dio.get(ApiRoutes.alert(id));
      
      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final alertData = response.data['data'];
      return Alert.fromJson(alertData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<Alert>> getUserAlerts({int page = 1, int limit = 20, AlertStatus? status,}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status.name,
      };

      final response = await _dio.get(
        ApiRoutes.alerts,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Alert.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _dio.post(ApiRoutes.markAsRead(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> archiveAlert(String id) async {
    try {
      AppLogger.debug('🔄 AlertRepositoryImpl archiveAlert: ${ApiRoutes.archiveAlert(id)}');
      await _dio.post(ApiRoutes.archiveAlert(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> unarchiveAlert(String id) async {
    try {
      await _dio.post(ApiRoutes.unarchiveAlert(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> shareAlert(String id) async {
    try {
      await _dio.post(ApiRoutes.shareAlert(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteAlert(String id) async {
    try {
      await _dio.delete(ApiRoutes.alert(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Alert> createAlert({
    required String title,
    required String content,
    required AlertType type,
    required bool isPublic,
  }) async {
    try {
      final response = await _dio.post(
        ApiRoutes.alerts,
        data: {
          'title': title,
          'content': content,
          'type': type.name,
          'isPublic': isPublic,
        },
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final alertData = response.data['alert'];
      return Alert.fromJson(alertData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Alert> updateAlert(String id, {
    String? title,
    String? content,
    AlertType? type,
    bool? isPublic,
  }) async {
    try {
      final response = await _dio.put(
        ApiRoutes.alert(id),
        data: {
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (type != null) 'type': type.name,
          if (isPublic != null) 'isPublic': isPublic,
        },
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      return Alert.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Alert> updateAlertStatus(String id, AlertStatus status) async {
    try {
      final response = await _dio.patch(
        '${ApiRoutes.alert(id)}/status',
        data: {
          'status': status.name,
        },
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final alertData = response.data['alert'];
      return Alert.fromJson(alertData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    AppLogger.error('Error en AlertRepositoryImpl', error: error);
    
    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data != null) {
        final message = response.data['message'] as String?;
        return Exception(message ?? 'Error al obtener las alertas');
      }
      return Exception('Error de conexión: ${error.message}');
    }
    
    if (error is Exception) {
      return error;
    }
    
    return Exception('Error inesperado: $error');
  }
} 