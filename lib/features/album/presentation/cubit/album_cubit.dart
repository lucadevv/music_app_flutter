// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> with BaseBlocMixin {
  final AlbumRepository _repository;
  final PlayerBlocBloc _playerBloc;
  String? _currentAlbumId;

  AlbumCubit(this._repository, this._playerBloc) : super(const AlbumState());

  Future<void> loadAlbum(String albumId) async {
    if (state.status == AlbumStatus.loading) return;

    _currentAlbumId = albumId;
    emit(state.copyWith(status: AlbumStatus.loading));

    try {
      // Load album details and songs in parallel
      final results = await Future.wait([
        _repository.getAlbum(albumId),
        _repository.getAlbumSongs(albumId),
        _repository.isLiked(albumId),
      ]);

      if (isClosed) return;

      emit(
        AlbumState(
          status: AlbumStatus.success,
          album: results[0] as Album,
          songs: results[1] as List<AlbumSong>,
          isLiked: results[2] as bool,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(status: AlbumStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleLike() async {
    final albumId = _currentAlbumId;
    if (albumId == null) return;

    try {
      if (state.isLiked) {
        await _repository.unlikeAlbum(albumId);
      } else {
        await _repository.likeAlbum(albumId);
      }

      if (isClosed) return;
      emit(state.copyWith(isLiked: !state.isLiked));
    } catch (e) {
      // Handle error silently
    }
  }

  bool playSong(AlbumSong song, List<AlbumSong> allSongs) {
    // Validar streamUrl
    if (song.streamUrl == null || song.streamUrl!.isEmpty) {
      emit(state.copyWith(errorMessage: 'Canción no disponible'));
      return false;
    }

    // NO disparamos LoadTrackEvent aquí - PlayerScreen lo hace
    // Solo preparamos los datos y retornamos true
    return true;
  }

  NowPlayingData? playAllAlbumSongs(List<AlbumSong> songs, {int startIndex = 0}) {
    if (songs.isEmpty) return null;

    final validSongs = songs
        .where(
          (s) =>
              s.videoId.isNotEmpty &&
              s.streamUrl != null &&
              s.streamUrl!.isNotEmpty,
        )
        .toList();

    if (validSongs.isEmpty) return null;

    if (startIndex < 0 || startIndex >= validSongs.length) {
      startIndex = 0;
    }

    final playlist = validSongs.map(mapAlbumSongToNowPlaying).toList();

    _playerBloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: startIndex,
        sourceId: 'album:$_currentAlbumId',
      ),
    );

    return playlist[startIndex];
  }

  NowPlayingData mapAlbumSongToNowPlaying(AlbumSong song) {
    final albumName = state.album?.title ?? '';
    final artistName = state.album?.artistName ?? 'Unknown Artist';
    return NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [artistName],
      albumName: albumName,
      duration: song.formattedDuration,
      durationSeconds: song.durationSeconds,
      thumbnailUrl: song.thumbnail,
      streamUrl: song.streamUrl,
    );
  }
}
