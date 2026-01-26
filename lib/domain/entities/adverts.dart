import 'package:freezed_annotation/freezed_annotation.dart';

part 'adverts.freezed.dart';
part 'adverts.g.dart';

@freezed
class Advert with _$Advert {
  const factory Advert({
    required String id,
    required String title,
    required String content,
    String? image,
    String? imageUrl,
    required bool isFeatured,
    required DateTime createdAt,
    required String createdBy,
  }) = _Advert;

  factory Advert.fromJson(Map<String, dynamic> json) =>
      _$AdvertFromJson(json);
}

