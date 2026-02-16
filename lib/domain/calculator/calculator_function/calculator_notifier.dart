import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calculator_state.dart';

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(const CalculatorState());

  void setCapital(double v) {
    state = state.copyWith(capital: v);
    _recalculate();
  }

  void setRiskPercent(double v) {
    state = state.copyWith(riskPercent: v);
    _recalculate();
  }

  void setEntry(double v) {
    state = state.copyWith(entry: v);
    _recalculate();
  }

  void setStop(double v) {
    state = state.copyWith(stop: v);
    _recalculate();
  }

  void setTakeProfit(double v) {
    state = state.copyWith(takeProfit: v);
    _recalculate();
  }

  void clear() {
    state = const CalculatorState();
  }

  void _recalculate() {
    final capital = state.capital;
    final riskPercent = state.riskPercent;
    final entry = state.entry;
    final stop = state.stop;

    double riskAmount = 0;
    double units = 0;
    double positionSize = 0;

    // 🚨 Validación de riesgo elevado
    final showHighRiskWarning = riskPercent > 2.5;

    // 🚨 Stop demasiado cercano
    bool showTightStopWarning = false;
    //const double minStopDistancePercent = 0.3;

    // ✅ PASO 1: Riesgo en dólares (SOLO capital + riesgo %)
    if (capital > 0 && riskPercent > 0) {
      riskAmount = capital * (riskPercent / 100);
    }

    // ✅ PASO 2 y 3: Unidades (necesita entry + stop)
    if (riskAmount > 0 && entry > 0 && stop > 0 && entry != stop) {
      final riskPerUnit = (entry - stop).abs();
      units = riskAmount / riskPerUnit;
      /*// ⚠️ Validar stop muy cerca
      final riskDistancePercent = (riskPerUnit / entry) * 100;
      if (riskDistancePercent < minStopDistancePercent) {
        showTightStopWarning = true;
      }*/
    }

    // ✅ PASO 4: Posición total (necesita unidades + entry)
    if (units > 0 && entry > 0) {
      positionSize = units * entry;
    }

    double marginUsed = 0;
    const double leverage = 100;

// ✅ PASO 5: Margen usado (usa positionSize)
    if (positionSize > 0 && capital > 0) {
      marginUsed = (positionSize / leverage) / capital;
    }

    state = state.copyWith(
      riskAmount: riskAmount,
      units: units,
      positionSize: positionSize,
      marginUsed: marginUsed,
      showHighRiskWarning: showHighRiskWarning,
      showTightStopWarning: showTightStopWarning,
    );
    _recalculateRiskReward();
  }

  void _recalculateRiskReward() {
    final entry = state.entry;
    final stop = state.stop;
    final takeProfit = state.takeProfit;
    final units = state.units;
    final capital = state.capital;

    double risk = 0;
    double reward = 0;
    double rrRatio = 0;
    double profitUsd = 0;
    double profitPercent = 0;

    if (entry <= 0 || stop <= 0 || takeProfit <= 0) {
      _updateRiskReward(0, 0, 0, 0, 0);
      return;
    }

    final bool isLong = takeProfit > entry;

    risk = (entry - stop).abs();
    reward = isLong ? (takeProfit - entry) : (entry - takeProfit);

    if (risk <= 0 || reward <= 0) {
      _updateRiskReward(0, 0, 0, 0, 0);
      return;
    }

    rrRatio = reward / risk;

    if (units > 0) {
      profitUsd = units * reward;
    }

    if (capital > 0) {
      profitPercent = (profitUsd / capital) * 100;
    }

    _updateRiskReward(risk, reward, rrRatio, profitUsd, profitPercent);
  }

  void _updateRiskReward(double risk, double reward, double rrRatio, double profitUsd, double profitPercent) {
    state = state.copyWith(
      risk: risk,
      reward: reward,
      rrRatio: rrRatio,
      profitUsd: profitUsd,
      profitPercent: profitPercent,
    );
  }
}