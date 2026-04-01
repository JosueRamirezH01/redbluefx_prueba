import 'package:freezed_annotation/freezed_annotation.dart';

part 'divisas.freezed.dart';
part 'divisas.g.dart';

@freezed
class Divisas with _$Divisas {
  const factory Divisas({
    required String id,
    required String parone,
    required String partwo,
    required String language,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Divisas;

  factory Divisas.fromJson(Map<String, dynamic> json) =>
      _$DivisasFromJson(json);
}

