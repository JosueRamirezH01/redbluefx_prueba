import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:redbluefx_mobile/domain/entities/user.dart';
part 'notice.freezed.dart';
part 'notice.g.dart';
enum NoticeCategory{ forex, tech, crypto, mercados, materias, all }
@freezed
class Notice with _$Notice {
  const factory Notice({
    required String id,
    required String author,
    required String title,
    required NoticeCategory category,
    required DateTime publishedAt,
    required String content,
    required String newsUrl,
    String? image,
    @Default('es') String language,

    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,

    required User creator,
  }) = _Notice;

  factory Notice.fromJson(Map<String, dynamic> json) =>
      _$NoticeFromJson(json);
}
