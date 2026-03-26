import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/playlist/data/data_sources/playlist_remote_data_source.dart';
import 'package:music_app/features/playlist/data/repositories/playlist_repository_impl.dart';
import 'package:music_app/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:music_app/features/playlist/domain/use_cases/get_playlist_use_case.dart';

void registerPlaylistFeature(GetIt getIt) {
  // Data Sources
  if (!getIt.isRegistered<PlaylistRemoteDataSource>()) {
    getIt.registerLazySingleton<PlaylistRemoteDataSource>(
      () => PlaylistRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // Repositories
  if (!getIt.isRegistered<PlaylistRepository>()) {
    getIt.registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(getIt<PlaylistRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<GetPlaylistUseCase>()) {
    getIt.registerLazySingleton<GetPlaylistUseCase>(
      () => GetPlaylistUseCase(getIt<PlaylistRepository>()),
    );
  }

  // PlaylistCubit se crea directamente en PlaylistScreen con BlocProvider
  // No se registra aquí porque necesita PlayerBloc que es un singleton
}
