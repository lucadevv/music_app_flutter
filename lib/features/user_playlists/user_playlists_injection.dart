import 'package:get_it/get_it.dart';
import 'package:music_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:music_app/features/user_playlists/data/datasources/user_playlists_data_source.dart';
import 'package:music_app/features/user_playlists/data/repositories/user_playlists_repository_impl.dart';
import 'package:music_app/features/user_playlists/domain/repositories/user_playlists_repository.dart';
import 'package:music_app/features/user_playlists/domain/use_cases/get_all_playlists_use_case.dart';

void registerUserPlaylistsFeature(GetIt getIt) {
  // Data Source
  if (!getIt.isRegistered<UserPlaylistsDataSource>()) {
    getIt.registerLazySingleton<UserPlaylistsDataSource>(
      () => UserPlaylistsDataSource(getIt<LibraryRemoteDataSource>()),
    );
  }

  // Repository
  if (!getIt.isRegistered<UserPlaylistsRepository>()) {
    getIt.registerLazySingleton<UserPlaylistsRepository>(
      () => UserPlaylistsRepositoryImpl(getIt<UserPlaylistsDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<GetAllPlaylistsUseCase>()) {
    getIt.registerLazySingleton<GetAllPlaylistsUseCase>(
      () => GetAllPlaylistsUseCase(getIt<UserPlaylistsRepository>()),
    );
  }
}
