// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> with BaseBlocMixin {
  final ArtistRepository _repository;
  final PlayerBlocBloc _playerBloc;
  String? _currentArtistId;

  ArtistCubit(this._repository, this._playerBloc) : super(const ArtistState());

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

  bool playSong(ArtistSong song, List<ArtistSong> allSongs) {
    // Validar streamUrl
    if (song.streamUrl == null || song.streamUrl!.isEmpty) {
      emit(state.copyWith(errorMessage: 'Canción no disponible'));
      return false;
    }

    // NO disparamos LoadTrackEvent aquí - PlayerScreen lo hace
    // Solo preparamos los datos y retornamos true
    return true;
  }

  NowPlayingData? playAllTopSongs(List<ArtistSong> songs, {int startIndex = 0}) {
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

    final playlist = validSongs.map(mapArtistSongToNowPlaying).toList();

    _playerBloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: startIndex,
        sourceId: 'artist:$_currentArtistId',
      ),
    );

    return playlist[startIndex];
  }

  NowPlayingData mapArtistSongToNowPlaying(ArtistSong song) {
    final artistName = state.artist?.name ?? 'Unknown Artist';
    return NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [artistName],
      albumName: '',
      duration: song.formattedDuration,
      durationSeconds: song.durationSeconds,
      thumbnailUrl: song.thumbnail,
      streamUrl: song.streamUrl,
    );
  }
}
