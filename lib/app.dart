import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/bloc/locale_cubit.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/theme/theme_cubit.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/downloads/presentation/cubit/downloads_cubit.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  ThemeCubit? _themeCubit;
  LocaleCubit? _localeCubit;
  PlayerBlocBloc? _playerBlocBloc;
  DownloadsCubit? _downloadsCubit;
  ProfileCubit? _profileCubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    _themeCubit?.close();
    _localeCubit?.close();
    _playerBlocBloc?.close();
    _downloadsCubit?.close();
    _profileCubit?.close();
    super.dispose();
  }

  Future<void> _initApp() async {
    try {
      // CRITICAL: Must wait for all async singletons to be ready first
      // This ensures ThemeCubit, LocaleCubit, DownloadsCubit are fully initialized
      print('[App] Waiting for getIt.allReady()...');
      await getIt.allReady();
      print('[App] getIt.allReady() completed');
      
      // Now safe to get async singletons
      _themeCubit = await getIt.getAsync<ThemeCubit>();
      print('[App] ThemeCubit resolved: $_themeCubit');
      
      _localeCubit = await getIt.getAsync<LocaleCubit>();
      print('[App] LocaleCubit resolved: $_localeCubit');
      
      _playerBlocBloc = getIt<PlayerBlocBloc>();
      print('[App] PlayerBlocBloc resolved: $_playerBlocBloc');
      
      // DownloadsCubit es lazy singleton async
      _downloadsCubit = await getIt.getAsync<DownloadsCubit>();
      print('[App] DownloadsCubit resolved: $_downloadsCubit');
      
      // ProfileCubit es singleton registrado en AppInjection
      _profileCubit = getIt<ProfileCubit>();
      print('[App] ProfileCubit resolved: $_profileCubit');
      
      print('[App] All cubits initialized successfully');
    } catch (e, stack) {
      print('[App] ERROR in _initApp(): $e');
      print('[App] Stack trace: $stack');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _themeCubit == null || _localeCubit == null || _playerBlocBloc == null || _downloadsCubit == null || _profileCubit == null) {
      return MaterialApp(
        title: 'Music App',
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child:  CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
     
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _themeCubit!),
        BlocProvider.value(value: _localeCubit!),
        BlocProvider.value(value: _playerBlocBloc!),
        BlocProvider.value(value: _downloadsCubit!),
        BlocProvider.value(value: _profileCubit!),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
            return MaterialApp.router(
              title: 'Music App',
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.themeMode,
              routerConfig: _router.config(),
         
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: localeState.isLoading ? null : localeState.locale,
            );
            },
          );
        },
      ),
    );
  }
}

