// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/features/artist/domain/use_cases/follow_artist_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/get_artist_albums_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/get_artist_top_songs_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/get_artist_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/is_following_artist_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/unfollow_artist_use_case.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

part 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> with BaseBlocMixin {
  final GetArtistUseCase _getArtistUseCase;
  final GetArtistTopSongsUseCase _getArtistTopSongsUseCase;
  final GetArtistAlbumsUseCase _getArtistAlbumsUseCase;
  final FollowArtistUseCase _followArtistUseCase;
  final UnfollowArtistUseCase _unfollowArtistUseCase;
  final IsFollowingArtistUseCase _isFollowingArtistUseCase;
  final PlayerBlocBloc _playerBloc;
  String? _currentArtistId;

  ArtistCubit({
    required GetArtistUseCase getArtistUseCase,
    required GetArtistTopSongsUseCase getArtistTopSongsUseCase,
    required GetArtistAlbumsUseCase getArtistAlbumsUseCase,
    required FollowArtistUseCase followArtistUseCase,
    required UnfollowArtistUseCase unfollowArtistUseCase,
    required IsFollowingArtistUseCase isFollowingArtistUseCase,
    required PlayerBlocBloc playerBloc,
  }) : _getArtistUseCase = getArtistUseCase,
       _getArtistTopSongsUseCase = getArtistTopSongsUseCase,
       _getArtistAlbumsUseCase = getArtistAlbumsUseCase,
       _followArtistUseCase = followArtistUseCase,
       _unfollowArtistUseCase = unfollowArtistUseCase,
       _isFollowingArtistUseCase = isFollowingArtistUseCase,
       _playerBloc = playerBloc,
       super(const ArtistState());

  Future<void> loadArtist(String artistId) async {
    if (state.status == ArtistStatus.loading) return;

    _currentArtistId = artistId;
    emit(state.copyWith(status: ArtistStatus.loading));

    try {
      // Load artist details, top songs, and albums in parallel
      final results = await Future.wait([
        _getArtistUseCase(artistId),
        _getArtistTopSongsUseCase(artistId),
        _getArtistAlbumsUseCase(artistId),
        _isFollowingArtistUseCase(artistId),
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
        await _unfollowArtistUseCase(artistId);
      } else {
        await _followArtistUseCase(artistId);
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

  NowPlayingData? playAllTopSongs(
    List<ArtistSong> songs, {
    int startIndex = 0,
  }) {
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
