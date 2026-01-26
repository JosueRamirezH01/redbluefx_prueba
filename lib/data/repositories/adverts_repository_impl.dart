import 'package:dio/dio.dart';
import 'package:redbluefx_mobile/domain/entities/adverts.dart';

import '../../core/config/api_routes.dart';
import '../../core/services/dio_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/adverts_repository.dart';

class AdvertsRepositoryImpl implements AdvertRepository {

  AdvertsRepositoryImpl({Dio? dio}) : _dio = dio ?? DioService.instance.dio;
  final Dio _dio;

  @override
  Future<Advert> createAdverts({required String title, required String content, String? image, required bool isFeatured}) async {
    try {
      final Map<String, dynamic> data = {
        'title': title,
        'content': content,
        'isFeatured': isFeatured,
      };
      if (image != null && image.trim().isNotEmpty) {
        data['image'] = image;
      }

      final response = await _dio.post(
        ApiRoutes.adverts,
        data: data,
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final alertData = response.data['advert'];
      return Advert.fromJson(alertData);
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

  @override
  Future<List<Advert>> getAdverts({int page = 1, int limit = 20, String? search}) async {
    try {

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      AppLogger.debug(
          '🔄 AdvertRepositoryImpl getAlerts - queryParams: $queryParams');

      final response = await _dio.get(
          ApiRoutes.adverts, queryParameters: queryParams);

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final List<dynamic> data = response.data['adverts'] as List<dynamic>;
      var adverts = data.map((json) => Advert.fromJson(json)).toList();
     /* if (search != null && search.isNotEmpty) {
        alerts = alerts.where((alert) =>
            alert.pair.toLowerCase().contains(search.toLowerCase())
          *//* || alert.content!.toLowerCase().contains(search.toLowerCase())*//*
        ).toList();
      }*/
      AppLogger.debug(
          '🔄 AdvertRepositoryImpl getAlerts - received ${data.length} advert');
      if (data.isNotEmpty) {
        AppLogger.debug(
            '🔄 AdvertRepositoryImpl getAlerts - first alert type: ${data[0]['type']}');
      }

      return adverts;
    } catch (e, stack) {
      AppLogger.error(
        'Error en getAdvert',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }

  @override
  Future<List<Advert>> getAdvertsFeature({int page = 1, int limit = 20, String? search}) async {
    try {

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      AppLogger.debug(
          '🔄 AdvertRepositoryImpl getAlerts - queryParams: $queryParams');

      final response = await _dio.get(ApiRoutes.advertsFeature, queryParameters: queryParams);

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final List<dynamic> data = response.data['adverts'] as List<dynamic>;
      var adverts = data.map((json) => Advert.fromJson(json)).toList();
      AppLogger.debug(
          '🔄 AdvertRepositoryImpl getAdverts - received ${data.length} advert');
      if (data.isNotEmpty) {
        AppLogger.debug(
            '🔄 AdvertRepositoryImpl getAdverts - first alert type: ${data[0]['type']}');
      }
      return adverts;
    } catch (e, stack) {
      AppLogger.error(
        'Error en getAdvert',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }

  @override
  Future<List<Advert>> getAdvertsPublic({int page = 1, int limit = 20, String? search}) async {
    try {

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      AppLogger.debug(
          '🔄 AdvertRepositoryImpl getAlerts - queryParams: $queryParams');

      final response = await _dio.get(ApiRoutes.advertsPublic, queryParameters: queryParams);

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final List<dynamic> data = response.data['adverts'] as List<dynamic>;
      var adverts = data.map((json) => Advert.fromJson(json)).toList();
      AppLogger.debug(
          '🔄 AdvertRepositoryImpl getAdverts - received ${data.length} advert');
      if (data.isNotEmpty) {
        AppLogger.debug(
            '🔄 AdvertRepositoryImpl getAdverts - first alert type: ${data[0]['type']}');
      }
      return adverts;
    } catch (e, stack) {
      AppLogger.error(
        'Error en getAdvert',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteAdverts(String id) async{
    try {
      await _dio.delete(ApiRoutes.advert(id));
    } catch (e) {
      throw _handleError(e);
    }
  }




}
