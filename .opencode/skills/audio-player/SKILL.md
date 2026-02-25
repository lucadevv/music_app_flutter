---
name: audio-player
description: Patrones de integración con just_audio y audio_service en este proyecto. PlayerBlocBloc, NowPlayingData, manejo de streams, queue, controles. Usar cuando trabajes con reproducción de audio.
---

# Audio Player - Music App

## Arquitectura del Player

```
PlayerBlocBloc (singleton GetIt)
    ├── AudioPlayer (just_audio) — reproducción real
    ├── AudioHandler? (audio_service) — notificaciones del sistema
    └── Streams suscritos:
        ├── playerStateStream → AudioPlayerStateChangedEvent
        ├── positionStream    → PositionChangedEvent
        ├── durationStream    → DurationChangedEvent
        ├── bufferedPositionStream → BufferedPositionChangedEvent
        └── currentIndexStream → CurrentIndexChangedEvent
```

## NowPlayingData — Entidad central

```dart
// 3 formas de crear NowPlayingData:

// 1. Desde Song (búsqueda)
final track = NowPlayingData.fromSong(song);

// 2. Desde PlaylistTrack
final track = NowPlayingData.fromPlaylistTrack(playlistTrack);

// 3. Desde datos básicos (charts, etc.)
final track = NowPlayingData.fromBasic(
  videoId: chartSong.videoId,
  title: chartSong.title,
  artistNames: [chartSong.artist],
  albumName: '',
  duration: '3:30',
  streamUrl: chartSong.streamUrl,
  thumbnailUrl: chartSong.thumbnail,
);
```

## Reproducir desde cualquier feature

```dart
// Obtener PlayerBlocBloc
final playerBloc = context.read<PlayerBlocBloc>();
// o desde GetIt:
final playerBloc = getIt<PlayerBlocBloc>();

// Reproducir canción individual
playerBloc.add(LoadTrackEvent(track: NowPlayingData.fromSong(song)));

// Reproducir playlist completa desde índice específico
final playlist = tracks.map(NowPlayingData.fromPlaylistTrack).toList();
playerBloc.add(LoadPlaylistEvent(playlist: playlist, startIndex: 2));

// Reproducir track en índice actual de la queue
playerBloc.add(PlayTrackAtIndexEvent(index: 3));

// Agregar a queue
playerBloc.add(AddToPlaylistEvent(track: newTrack));

// Remover de queue
playerBloc.add(RemoveFromPlaylistEvent(index: 1));
```

## Controles de reproducción

```dart
// Play/Pause
playerBloc.add(const PlayEvent());
playerBloc.add(const PauseEvent());
playerBloc.add(const PlayPauseToggleEvent()); // toggle

// Navegación
playerBloc.add(const NextTrackEvent());
playerBloc.add(const PreviousTrackEvent());
playerBloc.add(SeekEvent(position: const Duration(seconds: 45)));

// Modo repetición
playerBloc.add(SetLoopModeEvent(loopMode: LoopMode.off));
playerBloc.add(SetLoopModeEvent(loopMode: LoopMode.one));   // repetir canción
playerBloc.add(SetLoopModeEvent(loopMode: LoopMode.all));   // repetir playlist

// Shuffle
playerBloc.add(const ToggleShuffleEvent());

// Volumen y velocidad
playerBloc.add(SetVolumeEvent(volume: 0.8));   // 0.0 - 1.0
playerBloc.add(SetSpeedEvent(speed: 1.5));     // 0.5 - 2.0
```

## Leer estado del player en widgets

```dart
// PlayerBlocLoaded contiene toda la info
BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
  builder: (context, state) {
    if (state is PlayerBlocInitial) {
      return const SizedBox.shrink(); // no hay nada reproduciéndose
    }
    
    final loaded = state as PlayerBlocLoaded;
    
    return Column(
      children: [
        // Info de la canción actual
        if (loaded.currentTrack != null) ...[
          Text(loaded.currentTrack!.title),
          Text(loaded.currentTrack!.artistsNames),
          CachedNetworkImage(
            imageUrl: loaded.currentTrack!.bestThumbnail?.url ?? '',
          ),
        ],
        
        // Barra de progreso
        Slider(
          value: loaded.position.inSeconds.toDouble(),
          max: loaded.duration.inSeconds.toDouble(),
          onChanged: (value) => playerBloc.add(
            SeekEvent(position: Duration(seconds: value.toInt())),
          ),
        ),
        
        // Estado de reproducción
        if (loaded.isLoading)
          const CircularProgressIndicator()
        else
          IconButton(
            icon: Icon(loaded.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () => playerBloc.add(const PlayPauseToggleEvent()),
          ),
        
        // Botones siguiente/anterior
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: loaded.canPlayPrevious
              ? () => playerBloc.add(const PreviousTrackEvent())
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: loaded.canPlayNext
              ? () => playerBloc.add(const NextTrackEvent())
              : null,
        ),
      ],
    );
  },
)
```

## Estado PlayerBlocLoaded — propiedades clave

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `currentTrack` | `NowPlayingData?` | Canción actual |
| `playlist` | `List<NowPlayingData>` | Queue completa |
| `currentIndex` | `int?` | Índice en la queue |
| `isPlaying` | `bool` | ¿Está reproduciendo? |
| `isLoading` | `bool` | ¿Cargando audio? |
| `position` | `Duration` | Posición actual |
| `duration` | `Duration` | Duración total |
| `bufferedPosition` | `Duration` | Buffer descargado |
| `loopMode` | `LoopMode` | off/one/all |
| `isShuffleEnabled` | `bool` | Shuffle activo |
| `volume` | `double` | 0.0 - 1.0 |
| `canPlayNext` | `bool` | Hay siguiente track |
| `canPlayPrevious` | `bool` | Hay track anterior |
| `error` | `String?` | Error de reproducción |

## Mini-player (en DashboardShell)

El mini-player aparece sobre el bottom nav cuando hay algo reproduciéndose:

```dart
// Mostrar mini-player condicionalmente
BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
  buildWhen: (prev, curr) {
    // Solo reconstruir cuando cambia el track o el estado play/pause
    if (prev is PlayerBlocLoaded && curr is PlayerBlocLoaded) {
      return prev.currentTrack != curr.currentTrack ||
             prev.isPlaying != curr.isPlaying;
    }
    return prev.runtimeType != curr.runtimeType;
  },
  builder: (context, state) {
    if (state is! PlayerBlocLoaded || state.currentTrack == null) {
      return const SizedBox.shrink();
    }
    return MiniPlayerWidget(state: state);
  },
)
```

## Errores comunes y soluciones

```dart
// ERROR: streamUrl es null
// CAUSA: endpoint sin include_stream_urls=true
// SOLUCIÓN: cambiar endpoint
final endpoint = '/music/playlists/$id?include_stream_urls=true'; // ✓

// ERROR: Audio no inicia
// CAUSA: streamUrl vacío o formato incorrecto
// VERIFICAR:
if (streamUrl == null || streamUrl.isEmpty) {
  // manejar error, no intentar reproducir
}

// ERROR: Stream ya tiene listener
// CAUSA: PlayerBlocBloc instanciado múltiples veces
// SOLUCIÓN: debe ser singleton en GetIt
_getIt.registerLazySingleton<PlayerBlocBloc>(() => PlayerBlocBloc());

// ERROR: Position jumps al seek
// CAUSA: múltiples SeekEvents en corto tiempo
// SOLUCIÓN: debounce en el slider
```
