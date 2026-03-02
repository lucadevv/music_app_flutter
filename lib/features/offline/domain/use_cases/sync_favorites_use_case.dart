import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/offline/domain/repositories/offline_repository.dart';

/// Use case for syncing favorites when back online.
class SyncFavoritesUseCase {
  final OfflineRepository _repository;

  SyncFavoritesUseCase(this._repository);

  Future<Either<AppException, void>> call(List<Map<String, dynamic>> serverSongs) {
    return _repository.syncFavorites(serverSongs);
  }
}
