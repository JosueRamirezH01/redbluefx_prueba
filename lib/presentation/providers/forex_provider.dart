
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/forex_socket.dart';
import '../../data/repositories/forex_repository_impl.dart';
import '../../domain/repositories/forex_repository.dart';


final socketServiceProvider = Provider<SocketService>((ref) {
  final socket = SocketService();
  ref.onDispose(() => socket.disconnect());
  return socket;
});

final forexRepositoryProvider = Provider<ForexRepository>((ref) {
  final socket = ref.watch(socketServiceProvider);
  return ForexRepositoryImpl(socket);
});

final forexProvider =
StateNotifierProvider<ForexNotifier, Map<String, double>>((ref) {
  final repo = ref.watch(forexRepositoryProvider);
  return ForexNotifier(repo);
});

class ForexNotifier extends StateNotifier<Map<String, double>> {
  final ForexRepository repository;

  Map<String, double> _previous = {};

  ForexNotifier(this.repository) : super({}) {
    _init();
  }

  void _init() {
    repository.connect();

    repository.getForexStream().listen((data) {
      _previous = Map.from(state);
      state = data;
    });
  }

  Map<String, double> get previousPrices => _previous;

  @override
  void dispose() {
    repository.disconnect();
    super.dispose();
  }
}