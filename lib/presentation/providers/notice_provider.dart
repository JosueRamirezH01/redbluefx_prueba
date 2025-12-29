import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redbluefx_mobile/domain/entities/notice.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/notice_repository_impl.dart';
import '../../domain/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepositoryImpl();
});

final noticeProvider = StateNotifierProvider<NoticeNotifier, NoticeState>((ref) {
  return NoticeNotifier(ref.watch(noticeRepositoryProvider));
});

class NoticeState {
  final List<Notice> notices;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final NoticeCategory? selectedType;
  final String? searchQuery;

  const NoticeState({
    this.notices = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedType,
    this.searchQuery,
  });

  NoticeState copyWith({
    List<Notice>? notices,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    NoticeCategory? selectedType,
    String? searchQuery,
  }) {
    return NoticeState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NoticeNotifier extends StateNotifier<NoticeState> {
  final NoticeRepository _repository;
  static const _pageSize = 50;

  NoticeNotifier(this._repository) : super(const NoticeState()) {
    loadNotices();
  }

  Future<void> loadNotices({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        notices: [],
        hasMore: true,
      );
    }

    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.debug('🔄 NoticeNotifier loadNotice - loading with type: ${state.selectedType}');

    try {
      final notice = await _repository.getNotice(
        page: state.currentPage,
        limit: _pageSize,
        category: state.selectedType,
        search: state.searchQuery,
      );
      AppLogger.debug('🔄 NoticeNotifier loadNotice - received ${notice.length} notices');
      if (notice.isNotEmpty) {
        AppLogger.debug('🔄 NoticeNotifier loadNotice - first alert type: ${notice.first.category}');
      }

      state = state.copyWith(
        notices: [...state.notices, ...notice],
        isLoading: false,
        hasMore: notice.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      AppLogger.error('🔄 NoticeNotifier loadNotice - error', error: e);
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> refreshNotices() async {
    await loadNotices(refresh: true);
  }

  void filterByType(NoticeCategory? category) {
    AppLogger.debug('🔄 AlertNotifier filterByType - before: ${state.selectedType}, after: $category');
    AppLogger.debug('🔄 AlertNotifier filterByType - type is null: ${category == null}');

    if (category == state.selectedType) {
      AppLogger.debug('🔄 AlertNotifier filterByType - type unchanged, returning');
      return;
    }

    state = state.copyWith(
      selectedType: category,
      currentPage: 1,
      notices: [],
      hasMore: true,
    );

    AppLogger.debug('🔄 AlertNotifier filterByType - state updated, new selectedType: ${state.selectedType}');
    AppLogger.debug('🔄 AlertNotifier filterByType - loading alerts with type: ${state.selectedType}');
    loadNotices();
  }

/*


  void clearFilters() {
    state = const NoticeState(
      alerts: [],
      isLoading: false,
      error: null,
      hasMore: true,
      currentPage: 1,
      selectedType: null,
      searchQuery: null,
    );
  }


  void search(String query) {
    if (query == state.searchQuery) return;
    state = state.copyWith(
      searchQuery: query.isEmpty ? null : query,
      currentPage: 1,
      alerts: [],
      hasMore: true,
    );
    loadAlerts();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      state = state.copyWith(
        alerts: state.alerts.map((alert) {
          if (alert.id == id) {
            // TODO: Actualizar el estado de lectura cuando se implemente
            return alert;
          }
          return alert;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> archiveAlert(String id) async {
    try {
      await _repository.archiveAlert(id);
      state = state.copyWith(
        alerts: state.alerts.where((alert) => alert.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> shareAlert(String id) async {
    try {
      await _repository.shareAlert(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAlert(String id, {String? title, String? content, AlertType? type, bool? isPublic}) async {
    try {
      final updatedAlert = await _repository.updateAlert(
        id,
        title: title,
        content: content,
        type: type,
        isPublic: isPublic,
      );

      state = state.copyWith(
        alerts: state.alerts.map((alert) {
          return alert.id == id ? updatedAlert : alert;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAlertStatus(String id, AlertStatus status) async {
    try {
      final updatedAlert = await _repository.updateAlertStatus(id, status);
      state = state.copyWith(
        alerts: state.alerts.map((alert) {
          return alert.id == id ? updatedAlert : alert;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteAlert(String id) async {
    try {
      await _repository.deleteAlert(id);
      state = state.copyWith(
        alerts: state.alerts.where((alert) => alert.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Alert> createAlert({required String title, required String content, required AlertType type, required bool isPublic,}) async {
    try {
      final alert = await _repository.createAlert(
        title: title,
        content: content,
        type: type,
        isPublic: isPublic,
      );

      state = state.copyWith(
        alerts: [alert, ...state.alerts],
      );

      return alert;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }*/
}