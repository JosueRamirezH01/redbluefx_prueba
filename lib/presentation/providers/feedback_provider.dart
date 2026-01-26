import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/repositories/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepositoryImpl();
});

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  return FeedbackNotifier(ref.watch(feedbackRepositoryProvider));
});

class FeedbackState {
  final List<Feedback> feedback;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const FeedbackState({
    this.feedback = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  FeedbackState copyWith({
    List<Feedback>? feedback,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    AlertType? selectedType,
    String? searchQuery,
  }) {
    return FeedbackState(
      feedback: feedback ?? this.feedback,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final FeedbackRepository _repository;
  //static const _pageSize = 20;

  FeedbackNotifier(this._repository) : super(const FeedbackState()) {
   // loadAlerts();
  }

  Future<Feedback> createFeedback({required String qualification, required String content, required String email, required bool getFeedback}) async {
    try {
      final feedback = await _repository.createFeedback(
        content: content,
        email: email,
        getFeedback: getFeedback,
        platform: "RedBlue FX",
        qualification: qualification
      );

      state = state.copyWith(
        isLoading: false,
        feedback: [feedback, ...state.feedback],
      );

      return feedback;
    } catch (e) {

      state = state.copyWith(isLoading: false,error: e.toString());
      rethrow;
    }
  }


}