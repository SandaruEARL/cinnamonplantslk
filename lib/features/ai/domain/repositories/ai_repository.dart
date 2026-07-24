import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weekly_prediction_entity.dart';

abstract class AiRepository {
  Future<Either<Failure, PricePredictionEntity>> predictPrice({
    required String district,
    required String grade,
  });
}