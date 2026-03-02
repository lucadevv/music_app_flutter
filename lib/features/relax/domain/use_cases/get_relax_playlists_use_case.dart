import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/relax/domain/entities/relax_entity.dart';
import 'package:music_app/features/relax/domain/repositories/relax_repository.dart';

/// Use case for getting relax playlists.
class GetRelaxPlaylistsUseCase {
  final RelaxRepository _repository;

  GetRelaxPlaylistsUseCase(this._repository);

  Future<Either<AppException, List<RelaxPlaylistEntity>>> call() {
    return _repository.getRelaxPlaylists();
  }
}
