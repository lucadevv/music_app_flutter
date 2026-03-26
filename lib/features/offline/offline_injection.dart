import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';

void registerOfflineFeature(GetIt getIt) {
  // Connectivity - singleton to verify connection status
  if (!getIt.isRegistered<Connectivity>()) {
    getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  // OfflineService - singleton async because needs initialization with init()
  if (!getIt.isRegistered<OfflineService>()) {
    getIt.registerLazySingletonAsync<OfflineService>(() async {
      final service = OfflineService(getIt<Dio>(), getIt<Connectivity>());
      await service.init();
      return service;
    });
  }

  // PlaylistOfflineCubit now created directly in app.dart, NO longer registered here
  // HistoryCubit now created directly in app.dart, NO longer registered here
}
