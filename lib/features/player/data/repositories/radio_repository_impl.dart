import '../../domain/repositories/radio_repository.dart';
import '../datasources/radio_remote_data_source.dart';

/// Implementación del repositorio de radio
class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource _remoteDataSource;

  RadioRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> getRadioPlaylist(String videoId, {int limit = 10}) async {
    return _remoteDataSource.getRadioPlaylist(videoId, limit: limit);
  }
}
