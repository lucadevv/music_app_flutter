import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/presentation/widgets/organisms/player_content_builder_widget.dart';

@RoutePage()
class PlayerScreen extends StatefulWidget {
  final NowPlayingData nowPlayingData;
  final bool playAsSingle;
  final bool showFavoriteButton;
  final bool showExtras;

  const PlayerScreen({
    required this.nowPlayingData,
    this.playAsSingle = false,
    this.showFavoriteButton = true,
    this.showExtras = true,
    super.key,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _hasRequestedPlay = false;
  String? _lastVideoId;

  NowPlayingData get _nowPlayingData => widget.nowPlayingData;

  @override
  void initState() {
    super.initState();
    _lastVideoId = _nowPlayingData.videoId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentVideoId = widget.nowPlayingData.videoId;
    if (currentVideoId != _lastVideoId) {
      _hasRequestedPlay = false;
      _lastVideoId = currentVideoId;
    }
  }

  @override
  void didUpdateWidget(PlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nowPlayingData.videoId != widget.nowPlayingData.videoId) {
      _hasRequestedPlay = false;
      _lastVideoId = widget.nowPlayingData.videoId;
    }
  }

  void _requestPlayIfNeeded(PlayerBlocBloc bloc, PlayerBlocState state) {
    if (_hasRequestedPlay) return;
    if (_nowPlayingData.videoId != _lastVideoId) return;

    final hasValidUrl =
        _nowPlayingData.streamUrl != null &&
        _nowPlayingData.streamUrl!.isNotEmpty;
    if (!hasValidUrl) return;

    final isCurrentSong =
        state.currentTrack?.videoId == _nowPlayingData.videoId;
    final isAlreadyPlaying = isCurrentSong && state.isPlaying;

    if (isAlreadyPlaying) return;

    _hasRequestedPlay = true;

    if (widget.playAsSingle) {
      bloc.add(
        LoadTrackEvent(
          _nowPlayingData,
          sourceId: 'single:${_nowPlayingData.videoId}',
        ),
      );
    } else {
      bloc.add(PlayRequestEvent(_nowPlayingData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        right: false,
        left: false,
        child: BlocConsumer<PlayerBlocBloc, PlayerBlocState>(
          listener: (context, state) {
            _requestPlayIfNeeded(context.read<PlayerBlocBloc>(), state);
          },
          builder: (context, state) {
            return PlayerContentBuilderWidget(
              nowPlayingData: _nowPlayingData,
              state: state,
              playAsSingle: widget.playAsSingle,
              showFavoriteButton: widget.showFavoriteButton,
              showExtras: widget.showExtras,
            );
          },
        ),
      ),
    );
  }
}
