import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';

@RoutePage()
class PlayerScreen extends StatefulWidget {
  final NowPlayingData nowPlayingData;

  const PlayerScreen({required this.nowPlayingData, super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();

    // Check if user has showLyrics enabled in settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>();
      if (mounted) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PlayerBlocBloc>();
      final state = bloc.state;

      // Si la canción actual ya es la que se quiere reproducir,
      // solo reanudar si está pausada
      if (state is PlayerBlocLoaded &&
          state.currentTrack?.videoId == widget.nowPlayingData.videoId) {
        // Si está pausada, reproducir
        if (state.isPaused || state.isStopped) {
          bloc.add(const PlayEvent());
        }
        return;
      }

      // Verificar si la canción está en la playlist cargada
      if (state is PlayerBlocLoaded && state.playlist.isNotEmpty) {
        final trackIndex = state.playlist.indexWhere(
          (track) => track.videoId == widget.nowPlayingData.videoId,
        );

        // Si la canción está en la playlist cargada, solo cambiar el índice
        if (trackIndex >= 0) {
          bloc.add(PlayTrackAtIndexEvent(trackIndex));
          return;
        }
      }

      // Si la canción no está en la playlist cargada, cargar solo esa canción
      bloc.add(LoadTrackEvent(widget.nowPlayingData));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(child: Text('Player screen')),
    );
  }
}
