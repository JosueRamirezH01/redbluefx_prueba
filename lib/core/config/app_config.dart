import 'package:flutter/foundation.dart';

enum Environment { dev, prod }

class AppConfig {
  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  final Environment env;
  final String baseUrl;
  late final String apiUrl;
  late final String wsUrl;

  AppConfig._({
    required this.env,
    required this.baseUrl,
  }) {
    apiUrl = '$baseUrl/api';
    wsUrl = baseUrl.replaceFirst('http', 'ws');
  }

  static void initialize({
    required Environment env,
    required String baseUrl,
  }) {
    _instance = AppConfig._(
      env: env,
      baseUrl: baseUrl,
    );
  }

  bool get isDevelopment => env == Environment.dev;
  bool get isProduction => env == Environment.prod;

  Map<String, dynamic> toJson() => {
        'environment': env.toString(),
        'apiUrl': apiUrl,
        'wsUrl': wsUrl,
        'baseUrl': baseUrl,
      };
} 