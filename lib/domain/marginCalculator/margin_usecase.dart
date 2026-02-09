import 'margin_status.dart';

class GetMarginStatusUseCase {
  MarginStatus execute(double percent) {
    if (percent <= 0.25) {
      return MarginStatus(
        label: 'Seguro',
        percent: percent,
        gradientColors: [0xFF26A69A, 0xFF69F0AE],
      );
    } else if (percent <= 0.70) {
      return MarginStatus(
        label: 'Alto riesgo',
        percent: percent,
        gradientColors: [0xFFFF9800, 0xFFFFF59D],
      );
    } else {
      return MarginStatus(
        label: 'Riesgo extremo',
        percent: percent,
        gradientColors: [0xFFD32F2F, 0xFFFF5252],
      );
    }
  }
}