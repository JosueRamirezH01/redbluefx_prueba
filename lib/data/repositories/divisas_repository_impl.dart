
import 'package:dio/dio.dart';
import 'package:redbluefx/domain/entities/divisas.dart';
import 'package:redbluefx/domain/repositories/divisas_repository.dart';

import '../../core/config/api_routes.dart';
import '../../core/services/dio_service.dart';
import '../../core/utils/logger.dart';

class DivisasRepositoryImpl implements DivisasRepository {

  DivisasRepositoryImpl({Dio? dio})
      : _dio = dio ?? DioService.instance.dio;

  final Dio _dio;

  @override
  Future<List<Divisas>> getDivisas() async {
    try {
      final response = await _dio.get(ApiRoutes.getDivisas);

      final data = response.data['divisas'];

      if (data == null || data is! List) {
        throw Exception('Formato inválido de divisas');
      }

      final divisas = data.map<Divisas>((json) => Divisas.fromJson(json)).toList();

      AppLogger.debug(
        '🔄 DivisasRepositoryImpl - total: ${divisas.length}',
      );

      return divisas;

    } catch (e, stack) {
      AppLogger.error(
        'Error en getDivisas',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;

      if (response != null && response.data != null) {
        final message = response.data['message'] as String?;
        return Exception(message ?? 'Error al obtener divisas');
      }

      return Exception('Error de conexión: ${error.message}');
    }

    if (error is Exception) return error;

    return Exception('Error inesperado: $error');
  }
}