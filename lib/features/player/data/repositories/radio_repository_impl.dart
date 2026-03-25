import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/radio_track_entity.dart';
import '../../domain/repositories/radio_repository.dart';
import '../datasources/radio_remote_data_source.dart';

/// Implementación del repositorio de radio
class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource _remoteDataSource;

  RadioRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<RadioTrackEntity>>> getRadioPlaylist(
    String videoId, {
    int limit = 10,
  }) async {
    try {
      final models = await _remoteDataSource.getRadioPlaylist(
        videoId,
        limit: limit,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
