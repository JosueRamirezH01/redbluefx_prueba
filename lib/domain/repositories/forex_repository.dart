abstract class ForexRepository {
  Stream<Map<String, double>> getForexStream();
  void connect();
  void disconnect();
}