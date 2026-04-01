import 'dart:async';
import '../../core/services/forex_socket.dart';
import '../../domain/repositories/forex_repository.dart';

class ForexRepositoryImpl implements ForexRepository {
  final SocketService socketService;

  final _controller = StreamController<Map<String, double>>.broadcast();

  ForexRepositoryImpl(this.socketService);

  @override
  Stream<Map<String, double>> getForexStream() => _controller.stream;

  @override
  void connect() {
    socketService.connect((data) {
      _controller.add(Map<String, double>.from(data));
    });
  }

  @override
  void disconnect() {
    socketService.disconnect();
    _controller.close();
  }
}