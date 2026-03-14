// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';

part 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> with BaseBlocMixin {
  final ArtistRepository _repository;
  String? _currentArtistId;

  ArtistCubit(this._repository) : super(const ArtistState());

  Future<void> loadArtist(String artistId) async {
    if (state.status == ArtistStatus.loading) return;

    _currentArtistId = artistId;
    emit(state.copyWith(status: ArtistStatus.loading));

    try {
      // Load artist details, top songs, and albums in parallel
      final results = await Future.wait([
        _repository.getArtist(artistId),
        _repository.getArtistTopSongs(artistId),
        _repository.getArtistAlbums(artistId),
        _repository.isFollowing(artistId),
      ]);

      if (isClosed) return;

      emit(
        ArtistState(
          status: ArtistStatus.success,
          artist: results[0] as Artist,
          topSongs: results[1] as List<ArtistSong>,
          albums: results[2] as List<ArtistAlbum>,
          isFollowing: results[3] as bool,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ArtistStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> toggleFollow() async {
    final artistId = _currentArtistId;
    if (artistId == null) return;

    try {
      if (state.isFollowing) {
        await _repository.unfollowArtist(artistId);
      } else {
        await _repository.followArtist(artistId);
      }

      if (isClosed) return;
      emit(state.copyWith(isFollowing: !state.isFollowing));
    } catch (e) {
      // Handle error silently or emit error state
    }
  }

  void playSong(ArtistSong song) {
    // This will be connected to PlayerBloc
    // For now, the UI will handle this
  }
}
