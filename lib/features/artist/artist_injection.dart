import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/artist/data/repositories/artist_repository_impl.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

void registerArtistFeature(GetIt getIt) {
  // ArtistRepository
  if (!getIt.isRegistered<ArtistRepository>()) {
    getIt.registerLazySingleton<ArtistRepository>(
      () => ArtistRepositoryImpl(getIt<ApiServices>()),
    );
  }

  // NOTA: ArtistCubit se crea ahora vía BlocProvider en ArtistScreen
}
