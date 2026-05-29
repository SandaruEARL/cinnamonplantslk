import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/marketplace_repository.dart';

class AddToFavorites extends UseCase<void, FavoriteParams> {
  final MarketplaceRepository repository;
  AddToFavorites(this.repository);

  @override
  Future<Either<Failure, void>> call(FavoriteParams params) {
    return repository.addToFavorites(params.userId, params.adId);
  }
}

class RemoveFromFavorites extends UseCase<void, FavoriteParams> {
  final MarketplaceRepository repository;
  RemoveFromFavorites(this.repository);

  @override
  Future<Either<Failure, void>> call(FavoriteParams params) {
    return repository.removeFromFavorites(params.userId, params.adId);
  }
}

class FavoriteParams {
  final String userId;
  final String adId;
  const FavoriteParams({required this.userId, required this.adId});
}