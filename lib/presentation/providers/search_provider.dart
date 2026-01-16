import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isSearchingProvider = StateProvider<bool>((ref) => false);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) => SearchHistoryNotifier(),);

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const _key = 'search_history';
  static const int _maxItems = 3;

  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }


  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> addSearch(String term) async {
    if (term.trim().length < 3) return;

    final newState = [term, ...state.where((t) => t != term)];

    if (newState.length > _maxItems) {
      newState.removeRange(_maxItems, newState.length);
    }

    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  Future<void> removeSearch(String term) async {
    final newState = [...state]..remove(term);
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newState);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
