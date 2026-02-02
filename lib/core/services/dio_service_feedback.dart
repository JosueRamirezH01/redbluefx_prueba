import 'package:dio/dio.dart';

class FeedbackDioService {
  FeedbackDioService._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: 'https://feedbacksys-production.up.railway.app',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    ),
  );
}
