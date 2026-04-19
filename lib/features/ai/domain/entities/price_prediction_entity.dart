class WeeklyPredictionEntity {
  final DateTime date;
  final double averagePrice;
  final double highPrice;
  final double confidence;
  final double? nationalAverage;

  const WeeklyPredictionEntity({
    required this.date,
    required this.averagePrice,
    required this.highPrice,
    required this.confidence,
    this.nationalAverage,
  });
}