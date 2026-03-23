import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/app.dart';
import 'package:music_app/core/app_injection/app_injection.dart';
import 'package:music_app/core/config/app_config.dart';
import 'package:music_app/core/services/audio_initialization_service.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar AudioService ANTES de todo para que funcione correctamente
  // Esto es CRÍTICO para que las notificaciones aparezcan
  await _initAudioService();

  // Create AppInjection but DON'T call init() in constructor
  final appInjection = AppInjection(getIt: getIt, baseUrl: AppConfig.baseUrl);

  // CRITICAL: Call init() to register all dependencies in proper order
  await appInjection.init();

  // Now wait for all async singletons to be ready
  await getIt.allReady();

  // Forzar inicialización de OfflineService
  await getIt.getAsync<OfflineService>();

  runApp(const App());
}

/// Inicializa el servicio de audio para notificaciones y controles en pantalla de bloqueo
/// Usa el AudioInitializationService para evitar importaciones circulares
Future<void> _initAudioService() async {
  final audioInitializationService = AudioInitializationService();
  await audioInitializationService.initializeAudioService();
}
