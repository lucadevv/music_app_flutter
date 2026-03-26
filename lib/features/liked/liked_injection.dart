import 'package:get_it/get_it.dart';
import 'package:music_app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:music_app/features/liked/data/datasources/liked_data_source.dart';
import 'package:music_app/features/liked/data/datasources/liked_local_data_source.dart';
import 'package:music_app/features/liked/data/repositories/liked_repository_impl.dart';
import 'package:music_app/features/liked/domain/repositories/liked_repository.dart';
import 'package:music_app/features/liked/domain/use_cases/add_liked_song_use_case.dart';
import 'package:music_app/features/liked/domain/use_cases/get_liked_songs_use_case.dart';
import 'package:music_app/features/liked/domain/use_cases/is_song_liked_use_case.dart';
import 'package:music_app/features/liked/domain/use_cases/remove_liked_song_use_case.dart';

void registerLikedFeature(GetIt getIt) {
  // Data Source
  if (!getIt.isRegistered<LikedDataSource>()) {
    getIt.registerLazySingleton<LikedDataSource>(
      () => LikedDataSource(
        getIt<LibraryRemoteDataSource>(),
        getIt<LikedLocalDataSource>(),
      ),
    );
  }

  // Local Data Source
  if (!getIt.isRegistered<LikedLocalDataSource>()) {
    getIt.registerLazySingleton<LikedLocalDataSource>(LikedLocalDataSource.new);
  }

  // Repository
  if (!getIt.isRegistered<LikedRepository>()) {
    getIt.registerLazySingleton<LikedRepository>(
      () => LikedRepositoryImpl(getIt<LikedDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<GetLikedSongsUseCase>()) {
    getIt.registerLazySingleton<GetLikedSongsUseCase>(
      () => GetLikedSongsUseCase(getIt<LikedRepository>()),
    );
  }

  if (!getIt.isRegistered<AddLikedSongUseCase>()) {
    getIt.registerLazySingleton<AddLikedSongUseCase>(
      () => AddLikedSongUseCase(getIt<LikedRepository>()),
    );
  }

  if (!getIt.isRegistered<RemoveLikedSongUseCase>()) {
    getIt.registerLazySingleton<RemoveLikedSongUseCase>(
      () => RemoveLikedSongUseCase(getIt<LikedRepository>()),
    );
  }

  if (!getIt.isRegistered<IsSongLikedUseCase>()) {
    getIt.registerLazySingleton<IsSongLikedUseCase>(
      () => IsSongLikedUseCase(getIt<LikedRepository>()),
    );
  }

  // LikedSongsCubit se crea vía BlocProvider en LikedSongsScreen
}
