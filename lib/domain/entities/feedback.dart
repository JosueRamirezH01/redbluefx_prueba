import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback.freezed.dart';
part 'feedback.g.dart';

@freezed
class Feedback with _$Feedback {
  const factory Feedback({
    required int id,
    required String content,
    required String platform,
    required String calification,
    required String email,
    @JsonKey(name: 'get_feedback')
    @Default(false)
    bool getFeedback,
  }) = _Feedback;

  factory Feedback.fromJson(Map<String, dynamic> json) =>
      _$FeedbackFromJson(json);
}

