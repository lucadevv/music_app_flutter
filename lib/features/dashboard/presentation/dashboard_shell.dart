import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/presentation/widgets/mini_player.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class DashboardShell extends StatefulWidget implements AutoRouteWrapper {
  const DashboardShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    // Aquí se pueden agregar BlocProviders si es necesario
    return this;
  }

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _init();
    });
    
    // Listen to bottom sheet visibility changes
    BottomSheetVisibility().addListener(_onBottomSheetChanged);
  }

  @override
  void dispose() {
    BottomSheetVisibility().removeListener(_onBottomSheetChanged);
    super.dispose();
  }

  void _onBottomSheetChanged() {
    if (mounted) {
      setState(() {}); // Rebuild to update miniplayer position
    }
  }

  Future<void> _init() async {
    final manager = getIt<AuthManager>();
    final accessTokem = await manager.getCurrentAccessToken();
    final refreshTokem = await manager.getCurrentRefreshToken();
    debugPrint("accessToken: $accessTokem");
    debugPrint("refreshToken: $refreshTokem");
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navItems = [
      {'icon': Icons.home, 'label': l10n.home},
      {'icon': Icons.search, 'label': l10n.search},
      {'icon': Icons.library_music, 'label': l10n.library},
    ];
    final visibleRoutes = [
      '/dashboard/home',
      '/dashboard/search',
      '/dashboard/library',
    ];

    // Obtener la ruta actual
    final currentPath = context.router.currentPath;
    final isEmailVerificationRoute = currentPath.contains('email-verification');
    print("current page: $currentPath");
    // Si estamos en la ruta de verificación de email, mostrar solo el AutoRouter sin tabs
    if (isEmailVerificationRoute) {
      return Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: const AutoRouter(),
      );
    }
    return AutoTabsRouter.pageView(
      physics: const NeverScrollableScrollPhysics(),
      routes: const [HomeShell(), SearchShell(), LibraryShell()],
      builder: (context, child, _) {
        final tabsRouter = AutoTabsRouter.of(context);
        final tabsPath = tabsRouter.currentPath;
        final isVisible = visibleRoutes.contains(tabsPath);

        return BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
          bloc: getIt<PlayerBlocBloc>(),
          buildWhen: (previous, current) {
            // Rebuild cuando cambia la canción actual O la presencia de canción
            // IMPORTANTE: Necesitamos rebuild en cada cambio para que el MiniPlayer se actualice
            if (previous is PlayerBlocLoaded && current is PlayerBlocLoaded) {
              return previous.currentTrack?.videoId != current.currentTrack?.videoId ||
                  previous.playbackState != current.playbackState ||
                  previous.position != current.position ||
                  previous.duration != current.duration;
            }
            // También rebuild cuando cambia el estado (ej: de Initial a Loaded)
            return true;
          },
          builder: (context, playerState) {
            final hasTrack = playerState is PlayerBlocLoaded && playerState.currentTrack != null;
            final isBottomSheetOpen = BottomSheetVisibility().isBottomSheetOpen;
            
            // Posición del miniplayer:
            // - Normal: 119
            // - Con bottom sheet abierto: 512 (para que no tape el bottom sheet)
            final miniPlayerBottom = isBottomSheetOpen ? 512 : 119;
            
            return Scaffold(
              backgroundColor: AppColorsDark.surface,
              body: Stack(
                children: [
                  child,
                  // Mini Player con animación suave
                  if (isVisible && hasTrack)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: 0,
                      right: 0,
                      bottom: miniPlayerBottom.toDouble(),
                      child: const MiniPlayer(),
                    ),
                  // Navbar
                  if (isVisible) ...[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 79,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 30,
                        ).copyWith(bottom: 32),
                        decoration: BoxDecoration(
                          color: AppColorsDark.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ItemNavbar(
                                icon: navItems[0]['icon'] as IconData,
                                label: navItems[0]['label'] as String,
                                isActive: tabsRouter.activeIndex == 0,
                                onTap: () => tabsRouter.setActiveIndex(0),
                              ),
                              _ItemNavbar(
                                icon: navItems[1]['icon'] as IconData,
                                label: navItems[1]['label'] as String,
                                isActive: tabsRouter.activeIndex == 1,
                                onTap: () => tabsRouter.setActiveIndex(1),
                              ),
                              _ItemNavbar(
                                icon: navItems[2]['icon'] as IconData,
                                label: navItems[2]['label'] as String,
                                isActive: tabsRouter.activeIndex == 2,
                                onTap: () => tabsRouter.setActiveIndex(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ItemNavbar extends StatelessWidget {
  const _ItemNavbar({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive
                ? AppColorsDark.primary
                : AppColorsDark.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? AppColorsDark.primary
                  : AppColorsDark.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
