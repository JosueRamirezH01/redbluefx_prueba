import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/marginCalculator/margin_status.dart';
import '../../domain/marginCalculator/margin_usecase.dart';

final marginUseCaseProvider = Provider((ref) => GetMarginStatusUseCase(),);

final marginStatusProvider = Provider.family<MarginStatus, double>((ref, percent) {
  final useCase = ref.read(marginUseCaseProvider);
  return useCase.execute(percent);
});