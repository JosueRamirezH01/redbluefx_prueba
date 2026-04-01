import '../entities/divisas.dart';

abstract class DivisasRepository {
  Future<List<Divisas>> getDivisas();
}