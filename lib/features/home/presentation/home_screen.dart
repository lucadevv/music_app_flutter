import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/home/domain/entities/chart_song.dart';
import 'package:music_app/features/home/domain/entities/home_content_item.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart'
    show HomeCubit, HomeStatus;
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import 'package:music_app/features/home/presentation/widgets/home_error_widget.dart';
import 'package:music_app/features/home/presentation/widgets/home_header_widget.dart';
import 'package:music_app/features/home/presentation/widgets/home_listeners.dart';
import 'package:music_app/features/home/presentation/widgets/home_loading_widget.dart';
import 'package:music_app/features/home/presentation/widgets/home_section_widget.dart';
import 'package:music_app/features/home/presentation/widgets/mood_genres_grid_widget.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';
import 'package:music_app/main.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del home al iniciar (no resetear para mantener el estado)
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return HomeListeners(
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OrquestadorHomeCubit, OrquestadorHomeState>(
            builder: (context, orquestadorState) {
              final state = orquestadorState.homeState;

              // Mostrar shimmer cuando está cargando o en estado inicial
              if (state.status == HomeStatus.loading ||
                  state.status == HomeStatus.initial) {
                return const HomeLoadingWidget();
              }

              if (state.status == HomeStatus.failure) {
                return HomeErrorWidget(errorMessage: state.errorMessage);
              }

              final homeResponse = state.homeResponse;
              if (homeResponse == null) {
                return const SizedBox.shrink();
              }

              // Debug: Ver qué datos tenemos
              debugPrint('HomeScreen: moods: ${homeResponse.moods.length}, genres: ${homeResponse.genres.length}, sections: ${homeResponse.sections.length}');

              return CustomScrollView(
                slivers: [
                  // Header con saludo
                  const SliverToBoxAdapter(child: HomeHeaderWidget()),

                  // Secciones de contenido (tendencias, etc.) - igual que en el shimmer
                  ...homeResponse.sections.map(
                    (section) => SliverToBoxAdapter(
                      child: HomeSectionWidget(
                        section: section,
                        onSongTap: _playSong,
                        onPlaylistTap: (item) {
                          // Navegar a la playlist si tiene ID
                          if (item.playlistId != null && item.playlistId!.isNotEmpty) {
                            context.router.push(PlaylistRoute(id: item.playlistId!));
                          }
                        },
                      ),
                    ),
                  ),

                  // GridView de categorías (moods y genres combinados) - al final como en el shimmer
                  MoodGenresGridWidget(
                    moods: homeResponse.moods,
                    genres: homeResponse.genres,
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Reproduce una canción usando el PlayerBlocBloc
  void _playSong(HomeContentItem item) {
    if (item.videoId == null || item.videoId!.isEmpty) return;

    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: item.videoId!,
      title: item.title,
      artistNames: item.artists.map((a) => a.name).toList(),
      albumName: item.album?.name ?? '',
      albumId: item.album?.id,
      duration: '0:00',
      views: item.views,
      isExplicit: item.isExplicit,
      thumbnails: item.thumbnails, // Usar thumbnails con dimensiones reales
      thumbnail: item.thumbnail, // Usar thumbnail de mejor calidad con dimensiones reales
      streamUrl: item.streamUrl, // Usar stream_url directamente
    );

    // Cargar y reproducir la canción
    getIt<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));

    // Navegar al reproductor
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }

  /// Reproduce una canción de chart usando el PlayerBlocBloc
  void _playChartSong(ChartSong song) {
    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [song.artist],
      albumName: '',
      duration: '0:00',
      thumbnailUrl: song.thumbnail, // Usar thumbnail de mejor calidad (URL string)
      thumbnail: song.thumbnail.isNotEmpty
          ? Thumbnail(url: song.thumbnail, width: 544, height: 544) // Crear Thumbnail con dimensiones de mejor calidad
          : null,
      streamUrl: song.streamUrl, // Usar stream_url directamente
    );

    // Cargar y reproducir la canción
    getIt<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));

    // Navegar al reproductor
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }
}

/// Widget para mostrar una canción de chart
class _ChartSongCard extends StatelessWidget {
  final ChartSong song;
  final VoidCallback onTap;

  const _ChartSongCard({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: song.thumbnail,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 160,
                  height: 160,
                  color: AppColorsDark.primaryContainer,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 160,
                  height: 160,
                  color: AppColorsDark.primaryContainer,
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Expanded(
              child: Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Artist
            Expanded(
              child: Text(
                song.artist,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
