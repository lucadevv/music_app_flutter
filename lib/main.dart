import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/app.dart';
import 'package:music_app/core/app_injection/app_injection.dart';
import 'package:music_app/core/config/app_config.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/audio_handler_service.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/profile/profile_cubit.dart';


final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar AudioService ANTES de todo para que funcione correctamente
  // Esto es CRÍTICO para que las notificaciones aparezcan
  await _initAudioService();
  
  // Create AppInjection but DON'T call init() in constructor
  final appInjection = AppInjection(
    getIt: getIt,
    baseUrl: AppConfig.baseUrl,
    accessToken: AppConfig.accessToken,
  );
  
  // CRITICAL: Call init() to register all dependencies in proper order
  // This ensures AuthManager is ready BEFORE ProfileCubit is registered
  await appInjection.init();
  print('[Boot] AppInjection.init() complete, waiting for allReady()...');
  
  // Now wait for all async singletons to be ready
  await getIt.allReady();
  print('[Boot] getIt.allReady() complete');
  
  // Forzar inicialización de OfflineService
  await getIt.getAsync<OfflineService>();
  
  // Cargar settings después de que la app esté lista
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadUserSettings();
  });
  
  runApp(const App());
}

/// Inicializa el servicio de audio para notificaciones y controles en pantalla de bloqueo
/// 
/// Esta es la forma correcta según la documentación oficial de audio_service
Future<void> _initAudioService() async {
  try {
    // El handler returned por AudioService.init() es el mismo que se crea en el builder
    final handler = await AudioService.init(
      builder: AudioPlayerHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.lucadev.musicapp.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidStopForegroundOnPause: true,
      ),
    );
    
    // registrar en GetIt para uso en PlayerBloc
    if (!GetIt.I.isRegistered<AudioPlayerHandler>()) {
      GetIt.I.registerSingleton<AudioPlayerHandler>(handler);
    }
    
    // IMPORTANTE: Llamar init() del handler para que transmita estados a notificaciones
    handler.init();
  } catch (e) {
    // No bloquea la app si falla
  }
}

/// Carga los settings del usuario
Future<void> _loadUserSettings() async {
  try {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final authManager = getIt<AuthManager>();
    final isLoggedIn = await authManager.isUserLoggedIn();
    
    if (isLoggedIn) {
      final profileCubit = getIt<ProfileCubit>();
      await profileCubit.loadSettings();
    }
  } catch (e) {
    // Silently fail
  }
}
