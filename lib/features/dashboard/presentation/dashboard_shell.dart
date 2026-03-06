import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/presentation/widgets/mini_player.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/core/widgets/glass_bottom_nav.dart';

@RoutePage()
class DashboardShell extends StatefulWidget implements AutoRouteWrapper {
  const DashboardShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create:(context) => PlayerBlocBloc(),)
    ], child: this);
  }

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  @override
  void initState() {
    super.initState();
    
    BottomSheetVisibility().addListener(_onBottomSheetChanged);
  }

  @override
  void dispose() {
    BottomSheetVisibility().removeListener(_onBottomSheetChanged);
    super.dispose();
  }

  void _onBottomSheetChanged() {
    if (mounted) {
      setState(() {}); 
    }
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

    
    final currentPath = context.router.currentPath;
    final isEmailVerificationRoute = currentPath.contains('email-verification');

    
    if (isEmailVerificationRoute) {
      return const Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: AutoRouter(),
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
         
          buildWhen: (previous, current) {
        
            return previous.currentTrack?.videoId !=
                    current.currentTrack?.videoId ||
                previous.playbackState != current.playbackState ||
                previous.position != current.position ||
                previous.duration != current.duration;
      
          },
          builder: (context, playerState) {
            final hasTrack =
                playerState.currentTrack != null;
            final isBottomSheetOpen = BottomSheetVisibility().isBottomSheetOpen;

       
            final miniPlayerBottom = isBottomSheetOpen ? 512 : 119;

            return Scaffold(
              backgroundColor: AppColorsDark.surface,
              body: Stack(
                children: [
                  child,
                  
                  if (isVisible && hasTrack)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: 0,
                      right: 0,
                      bottom: miniPlayerBottom.toDouble(),
                      child: const MiniPlayer(),
                    ),
                  
                  if (isVisible) ...[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GlassBottomNav(
                        currentIndex: tabsRouter.activeIndex,
                        onTap: (index) => tabsRouter.setActiveIndex(index),
                        outlinedIcons: const [Icons.home_outlined, Icons.search_outlined, Icons.library_music_outlined],
                        filledIcons: const [Icons.home, Icons.search, Icons.library_music],
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

// Removed _ItemNavbar class as it's replaced by GlassBottomNav
