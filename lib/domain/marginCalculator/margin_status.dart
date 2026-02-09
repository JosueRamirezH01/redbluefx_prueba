class MarginStatus {
  final String label;
  final double percent;
  final List<int> gradientColors; // colores como int (domain-safe)

  const MarginStatus({
    required this.label,
    required this.percent,
    required this.gradientColors,
  });
}