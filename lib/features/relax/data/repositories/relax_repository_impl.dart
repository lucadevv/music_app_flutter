import 'package:dartz/dartz.dart';
import 'package:music_app/features/relax/data/datasources/relax_data_source.dart';
import 'package:music_app/features/relax/domain/entities/relax_entity.dart';
import 'package:music_app/features/relax/domain/repositories/relax_repository.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Implementation of RelaxRepository.
class RelaxRepositoryImpl implements RelaxRepository {
  final RelaxDataSource _dataSource;

  RelaxRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, List<RelaxPlaylistEntity>>> getRelaxPlaylists() async {
    try {
      final playlists = await _dataSource.getRelaxPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
