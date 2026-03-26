import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/mood_genre/data/data_sources/mood_genre_remote_data_source.dart';
import 'package:music_app/features/mood_genre/data/repositories/mood_genre_repository_impl.dart';
import 'package:music_app/features/mood_genre/domain/repositories/mood_genre_repository.dart';
import 'package:music_app/features/mood_genre/domain/use_cases/get_mood_playlists_use_case.dart';

void registerMoodGenreFeature(GetIt getIt) {
  // Data Sources
  if (!getIt.isRegistered<MoodGenreRemoteDataSource>()) {
    getIt.registerLazySingleton<MoodGenreRemoteDataSource>(
      () => MoodGenreRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // Repositories
  if (!getIt.isRegistered<MoodGenreRepository>()) {
    getIt.registerLazySingleton<MoodGenreRepository>(
      () => MoodGenreRepositoryImpl(getIt<MoodGenreRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<GetMoodPlaylistsUseCase>()) {
    getIt.registerLazySingleton<GetMoodPlaylistsUseCase>(
      () => GetMoodPlaylistsUseCase(getIt<MoodGenreRepository>()),
    );
  }

  // NOTA: MoodGenreCubit se crea ahora vía BlocProvider en MoodGenreScreen.wrappedRoute
}
