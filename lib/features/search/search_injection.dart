import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:music_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';
import 'package:music_app/features/search/domain/use_cases/get_categories_usecase.dart';
import 'package:music_app/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/update_selected_song_use_case.dart';

void registerSearchFeature(GetIt getIt) {
  // Data Sources
  if (!getIt.isRegistered<SearchRemoteDataSource>()) {
    getIt.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // Repositories
  if (!getIt.isRegistered<SearchRepository>()) {
    getIt.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(getIt<SearchRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<SearchUseCase>()) {
    getIt.registerLazySingleton<SearchUseCase>(
      () => SearchUseCase(getIt<SearchRepository>()),
    );
  }

  if (!getIt.isRegistered<GetRecentSearchesUseCase>()) {
    getIt.registerLazySingleton<GetRecentSearchesUseCase>(
      () => GetRecentSearchesUseCase(getIt<SearchRepository>()),
    );
  }

  if (!getIt.isRegistered<GetCategoriesUseCase>()) {
    getIt.registerLazySingleton<GetCategoriesUseCase>(
      () => GetCategoriesUseCase(getIt<SearchRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateSelectedSongUseCase>()) {
    getIt.registerLazySingleton<UpdateSelectedSongUseCase>(
      () => UpdateSelectedSongUseCase(getIt<SearchRepository>()),
    );
  }

  // Cubits now created directly in screens with BlocProvider
}
