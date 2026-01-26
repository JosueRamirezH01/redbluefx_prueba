

import 'package:dio/dio.dart';
import 'package:redbluefx_mobile/domain/entities/feedback.dart';

import '../../core/config/api_routes.dart';
import '../../core/services/dio_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {

  FeedbackRepositoryImpl({Dio? dio}) : _dio = dio ?? DioService.instance.dio;
  final Dio _dio;

  @override
  Future<Feedback> createFeedback({required String content,required String qualification, required String platform, required String email, required bool getFeedback}) async {
    print('LLEGADA $content');
    print('LLEGADA $qualification');
    print('LLEGADA $platform');
    print('LLEGADA $email');
    print('LLEGADA $getFeedback');

    try {
      final Map<String, dynamic> data = {
        'content': content,
        'calification': qualification,
        'get_feedback': getFeedback,
        'platform': platform,
        'email': email
      };

      final response = await _dio.post(
        Uri.parse(ApiRoutes.feedbackCreate).toString(),
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.data == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      final feedbackData = response.data;
      return Feedback.fromJson(feedbackData);
    } catch (e) {
      throw _handleError(e);
    }
  }
  Exception _handleError(dynamic error) {
    AppLogger.error('Error en feedBackRepositoryImpl', error: error);

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