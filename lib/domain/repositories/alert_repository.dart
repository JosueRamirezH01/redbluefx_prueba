import '../entities/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlerts({
    int page = 1,
    int limit = 20,
    AlertType? type,
    String? search,
  });

  Future<Alert> getAlertById(String id);

  Future<List<Alert>> getUserAlerts({
    int page = 1,
    int limit = 20,
    AlertStatus? status,
  });

  Future<Alert> createAlert({
    required String pair,
    required String entry,
    required String stopLoss,
    String? analysis,
    String? image,
    String? parOne,
    String? parTwo,
    required List<String> takeProfits,
    required AlertType type,
    String? imageUrl,
    required bool isPublic,
  });

  Future<void> markAsRead(String id);
  Future<void> archiveAlert(String id);
  Future<void> unarchiveAlert(String id);
  Future<void> shareAlert(String id);
  Future<void> deleteAlert(String id);

  Future<Alert> updateAlert(
    String id, {
    String? title,
    String? content,
    AlertType? type,
    bool? isPublic,
  });

  Future<Alert> updateAlertStatus(String id, AlertStatus status);
} 