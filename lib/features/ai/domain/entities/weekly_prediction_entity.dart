import 'package:cinnamon_marketplace_app/features/ai/domain/entities/price_prediction_entity.dart';


class PricePredictionEntity {
  final double currentPrice;
  final double? nationalPrice;
  final List<WeeklyPredictionEntity> predictions;
  final double monthlyChange;
  final String trend;
  final String district;
  final String grade;
  final bool isWeekly;
  final bool isMock;
  final String? modelVersion;
  final String? modelUpdatedAt;

  const PricePredictionEntity({
    required this.currentPrice,
    required this.predictions,
    required this.monthlyChange,
    required this.trend,
    required this.district,
    required this.grade,
    required this.isWeekly,
    required this.isMock,
    this.nationalPrice,
    this.modelVersion,
    this.modelUpdatedAt,
  });
}