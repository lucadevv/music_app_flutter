import '../../domain/repositories/stream_url_repository.dart';
import '../datasources/stream_url_remote_data_source.dart';

/// Implementación del repositorio de Stream URL
class StreamUrlRepositoryImpl implements StreamUrlRepository {
  final StreamUrlRemoteDataSource _remoteDataSource;

  StreamUrlRepositoryImpl(this._remoteDataSource);

  @override
  Future<String?> getStreamUrl(String videoId, {bool bypassCache = false}) {
    return _remoteDataSource.getStreamUrl(videoId, bypassCache: bypassCache);
  }
}
