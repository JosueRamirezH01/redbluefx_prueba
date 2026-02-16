import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculator/calculator_function/calculator_notifier.dart';
import '../../domain/calculator/calculator_function/calculator_state.dart';
import '../../domain/calculator/marginCalculator/margin_status.dart';
import '../../domain/calculator/marginCalculator/margin_usecase.dart';

final marginUseCaseProvider = Provider((ref) => GetMarginStatusUseCase(),);

final marginStatusProvider = Provider.family<MarginStatus, double>((ref, percent) {
  final useCase = ref.read(marginUseCaseProvider);
  return useCase.execute(percent);
});


final calculatorProvider =
StateNotifierProvider<CalculatorNotifier, CalculatorState>(
      (ref) => CalculatorNotifier(),
);