import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';

@RoutePage()
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColorsDark.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColorsDark.primary,
                    size: 24,
                  ),
                ),
                onPressed: () {
                  context.router.push(const ProfileRoute());
                },
              ),
              title: const Text(
                'Your Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Recently Played section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recently Played',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See more',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recently Played horizontal list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          context.router.push(
                            PlayerRoute(
                              nowPlayingData: NowPlayingData.fromBasic(
                                videoId: 'inside_out',
                                title: 'Inside Out',
                                artistNames: ['The Chainsmokers', 'Charlee'],
                                albumName: 'Sick Boy',
                                duration: '3:15',
                                durationSeconds: 195,
                              ),
                            ),
                          );
                        } else {
                          // context.router.push( PlaylistRoute());
                        }
                      },
                      child: _LibraryCard(
                        title: index == 0 ? 'Inside Out' : 'Playlist ${index}',
                        subtitle: index == 0
                            ? 'The Chainsmokers, Charlee'
                            : 'Artist ${index}',
                      ),
                    );
                  },
                ),
              ),
            ),

            // Songs list
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final songs = [
                  {'title': 'Beach House', 'artist': 'The Chainsmokers'},
                  {'title': 'Sick Boy', 'artist': 'The Chainsmokers'},
                  {'title': 'Young', 'artist': 'The Chainsmokers'},
                  {'title': 'Kills You Slowly', 'artist': 'The Chainsmokers'},
                  {'title': 'World', 'artist': 'The Chainsmokers'},
                  {
                    'title': 'Setting Fires',
                    'artist': 'The Chainsmokers, XYLO',
                  },
                  {'title': 'Somebody', 'artist': 'The Chainsmokers, Drew'},
                ];
                final song = songs[index % songs.length];
                return GestureDetector(
                  onTap: () {
                    context.router.push(
                      PlayerRoute(
                        nowPlayingData: NowPlayingData.fromBasic(
                          videoId: 'library_song_${index}',
                          title: song['title']!,
                          artistNames: song['artist']!.split(', '),
                          albumName: 'Album',
                          duration: '3:30',
                          durationSeconds: 210,
                        ),
                      ),
                    );
                  },
                  child: _LibrarySongItem(
                    title: song['title']!,
                    artist: song['artist']!,
                  ),
                );
              }, childCount: 10),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LibraryCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColorsDark.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.playlist_play,
                  size: 60,
                  color: AppColorsDark.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarySongItem extends StatelessWidget {
  final String title;
  final String artist;

  const _LibrarySongItem({required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColorsDark.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.music_note, color: AppColorsDark.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.6)),
        onPressed: () {},
      ),
    );
  }
}
