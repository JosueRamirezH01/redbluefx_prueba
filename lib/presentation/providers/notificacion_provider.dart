import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redbluefx/domain/entities/Advert_Mapper.dart';
import 'package:redbluefx/domain/entities/adverts.dart';
import 'package:shared_preferences/shared_preferences.dart';
final showNewsCarouselProvider =
StateNotifierProvider<ShowNewsCarouselNotifier, bool>(
      (ref) => ShowNewsCarouselNotifier(),
);
class ShowNewsCarouselNotifier extends StateNotifier<bool> {
  ShowNewsCarouselNotifier() : super(true);

  void show() => state = true;
  void hide() => state = false;
}
final realtimeNotificationProvider = StateNotifierProvider<RealtimeNotificationNotifier, RemoteMessage?>(
      (ref) => RealtimeNotificationNotifier(),
);
final newsCarouselProvider = StateNotifierProvider<NewsCarouselNotifier, List<Advert>>(
      (ref) => NewsCarouselNotifier(),
);

class RealtimeNotificationNotifier extends StateNotifier<RemoteMessage?> {
  RealtimeNotificationNotifier() : super(null);

  void setNotification(RemoteMessage message) {
    state = message;
  }

  void clear() {
    state = null;
  }
}


class NewsCarouselNotifier extends StateNotifier<List<Advert>> {
  NewsCarouselNotifier() : super([]) {
    _restore();
  }

  Future<void> _restore() async {
    final stored = await NewsCarouselStorage.load();
    if (stored.isNotEmpty) {
      state = stored;
    }
  }

  Future<void> addFromNotification(RemoteMessage message) async {
    final item = AdvertMapper.fromRemoteMessage(message);

    // evitar duplicados
    final exists = state.any((e) => e.id == item.id);
    if (exists) return;

    state = [item, ...state].take(3).toList();

    // 🔥 persistir
    await NewsCarouselStorage.save(state);
  }

  Future<void> clear() async {
    state = [];
    await NewsCarouselStorage.clear();
  }
}


class NewsCarouselStorage {
  static const _key = 'news_carousel_items';

  static Future<void> save(List<Advert> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<Advert>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Advert.fromJson(e)).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
