import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';

part 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> with BaseBlocMixin {
  final AlbumRepository _repository;
  String? _currentAlbumId;

  AlbumCubit(this._repository) : super(const AlbumState());

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

      emit(AlbumState(
        status: AlbumStatus.success,
        album: results[0] as Album,
        songs: results[1] as List<AlbumSong>,
        isLiked: results[2] as bool,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: AlbumStatus.failure,
        errorMessage: e.toString(),
      ));
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

  void playSong(AlbumSong song) {
    // This will be connected to PlayerBloc via the screen
  }
}
