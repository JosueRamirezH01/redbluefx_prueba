

import 'package:dio/dio.dart';
import 'package:redbluefx/domain/entities/feedback.dart';

import '../../core/services/dio_service_feedback.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {

  final Dio _dio = FeedbackDioService.instance;

  @override
  Future<Feedback> createFeedback({
    required String content,
    required String calification,
    required String platform,
    required String email,
    required bool getFeedback,
  }) async {

    try {
      final data = {
        'content': content.trim(),
        'calification': calification.toLowerCase(), // 🔥 FIX CLAVE
        'get_feedback': getFeedback,
        'platform': platform.toLowerCase(),         // 🔥 PREVENCIÓN
        'email': email.trim().toLowerCase(),
      };
      AppLogger.info('📤 FEEDBACK ENVIADO → $data');
      final response = await _dio.post('/feedbacks/', data: data,);

      return Feedback.fromJson(response.data);
    } catch (e, stack) {
      AppLogger.error(
        '❌ Error al crear feedback',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

}