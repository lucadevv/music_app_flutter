import 'package:get_it/get_it.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/player/data/datasources/radio_remote_data_source.dart';
import 'package:music_app/features/player/data/repositories/player_repository_impl.dart';
import 'package:music_app/features/player/data/repositories/radio_repository_impl.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';
import 'package:music_app/features/player/domain/repositories/radio_repository.dart';
import 'package:music_app/features/player/domain/services/history_state_service.dart';
import 'package:music_app/features/player/domain/usecases/get_history_use_case.dart';
import 'package:music_app/features/player/domain/usecases/get_radio_playlist_usecase.dart';
import 'package:music_app/features/player/domain/usecases/get_similar_songs_use_case.dart';
import 'package:music_app/features/player/domain/usecases/manage_history_use_case.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';

void registerPlayerFeature(GetIt getIt) {
  // Data Sources
  if (!getIt.isRegistered<RadioRemoteDataSource>()) {
    getIt.registerLazySingleton<RadioRemoteDataSource>(
      () => RadioRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // Repositories
  if (!getIt.isRegistered<RadioRepository>()) {
    getIt.registerLazySingleton<RadioRepository>(
      () => RadioRepositoryImpl(getIt<RadioRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<GetRadioPlaylistUseCase>()) {
    getIt.registerLazySingleton<GetRadioPlaylistUseCase>(
      () => GetRadioPlaylistUseCase(getIt<RadioRepository>()),
    );
  }

  // PlayerRepository - singleton async (needs OfflineService which is async)
  if (!getIt.isRegistered<PlayerRepository>()) {
    getIt.registerLazySingletonAsync<PlayerRepository>(
      () async => PlayerRepositoryImpl(
        offlineService: await getIt.getAsync<OfflineService>(),
        recentlyPlayedRepository: getIt<RecentlyPlayedRepository>(),
      ),
    );
  }

  // HistoryStateService - singleton to manage history state
  if (!getIt.isRegistered<HistoryStateService>()) {
    getIt.registerLazySingleton<HistoryStateService>(
      () => HistoryStateService(getIt<PlayerRepository>()),
    );
  }

  // Player Use Cases - factory (new instance each time for stateful use cases)
  if (!getIt.isRegistered<ManageHistoryUseCase>()) {
    getIt.registerFactory<ManageHistoryUseCase>(
      () => ManageHistoryUseCase(getIt<HistoryStateService>()),
    );
  }

  if (!getIt.isRegistered<GetHistoryUseCase>()) {
    getIt.registerFactory<GetHistoryUseCase>(
      () => GetHistoryUseCase(getIt<PlayerRepository>()),
    );
  }

  if (!getIt.isRegistered<GetSimilarSongsUseCase>()) {
    getIt.registerFactory<GetSimilarSongsUseCase>(
      () => GetSimilarSongsUseCase(getIt<PlayerRepository>()),
    );
  }

  // PlayerBlocBloc now created directly in app.dart, NO longer registered here
  // PlayerFacade usa el PlayerBlocBloc de app.dart, NO crea uno nuevo
  // NOTA: PlayerFacade se registra en app.dart después de crear PlayerBlocBloc
}
