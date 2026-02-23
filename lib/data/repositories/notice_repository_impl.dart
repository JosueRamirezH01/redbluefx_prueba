
import 'package:dio/dio.dart';
import 'package:redbluefx_mobile/core/config/api_routes.dart';
import 'package:redbluefx_mobile/domain/entities/notice.dart';
import 'package:redbluefx_mobile/domain/repositories/notice_repository.dart';

import '../../core/services/dio_service.dart';
import '../../core/utils/logger.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  NoticeRepositoryImpl({Dio? dio}) : _dio = dio ?? DioService.instance.dio;
  final Dio _dio;

  @override
  Future<List<Notice>> getNotice({int page = 1, int limit = 50, NoticeCategory? category, String? search}) async {
    try{
      AppLogger.debug('🔄 NoticeRepositoryImpl getNotice - Category: $category');
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category.name,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      if(category == null){
        queryParams['category'] = '';
      }
      AppLogger.debug('🔄 NoticeRepositoryImpl getNotice - queryParams: $queryParams');
      final response = await _dio.get(ApiRoutes.notices, queryParameters: queryParams);
      if(response.data == null){
        throw Exception('No se recibieron datos del servidor');
      }
      final List<dynamic> data = response.data['news'] as List<dynamic>;
      var notices = data.map((json) => Notice.fromJson(json)).toList();
      if (search != null && search.isNotEmpty) {
        notices = notices.where((notices) =>
        notices.title.toLowerCase().contains(search.toLowerCase()) ||
            notices.content!.toLowerCase().contains(search.toLowerCase())
        ).toList();
      }
      AppLogger.debug('🔄 NoticeRepositoryImpl getNotice - received ${data.length} notice');
      if (data.isNotEmpty) {
        AppLogger.debug('🔄 NoticeRepositoryImpl getNotice - first notice category: ${data[0]['category']}');
      }
      return notices;
    }catch (e, stack) {
      AppLogger.error(
        'Error en getNotices',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }

  @override
  Future<List<Notice>> filterNotice({int page = 1, int limit = 50, NoticeCategory? category}) async {
    try{
      if (category == null) {
        throw Exception('Debe especificarse una categoría para filtrar');
      }

      // Construimos la URL usando tu ruta de API
      final url = ApiRoutes.filterCategoryNotice(category.name);

      AppLogger.debug('🔄 NoticeRepositoryImpl filterNotice - URL: $url');

      // Hacemos la petición GET
      final response = await _dio.get(url!, queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final List<dynamic> data = response.data['news'] as List<dynamic>;
      final notices = data.map((json) => Notice.fromJson(json)).toList();

      AppLogger.debug('🔄 NoticeRepositoryImpl filterNotice - received ${notices.length} notice(s) for category: ${category.name}');

      return notices;
    }catch (e, stack) {
      AppLogger.error(
        'Error en getNotices',
        error: e,
        stackTrace: stack,
      );
      throw _handleError(e);
    }
  }
  Exception _handleError(dynamic error) {
    AppLogger.error('Error en NoticeRepositoryImpl', error: error);

    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data != null) {
        final message = response.data['message'] as String?;
        return Exception(message ?? 'Error al obtener las Notice');
      }
      return Exception('Error de conexión: ${error.message}');
    }

    if (error is Exception) {
      return error;
    }

    return Exception('Error inesperado: $error');
  }

}