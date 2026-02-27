import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/bloc/locale_cubit.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/theme/theme_cubit.dart';
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
    super.dispose();
  }

  Future<void> _initApp() async {
    try {
      _themeCubit = await getIt.getAsync<ThemeCubit>();
      _localeCubit = await getIt.getAsync<LocaleCubit>();
      debugPrint('App._initApp: App inicializada correctamente');
    } catch (e) {
      debugPrint('App._initApp: Error inicializando app: $e');
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
    if (!_isInitialized || _themeCubit == null || _localeCubit == null) {
      return MaterialApp(
        title: 'Music App',
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: const CircularProgressIndicator(),
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
