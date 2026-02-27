import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/presentation/widgets/mini_player.dart';
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
    final navItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.search, 'label': 'Search'},
      {'icon': Icons.library_music, 'label': 'Library'},
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
            // Solo rebuild cuando cambia si hay una canción cargada
            final prevHasTrack = previous is PlayerBlocLoaded && previous.currentTrack != null;
            final currHasTrack = current is PlayerBlocLoaded && current.currentTrack != null;
            return prevHasTrack != currHasTrack;
          },
          builder: (context, playerState) {
            final hasTrack = playerState is PlayerBlocLoaded && playerState.currentTrack != null;
            
            return Scaffold(
              backgroundColor: AppColorsDark.surface,
              body: Stack(
                children: [
                  child,
                  // Mini Player (encima del contenido, debajo del navbar)
                  if (isVisible && hasTrack)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 79 + 32 + 8, // Altura navbar + margen + padding extra
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
