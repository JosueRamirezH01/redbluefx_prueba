class CalculatorState {
  final double capital;
  final double riskPercent;
  final double entry;
  final double stop;

  final double positionSize;
  final double units;
  final double riskAmount;
  final double marginUsed;

  final bool showHighRiskWarning;
  final bool showTightStopWarning;



  final double takeProfit;
  final double risk;
  final double reward;
  final double rrRatio;
  final double profitUsd;
  final double profitPercent;

  const CalculatorState({
    this.capital = 0,
    this.riskPercent = 0,
    this.entry = 0,
    this.stop = 0,
    this.takeProfit = 0,
    this.positionSize = 0,
    this.units = 0,
    this.riskAmount = 0,
    this.marginUsed = 0,
    this.risk = 0,
    this.reward = 0,
    this.rrRatio = 0,
    this.profitUsd = 0,
    this.profitPercent = 0,
    this.showHighRiskWarning = false,
    this.showTightStopWarning = false,
  });

  CalculatorState copyWith({
    double? capital,
    double? riskPercent,
    double? entry,
    double? stop,
    double? takeProfit,

    double? positionSize,
    double? units,
    double? riskAmount,
    double? marginUsed,

    double? risk,
    double? reward,
    double? rrRatio,
    double? profitUsd,
    double? profitPercent,

    bool? showHighRiskWarning,
    bool? showTightStopWarning,
  }) {
    return CalculatorState(
      capital: capital ?? this.capital,
      riskPercent: riskPercent ?? this.riskPercent,
      entry: entry ?? this.entry,
      stop: stop ?? this.stop,
      takeProfit: takeProfit ?? this.takeProfit,

      positionSize: positionSize ?? this.positionSize,
      units: units ?? this.units,
      riskAmount: riskAmount ?? this.riskAmount,
      marginUsed: marginUsed ?? this.marginUsed,

      risk: risk ?? this.risk,
      reward: reward ?? this.reward,
      rrRatio: rrRatio ?? this.rrRatio,
      profitUsd: profitUsd ?? this.profitUsd,
      profitPercent: profitPercent ?? this.profitPercent,

      showHighRiskWarning:
      showHighRiskWarning ?? this.showHighRiskWarning,
      showTightStopWarning:
      showTightStopWarning ?? this.showTightStopWarning,
    );
  }
}