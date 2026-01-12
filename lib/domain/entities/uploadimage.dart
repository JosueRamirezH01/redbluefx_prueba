import 'package:freezed_annotation/freezed_annotation.dart';

part 'uploadimage.freezed.dart';
part 'uploadimage.g.dart';

@freezed
class uploadimage with _$uploadimage {
  const factory uploadimage({
    required String url,
    required String key,
    required String name,
  }) = _uploadimage;

  factory uploadimage.fromJson(Map<String, dynamic> json) => _$uploadimageFromJson(json);
}