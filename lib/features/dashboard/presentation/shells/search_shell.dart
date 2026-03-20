import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/update_selected_song_use_case.dart';
import 'package:music_app/features/search/presentation/cubit/orquestador_search_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/recent_searches_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/search_cubit.dart';

@RoutePage()
class SearchShell extends StatelessWidget implements AutoRouteWrapper {
  const SearchShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    // Use cases son dependencias no-reactivas, usamos GetIt
    // Los blocs se crean aquí con BlocProvider
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(
          create: (_) => SearchCubit(searchUseCase: GetIt.I<SearchUseCase>()),
        ),
        BlocProvider<RecentSearchesCubit>(
          create: (_) => RecentSearchesCubit(
            getRecentSearchesUseCase: GetIt.I<GetRecentSearchesUseCase>(),
          ),
        ),
        BlocProvider<OrquestadorSearchCubit>(
          create: (context) => OrquestadorSearchCubit(
            searchCubit: context.read<SearchCubit>(),
            recentSearchesCubit: context.read<RecentSearchesCubit>(),
            updateSelectedSongUseCase: GetIt.I<UpdateSelectedSongUseCase>(),
          ),
        ),
      ],
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
