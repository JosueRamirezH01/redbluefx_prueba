import '../entities/feedback.dart';

abstract class FeedbackRepository {
  Future<Feedback> createFeedback({
    required String content,
    required String calification,
    required String platform,
    required String email,
    required bool getFeedback,
  });

}