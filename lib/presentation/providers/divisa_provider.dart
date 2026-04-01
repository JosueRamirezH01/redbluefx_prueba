import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/divisas_repository_impl.dart';
import '../../domain/entities/divisas.dart';
import '../../domain/repositories/divisas_repository.dart';

final divisasRepositoryProvider = Provider<DivisasRepository>((ref) {
  return DivisasRepositoryImpl();
});

final divisasProvider = FutureProvider<List<Divisas>>((ref) async {
  final repo = ref.watch(divisasRepositoryProvider);

  final result = await repo.getDivisas();

  return result;
});