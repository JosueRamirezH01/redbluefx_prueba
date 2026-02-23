import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/adverts_repository_impl.dart';
import '../../domain/entities/adverts.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/adverts_repository.dart';
final showNewsCarouselProvider = StateProvider<bool>((ref) {
  return true; // visible por defecto
});
final advertRepositoryProvider = Provider<AdvertRepository>((ref) {
  return AdvertsRepositoryImpl();
});

final advertsProvider =
StateNotifierProvider<AdvertNotifier, AdvertState>((ref) {
  return AdvertNotifier(ref, ref.watch(advertRepositoryProvider),);
});
final advertsProviderPublic = StateNotifierProvider<AdvertNotifierPublic, AdvertState>((ref) {
  return AdvertNotifierPublic(ref.watch(advertRepositoryProvider));
});

class AdvertState {
  final List<Advert> adverts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;

  const AdvertState({
    this.adverts = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
  });

  AdvertState copyWith({
    List<Advert>? adverts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    AlertType? selectedType,
    String? searchQuery,
  }) {
    return AdvertState(
      adverts: adverts ?? this.adverts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdvertNotifier extends StateNotifier<AdvertState> {
  final AdvertRepository _repository;
  final Ref ref;
  static const _pageSize = 20;

  AdvertNotifier(this.ref,this._repository) : super(const AdvertState()) {
    loadAdvertsFeature();
  }

  Future<void> loadAdvertsFeature({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        adverts: [],
        hasMore: true,
      );
    }

    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final adverts = await _repository.getAdvertsFeature(
        page: state.currentPage,
        limit: _pageSize,
        search: state.searchQuery,

      );
      AppLogger.debug('🔄 AdvertNotifier loadAlerts - received ${adverts.length} advert');

      state = state.copyWith(
        adverts: [...state.adverts, ...adverts],
        isLoading: false,
        hasMore: adverts.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      AppLogger.error('🔄 AdvertNotifier loadAdvert - error', error: e);
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }


  Future<void> refreshAdverts() async {
    await loadAdvertsFeature(refresh: true);
  }

  void clearFilters() {
    state = const AdvertState(
      adverts: [],
      isLoading: false,
      error: null,
      hasMore: true,
      currentPage: 1,
      searchQuery: null,
    );
  }
  Future<Advert> createAdvert({required title, required String content,String? image, required bool isFeatured}) async {
    try {
      final advert = await _repository.createAdverts(
          title: title,
          content: content,
          isFeatured: isFeatured,
          image: image
      );

      state = state.copyWith(
        adverts: [advert, ...state.adverts],
      );

      return advert;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

 /* void filterByType(AlertType? type) {
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
*/
  Future<void> deleteAdvert(String id) async {
    try {
      await _repository.deleteAdverts(id);
      state = state.copyWith(
        adverts: state.adverts.where((advert) => advert.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAdvert(String id, {String? title, String? content, String? image, bool? isFeatured}) async {

    try {
      final updatedAdvert = await _repository.updateAdvert(
        id,
        title: title,
        content: content,
        image: image,
        isFeatured: isFeatured,
      );
      await loadAdvertsFeature(refresh: true);
      await ref.read(advertsProviderPublic.notifier).loadAdvertsPublic(refresh: true);
      state = state.copyWith(
        adverts: state.adverts.map((advert) {
          return advert.id == id ? updatedAdvert : advert;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

}

class AdvertNotifierPublic extends StateNotifier<AdvertState> {
  final AdvertRepository _repository;
  static const _pageSize = 20;

  AdvertNotifierPublic(this._repository) : super(const AdvertState()) {
    loadAdvertsPublic();
  }

  Future<void> loadAdvertsPublic({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        adverts: [],
        hasMore: true,
      );
    }

    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final adverts = await _repository.getAdvertsPublic(
        page: state.currentPage,
        limit: _pageSize,
        search: state.searchQuery,
      );

      AppLogger.debug('📰 Public adverts: ${adverts.length}');

      state = state.copyWith(
        adverts: [...state.adverts, ...adverts],
        isLoading: false,
        hasMore: adverts.length >= _pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      AppLogger.error('❌ Error loading public adverts', error: e);
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadAdvertsPublic(refresh: true);
  }
  Future<void> deleteAdvertPublic(String id) async {
    try {
      await _repository.deleteAdverts(id);
      state = state.copyWith(
        adverts: state.adverts.where((advert) => advert.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  // adverts_provider.dart
}
