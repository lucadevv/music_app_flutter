import 'package:auto_route/auto_route.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/app_router/guards/auth_guard.dart';
import 'package:music_app/core/app_router/guards/email_verification_guard.dart';

class PrivateRoutes {
  static List<AutoRoute> routes() => [
    AutoRoute(
      path: '/dashboard',
      guards: [AuthGuard()],
      page: DashboardShell.page,
      children: [
        // Ruta de verificación de email - SIN EmailVerificationGuard (debe ser accesible cuando email no verificado)
        // Esta será la ruta inicial cuando el email no esté verificado
        AutoRoute(
          path: 'email-verification',
          page: EmailVerificationRoute.page,
        ),
        // Rutas protegidas con EmailVerificationGuard
        AutoRoute(
          path: 'home',
          guards: [EmailVerificationGuard()],
          page: HomeShell.page,
          initial: true,
          children: [
            AutoRoute(path: '', page: HomeRoute.page),
            AutoRoute(path: 'relax', page: RelaxRoute.page),
            AutoRoute(path: 'player', page: PlayerRoute.page),
            AutoRoute(path: 'mood-genre/:params', page: MoodGenreRoute.page),
            AutoRoute(path: 'playlist/:id', page: PlaylistRoute.page),
            AutoRoute(path: 'album/:id', page: AlbumRoute.page),
            AutoRoute(path: 'artist/:id', page: ArtistRoute.page),
            AutoRoute(path: 'queue', page: QueueRoute.page),
            AutoRoute(path: 'profile', page: ProfileRoute.page),
            AutoRoute(path: 'my-profile', page: MyProfileRoute.page),
            AutoRoute(path: 'settings', page: SettingsRoute.page),
            AutoRoute(path: 'language', page: LanguageRoute.page),
            AutoRoute(
              path: 'streaming-quality',
              page: StreamingQualityRoute.page,
            ),
            AutoRoute(path: 'equalizer', page: EqualizerRoute.page),
            AutoRoute(path: 'logout', page: LogoutRoute.page),
            AutoRoute(path: 'downloads', page: DownloadsRoute.page),
          ],
        ),
        AutoRoute(
          path: 'search',
          guards: [EmailVerificationGuard()],
          page: SearchShell.page,
          children: [
            AutoRoute(path: '', page: SearchRoute.page),
            AutoRoute(path: 'mood-genre/:params', page: MoodGenreRoute.page),
            AutoRoute(path: 'artist/:id', page: ArtistRoute.page),
            AutoRoute(path: 'album/:id', page: AlbumRoute.page),
            AutoRoute(path: 'playlist/:id', page: PlaylistRoute.page),
            AutoRoute(path: 'player', page: PlayerRoute.page),
            AutoRoute(path: 'downloads', page: DownloadsRoute.page),
            AutoRoute(path: 'queue', page: QueueRoute.page),
          ],
        ),
        AutoRoute(
          path: 'library',
          guards: [EmailVerificationGuard()],
          page: LibraryShell.page,
          children: [
            AutoRoute(path: '', page: LibraryRoute.page),
            AutoRoute(path: 'playlist/:id', page: PlaylistRoute.page),
            AutoRoute(path: 'album/:id', page: AlbumRoute.page),
            AutoRoute(path: 'liked', page: LikedSongsRoute.page),
            AutoRoute(path: 'recently-played', page: RecentlyPlayedRoute.page),
            AutoRoute(path: 'user-playlists', page: UserPlaylistsRoute.page),
            AutoRoute(
              path: 'user-playlist/:id',
              page: UserPlaylistDetailRoute.page,
            ),
            AutoRoute(path: 'downloads', page: DownloadsRoute.page),
            AutoRoute(path: 'player', page: PlayerRoute.page),
            AutoRoute(path: 'profile', page: ProfileRoute.page),
            AutoRoute(path: 'my-profile', page: MyProfileRoute.page),
            AutoRoute(path: 'settings', page: SettingsRoute.page),
            AutoRoute(path: 'language', page: LanguageRoute.page),
            AutoRoute(
              path: 'streaming-quality',
              page: StreamingQualityRoute.page,
            ),
            AutoRoute(path: 'equalizer', page: EqualizerRoute.page),
            AutoRoute(path: 'logout', page: LogoutRoute.page),
            AutoRoute(path: 'queue', page: QueueRoute.page),
          ],
        ),
      ],
    ),
  ];
}
