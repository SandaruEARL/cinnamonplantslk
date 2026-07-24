import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/weekly_prediction_entity.dart';
import '../repositories/ai_repository.dart';

class PredictPriceParams {
  final String district;
  final String grade;

  const PredictPriceParams({
    required this.district,
    required this.grade,
  });
}

class PredictPrice implements UseCase<PricePredictionEntity, PredictPriceParams> {
  final AiRepository repository;

  const PredictPrice(this.repository);

  @override
  Future<Either<Failure, PricePredictionEntity>> call(PredictPriceParams params) {
    return repository.predictPrice(
      district: params.district,
      grade: params.grade,
    );
  }
}