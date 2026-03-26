import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/recently_played/data/datasources/recently_played_remote_data_source.dart';
import 'package:music_app/features/recently_played/data/repositories/recently_played_repository_impl.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';
import 'package:music_app/features/recently_played/domain/usecases/get_recently_played_usecase.dart';
import 'package:music_app/features/recently_played/domain/usecases/record_listen_usecase.dart';

void registerRecentlyPlayedFeature(GetIt getIt) {
  // Data Source
  if (!getIt.isRegistered<RecentlyPlayedRemoteDataSource>()) {
    getIt.registerLazySingleton<RecentlyPlayedRemoteDataSource>(
      () => RecentlyPlayedRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // Repository
  if (!getIt.isRegistered<RecentlyPlayedRepository>()) {
    getIt.registerLazySingleton<RecentlyPlayedRepository>(
      () =>
          RecentlyPlayedRepositoryImpl(getIt<RecentlyPlayedRemoteDataSource>()),
    );
  }

  // Use Case
  if (!getIt.isRegistered<GetRecentlyPlayedUseCase>()) {
    getIt.registerLazySingleton<GetRecentlyPlayedUseCase>(
      () => GetRecentlyPlayedUseCase(getIt<RecentlyPlayedRepository>()),
    );
  }

  // Record Listen Use Case
  if (!getIt.isRegistered<RecordListenUseCase>()) {
    getIt.registerLazySingleton<RecordListenUseCase>(
      () => RecordListenUseCase(getIt<RecentlyPlayedRepository>()),
    );
  }
}
