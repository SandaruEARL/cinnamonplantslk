import '../../domain/entities/price_prediction_entity.dart';
import '../../domain/entities/weekly_prediction_entity.dart';

class PricePredictionModel extends PricePredictionEntity {
  const PricePredictionModel({
    required super.currentPrice,
    required super.predictions,
    required super.monthlyChange,
    required super.trend,
    required super.district,
    required super.grade,
    required super.isWeekly,
    required super.isMock,
    super.nationalPrice,
    super.modelVersion,
    super.modelUpdatedAt,
  });

  factory PricePredictionModel.fromMap(Map<String, dynamic> map) {
    final rawPredictions = map['predictions'] as List<dynamic>;

    final predictions = rawPredictions.map((p) {
      return WeeklyPredictionEntity(
        date: p['date'] as DateTime,
        averagePrice: (p['average_price'] as num).toDouble(),
        highPrice: (p['high_price'] as num).toDouble(),
        confidence: (p['confidence'] as num?)?.toDouble() ?? 80.0,
        nationalAverage: (p['national_average'] as num?)?.toDouble(),
      );
    }).toList();

    return PricePredictionModel(
      currentPrice: (map['currentPrice'] as num).toDouble(),
      nationalPrice: (map['nationalPrice'] as num?)?.toDouble(),
      predictions: predictions,
      monthlyChange: (map['monthlyChange'] as num).toDouble(),
      trend: map['trend'] as String,
      district: map['district'] as String,
      grade: map['grade'] as String,
      isWeekly: map['isWeekly'] as bool? ?? true,
      isMock: map['mock'] as bool? ?? false,
      modelVersion: map['model_version'] as String?,
    );
  }
}