import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/usecases/get_stream_url_usecase.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import '../../domain/use_cases/get_playlist_use_case.dart';

/// Cubit para manejar el estado de la playlist
class PlaylistCubit extends Cubit<PlaylistState> with BaseBlocMixin {
  final GetPlaylistUseCase _getPlaylistUseCase;
  final PlayerBlocBloc _playerBloc;
  final GetStreamUrlUseCase _getStreamUrlUseCase;
  
  PlaylistCubit({
    required GetPlaylistUseCase getPlaylistUseCase,
    required PlayerBlocBloc playerBloc,
  })  : _getPlaylistUseCase = getPlaylistUseCase,
        _playerBloc = playerBloc,
        _getStreamUrlUseCase = GetIt.I<GetStreamUrlUseCase>(),
        super(const PlaylistState());

  /// Carga los datos de una playlist
  Future<void> loadPlaylist(String id) async {
    if (state.status == PlaylistStatus.loading) {
      return;
    }

    // Validar que el ID no esté vacío
    if (id.isEmpty) {
      emit(
        state.copyWith(
          status: PlaylistStatus.failure,
          errorMessage: 'El ID de la playlist no puede estar vacío',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PlaylistStatus.loading, errorMessage: null));

    final result = await _getPlaylistUseCase(id);

    result.fold(
      (failure) {
        final String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: PlaylistStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            status: PlaylistStatus.success,
            response: response,
            errorMessage: null,
          ),
        );
      },
    );
  }

  /// Reproduce la playlist desde el inicio
  /// 
  /// Flujo:
  /// 1. Intenta cargar la primera canción disponible
  /// 2. Si falla, intenta con la siguiente, y así sucesivamente
  /// 3. Una vez que encuentra una que funcione, carga el resto secuencialmente
  Future<void> playAll() async {
    if (state.response == null) return;
    if (state.isLoadingForPlay) return;

    // Obtener tracks disponibles
    final availableTracks = state.response!.tracks
        .where(
          (track) =>
              track.videoId != null &&
              track.videoId!.isNotEmpty &&
              track.isAvailable,
        )
        .toList();

    if (availableTracks.isEmpty) return;

    // Convertir a NowPlayingData
    final nowPlayingTracks = availableTracks
        .map((t) => NowPlayingData.fromPlaylistTrack(t))
        .toList();

    // Resetear estado de carga
    emit(state.copyWith(
      isLoadingForPlay: true,
      loadedCount: 0,
      totalCount: nowPlayingTracks.length,
    ));

    // Reiniciar el player antes de cargar
    _playerBloc.add(const StopEvent());
    
    // Pequeño delay para asegurar que el stop se procese
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // === FASE 1: Encontrar primera canción válida ===
      // Intentar con cada canción hasta encontrar una que funcione
      int startIndex = 0;
      NowPlayingData? firstTrackWithUrl;
      
      while (startIndex < nowPlayingTracks.length) {
        // Verificar si el Cubit fue cerrado antes de continuar
        if (isClosed) return;
        
        final streamUrl = await _getStreamUrlUseCase(
          nowPlayingTracks[startIndex].videoId, 
          bypassCache: true,
        );
        
        // Verificar si fue cerrado durante el await
        if (isClosed) return;
        
        if (streamUrl != null && streamUrl.isNotEmpty) {
          final track = nowPlayingTracks[startIndex];
          firstTrackWithUrl = NowPlayingData(
            videoId: track.videoId,
            title: track.title,
            artists: track.artists,
            album: track.album,
            duration: track.duration,
            durationSeconds: track.durationSeconds,
            views: track.views,
            isExplicit: track.isExplicit,
            inLibrary: track.inLibrary,
            thumbnails: track.thumbnails,
            streamUrl: streamUrl,
            thumbnail: track.thumbnail,
          );
          break; // Encontramos una canción válida
        }
        
        // Esta canción falló, intentar con la siguiente
        startIndex++;
      }

      // Verificar si fue cerrado
      if (isClosed) return;

      // Si ninguna canción funcionó
      if (firstTrackWithUrl == null) {
        emit(state.copyWith(
          isLoadingForPlay: false,
          errorMessage: 'No se pudo reproducir ninguna canción de la playlist',
        ));
        return;
      }

      // Enviar LoadPlaylistEvent con primera canción válida
      _playerBloc.add(LoadPlaylistEvent(
        playlist: [firstTrackWithUrl],
        startIndex: 0,
      ));

      emit(state.copyWith(loadedCount: startIndex + 1));

      // Esperar un poco para ver si la canción se reproduce correctamente
      await Future.delayed(const Duration(seconds: 2));

      // Verificar si fue cerrado durante el delay
      if (isClosed) return;

      // Verificar si el player tiene un track cargado
      final playerState = _playerBloc.state;
      if (playerState is! PlayerBlocLoaded || 
          playerState.currentTrack == null ||
          playerState.hasError) {
        // La canción también falló, cancelar
        emit(state.copyWith(isLoadingForPlay: false));
        return;
      }

      // === FASE 2: Cargar resto secuencialmente ===
      for (int i = 1; i < nowPlayingTracks.length; i++) {
        // Verificar si fue cerrado antes de cada canción
        if (isClosed) return;
        
        // Delay para evitar rate limiting
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Verificar si fue cerrado durante el delay
        if (isClosed) return;
        
        final track = nowPlayingTracks[i];
        final url = await _getStreamUrlUseCase(track.videoId);
        
        if (url != null && url.isNotEmpty) {
          final trackWithUrl = NowPlayingData(
            videoId: track.videoId,
            title: track.title,
            artists: track.artists,
            album: track.album,
            duration: track.duration,
            durationSeconds: track.durationSeconds,
            views: track.views,
            isExplicit: track.isExplicit,
            inLibrary: track.inLibrary,
            thumbnails: track.thumbnails,
            streamUrl: url,
            thumbnail: track.thumbnail,
          );
          _playerBloc.add(AddToPlaylistEvent(trackWithUrl));
          emit(state.copyWith(loadedCount: i + 1));
        }
      }

      // Carga completa
      emit(state.copyWith(
        isLoadingForPlay: false,
        loadedCount: nowPlayingTracks.length,
      ));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoadingForPlay: false));
      }
    }
  }

  /// Cancela la carga de la playlist
  void cancelLoading() {
    emit(state.copyWith(
      isLoadingForPlay: false,
      loadedCount: 0,
      totalCount: 0,
    ));
  }

  /// Reinicia el estado del cubit
  void reset() {
    emit(const PlaylistState());
  }
}
