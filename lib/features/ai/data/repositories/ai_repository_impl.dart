import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/price_prediction_entity.dart';
import '../../domain/entities/weekly_prediction_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_local_datasource.dart';
import '../models/price_prediction_model.dart';

class AiRepositoryImpl implements AiRepository {
  final AiLocalDatasource datasource;

  const AiRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, PricePredictionEntity>> predictPrice({
    required String district,
    required String grade,
  }) async {
    try {
      final raw = await datasource.predictPrice(
        district: district,
        grade: grade,
      );
      final entity = PricePredictionModel.fromMap(raw);
      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}