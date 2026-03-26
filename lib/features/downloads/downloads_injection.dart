import 'package:get_it/get_it.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/downloads/data/data_sources/downloads_local_data_source.dart';
import 'package:music_app/features/downloads/data/repositories/downloads_repository_impl.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:music_app/features/downloads/domain/use_cases/check_download_status_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/get_downloaded_songs_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/remove_download_use_case.dart';

void registerDownloadsFeature(GetIt getIt) {
  // Data Sources - singleton because needs to share state with OfflineService
  if (!getIt.isRegistered<DownloadsLocalDataSource>()) {
    getIt.registerLazySingletonAsync<DownloadsLocalDataSource>(() async {
      final dataSource = DownloadsLocalDataSourceImpl(
        await getIt.getAsync<OfflineService>(),
      );
      await dataSource.init();
      return dataSource;
    });
  }

  // Repository - singleton to share state
  if (!getIt.isRegistered<DownloadsRepository>()) {
    getIt.registerLazySingletonAsync<DownloadsRepository>(
      () async => DownloadsRepositoryImpl(
        await getIt.getAsync<DownloadsLocalDataSource>(),
      ),
    );
  }

  // Use Cases - factory async because they depend on repository async
  if (!getIt.isRegistered<DownloadSongUseCase>()) {
    getIt.registerFactoryAsync<DownloadSongUseCase>(
      () async =>
          DownloadSongUseCase(await getIt.getAsync<DownloadsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetDownloadedSongsUseCase>()) {
    getIt.registerFactoryAsync<GetDownloadedSongsUseCase>(
      () async => GetDownloadedSongsUseCase(
        await getIt.getAsync<DownloadsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<RemoveDownloadUseCase>()) {
    getIt.registerFactoryAsync<RemoveDownloadUseCase>(
      () async =>
          RemoveDownloadUseCase(await getIt.getAsync<DownloadsRepository>()),
    );
  }

  if (!getIt.isRegistered<CheckDownloadStatusUseCase>()) {
    getIt.registerFactoryAsync<CheckDownloadStatusUseCase>(
      () async => CheckDownloadStatusUseCase(
        await getIt.getAsync<DownloadsRepository>(),
      ),
    );
  }

  // DownloadsCubit now created directly in app.dart, NO longer registered here
}
