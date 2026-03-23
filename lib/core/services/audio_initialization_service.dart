import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/audio_handler_service.dart';
import 'package:music_app/core/services/logger/app_logger.dart';

/// Servicio dedicado a la inicialización de AudioService para evitar importaciones circulares
class AudioInitializationService {

  /// Inicializa el servicio de audio para notificaciones y controles en pantalla de bloqueo
  ///
  /// ESTA ES LA ÚNICA FUENTE DE AudioPlayer.
  /// Después de esta inicialización, TODO el código debe obtener el AudioPlayer
  /// exclusivamente a través de GetIt<AudioPlayerHandler>().player
  Future<void> initializeAudioService() async {
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
          androidNotificationIcon: 'drawable/ic_notification',
        ),
      );

      // Registrar en GetIt para uso en PlayerBloc
      // AudioPlayerHandler es un singleton - única fuente de AudioPlayer
      if (!GetIt.I.isRegistered<AudioPlayerHandler>()) {
        GetIt.I.registerSingleton<AudioPlayerHandler>(handler);
      }

      // IMPORTANTE: Llamar init() del handler para que transmita estados a notificaciones
      // init() es idempotente, así que es seguro llamarlo múltiples veces
      handler.init();
    } catch (e, stackTrace) {
      AppLogger.error('AudioService init error', e, stackTrace);
      // No bloquea la app si falla el audio, pero sí lo loggeamos para debugging
      rethrow;
    }
  }

  /// Verifica si el AudioService está inicializado
  bool isAudioServiceInitialized() {
    return GetIt.I.isRegistered<AudioPlayerHandler>();
  }

  /// Obtiene el AudioPlayerHandler desde GetIt
  AudioPlayerHandler getAudioPlayerHandler() {
    return GetIt.I<AudioPlayerHandler>();
  }
}