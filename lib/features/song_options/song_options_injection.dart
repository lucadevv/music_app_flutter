import 'package:get_it/get_it.dart';
import 'package:music_app/features/library/domain/repositories/library_repository.dart';
import 'package:music_app/features/song_options/domain/use_cases/add_to_playlist_use_case.dart';
import 'package:music_app/features/song_options/domain/use_cases/create_playlist_use_case.dart';
import 'package:music_app/features/song_options/domain/use_cases/get_user_playlists_use_case.dart';
import 'package:music_app/features/user_playlists/domain/repositories/user_playlists_repository.dart';

void registerSongOptionsFeature(GetIt getIt) {
  // Use Cases - depend on UserPlaylistsRepository and LibraryRepository
  if (!getIt.isRegistered<GetUserPlaylistsUseCase>()) {
    getIt.registerLazySingleton<GetUserPlaylistsUseCase>(
      () => GetUserPlaylistsUseCase(getIt<UserPlaylistsRepository>()),
    );
  }

  if (!getIt.isRegistered<CreatePlaylistUseCase>()) {
    getIt.registerLazySingleton<CreatePlaylistUseCase>(
      () => CreatePlaylistUseCase(getIt<UserPlaylistsRepository>()),
    );
  }

  // AddToPlaylistUseCase depends on LibraryRepository
  if (!getIt.isRegistered<AddToPlaylistUseCase>()) {
    // Import LibraryRepository dynamically to avoid circular dependencies
    getIt.registerLazySingleton<AddToPlaylistUseCase>(
      () => AddToPlaylistUseCase(getIt<LibraryRepository>()),
    );
  }
}
