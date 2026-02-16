import 'margin_status.dart';

class GetMarginStatusUseCase {
  MarginStatus execute(double percent) {
    // 🟢 SEGURO (ej: 2.17%)
    if (percent <= 5) {
      return MarginStatus(
        label: 'Seguro',
        percent: percent / 100, // 🔥 importante para la barra
        gradientColors: [
          0xFF26A69A, // verde
          0xFF69F0AE,
        ],
      );
    }

    // 🟡 MODERADO (hasta 7.4%)
    else if (percent <= 15) {
      return MarginStatus(
        label: 'Moderado',
        percent: percent / 100,
        gradientColors: [
          0xFFFFC107, // amarillo
          0xFFFF9800, // naranja (alto riesgo)
        ],
      );
    }

    // 🟠 ALTO RIESGO (hasta 30%)
    else if (percent <= 35) {
      return MarginStatus(
        label: 'Alto riesgo',
        percent: percent / 100,
        gradientColors: [
          0xFFFF9800, // naranja
          0xFFFFB74D,
        ],
      );
    }

    // 🔴 RIESGO EXTREMO (> 30%)
    else {
      return MarginStatus(
        label: 'Riesgo extremo',
        percent: percent / 100,
        gradientColors: [
          0xFFD32F2F, // rojo
          0xFFFF5252,
        ],
      );
    }
  }
}