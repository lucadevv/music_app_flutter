import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:music_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:music_app/features/home/domain/repositories/home_repository.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';

void registerHomeFeature(GetIt getIt) {
  // Data Sources
  if (!getIt.isRegistered<HomeRemoteDataSource>()) {
    getIt.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // Repositories
  if (!getIt.isRegistered<HomeRepository>()) {
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<GetHomeUseCase>()) {
    getIt.registerLazySingleton<GetHomeUseCase>(
      () => GetHomeUseCase(getIt<HomeRepository>()),
    );
  }

  // NOTA: HomeCubit se crea ahora vía BlocProvider en HomeShell.wrappedRoute
  // Se elimina el registro de GetIt para mantener consistencia con el patrón
}
