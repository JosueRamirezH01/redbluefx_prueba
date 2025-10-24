import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

enum AlertType { info, buy, sell, all }
enum AlertStatus { active, archived }

@freezed
class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String title,
    required String content,
    required AlertType type,
    String? imageUrl,
    required DateTime createdAt,
    required String createdBy,
    required bool isPublic,
    @Default(AlertStatus.active) AlertStatus status,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
} 