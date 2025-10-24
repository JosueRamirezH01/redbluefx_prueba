import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../data/repositories/alert_repository_impl.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl();
});

final alertsProvider = StateNotifierProvider<AlertNotifier, AlertState>((ref) {
  return AlertNotifier(ref.watch(alertRepositoryProvider));
});

class AlertState {
  final List<Alert> alerts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final AlertType? selectedType;
  final String? searchQuery;

  const AlertState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedType,
    this.searchQuery,
  });

  AlertState copyWith({
    List<Alert>? alerts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    AlertType? selectedType,
    String? searchQuery,
  }) {
    return AlertState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AlertNotifier extends StateNotifier<AlertState> {
  final AlertRepository _repository;
  static const _pageSize = 20;

  AlertNotifier(this._repository) : super(const AlertState()) {
    loadAlerts();
  }

  Future<void> loadAlerts({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        alerts: [],
        hasMore: true,
      );
    }

    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.debug('🔄 AlertNotifier loadAlerts - loading with type: ${state.selectedType}');

    try {
      final alerts = await _repository.getAlerts(
        page: state.currentPage,
        limit: _pageSize,
        type: state.selectedType,
        search: state.searchQuery,
      );
      AppLogger.debug('🔄 AlertNotifier loadAlerts - received ${alerts.length} alerts');
      if (alerts.isNotEmpty) {
        AppLogger.debug('🔄 AlertNotifier loadAlerts - first alert type: ${alerts.first.type}');
      }
      
      state = state.copyWith(
        alerts: [...state.alerts, ...alerts],
        isLoading: false,
        hasMore: alerts.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      AppLogger.error('🔄 AlertNotifier loadAlerts - error', error: e);
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> refreshAlerts() async {
    await loadAlerts(refresh: true);
  }

  void filterByType(AlertType? type) {
    AppLogger.debug('🔄 AlertNotifier filterByType - before: ${state.selectedType}, after: $type');
    AppLogger.debug('🔄 AlertNotifier filterByType - type is null: ${type == null}');
    
    if (type == state.selectedType) {
      AppLogger.debug('🔄 AlertNotifier filterByType - type unchanged, returning');
      return;
    }
    
    state = state.copyWith(
      selectedType: type,
      currentPage: 1,
      alerts: [],
      hasMore: true,
    );
    
    AppLogger.debug('🔄 AlertNotifier filterByType - state updated, new selectedType: ${state.selectedType}');
    AppLogger.debug('🔄 AlertNotifier filterByType - loading alerts with type: ${state.selectedType}');
    loadAlerts();
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

  Future<void> updateAlert(
    String id, {
    String? title,
    String? content,
    AlertType? type,
    bool? isPublic,
  }) async {
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

  Future<Alert> createAlert({
    required String title,
    required String content,
    required AlertType type,
    required bool isPublic,
  }) async {
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
  }
} 