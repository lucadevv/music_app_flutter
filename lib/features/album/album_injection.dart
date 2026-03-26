import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/album/data/repositories/album_repository_impl.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

void registerAlbumFeature(GetIt getIt) {
  // AlbumRepository
  if (!getIt.isRegistered<AlbumRepository>()) {
    getIt.registerLazySingleton<AlbumRepository>(
      () => AlbumRepositoryImpl(getIt<ApiServices>()),
    );
  }

  // NOTA: AlbumCubit se crea ahora vía BlocProvider en AlbumScreen
}
