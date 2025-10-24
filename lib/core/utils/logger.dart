import 'package:logger/logger.dart';
import '../config/app_config.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message) {
    print('🔍 DEBUG: $message');
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    print('❌ ERROR: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace:\n$stackTrace');
  }

  static void info(String message) {
    print('ℹ️ INFO: $message');
  }

  static void warning(String message) {
    print('⚠️ WARN: $message');
  }
} 