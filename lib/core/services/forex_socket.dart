import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  IO.Socket? socket;

  void connect(Function(dynamic) onForexUpdate) {
    socket = IO.io(
      AppConfig.instance.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection() // auto reconexión
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("✅ Conectado al socket");
    });

    socket!.on("forex", (data) {
      onForexUpdate(data);
    });

    socket!.onDisconnect((_) {
      print("❌ Desconectado");
    });

    socket!.onReconnect((_) {
      print("🔄 Reconectado");
    });
  }

  void disconnect() {
    socket?.dispose();
  }
}