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
  /// Flujo simplificado:
  /// 1. Carga primera canción con URL
  /// 2. Envía LoadPlaylistEvent (reproduce automáticamente)
  /// 3. Carga resto secuencialmente
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
      // === FASE 1: Cargar primera canción CON bypass cache para obtener URL fresca ===
      final streamUrl = await _getStreamUrlUseCase(nowPlayingTracks.first.videoId, bypassCache: true);
      
      if (streamUrl == null || streamUrl.isEmpty) {
        emit(state.copyWith(isLoadingForPlay: false));
        return;
      }

      // Crear primera canción con URL
      final firstTrack = nowPlayingTracks.first;
      final firstTrackWithUrl = NowPlayingData(
        videoId: firstTrack.videoId,
        title: firstTrack.title,
        artists: firstTrack.artists,
        album: firstTrack.album,
        duration: firstTrack.duration,
        durationSeconds: firstTrack.durationSeconds,
        views: firstTrack.views,
        isExplicit: firstTrack.isExplicit,
        inLibrary: firstTrack.inLibrary,
        thumbnails: firstTrack.thumbnails,
        streamUrl: streamUrl,
        thumbnail: firstTrack.thumbnail,
      );

      // Enviar LoadPlaylistEvent con primera canción
      _playerBloc.add(LoadPlaylistEvent(
        playlist: [firstTrackWithUrl],
        startIndex: 0,
      ));

      emit(state.copyWith(loadedCount: 1));

      // Esperar un poco para ver si la primera canción se reproduce correctamente
      // Si hay error, no continuamos cargando el resto
      await Future.delayed(const Duration(seconds: 2));

      // Verificar si el player tiene un track cargado (si falló, no hay currentTrack o hay error)
      final playerState = _playerBloc.state;
      if (playerState is! PlayerBlocLoaded || 
          playerState.currentTrack == null ||
          playerState.hasError) {
        // La primera canción falló, no continuar cargando
        print("DEBUG: Primera canción falló (currentTrack: ${playerState is PlayerBlocLoaded ? playerState.currentTrack : 'null'}, hasError: ${playerState is PlayerBlocLoaded ? playerState.hasError : 'N/A'}), cancelando carga del resto");
        emit(state.copyWith(isLoadingForPlay: false));
        return;
      }

      print("DEBUG: Primera canción reproduciendo, cargando resto...");

      // === FASE 2: Cargar resto secuencialmente ===
      for (int i = 1; i < nowPlayingTracks.length; i++) {
        // Delay para evitar rate limiting
        await Future.delayed(const Duration(milliseconds: 800));
        
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
      emit(state.copyWith(isLoadingForPlay: false));
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
