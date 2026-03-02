import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:music_app/features/search/presentation/cubit/orquestador_search_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/recent_searches_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:music_app/main.dart';

@RoutePage()
class SearchShell extends StatelessWidget implements AutoRouteWrapper {
  const SearchShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(
          create: (context) =>
              SearchCubit(searchUseCase: getIt<SearchUseCase>()),
        ),
        BlocProvider<RecentSearchesCubit>(
          create: (context) => RecentSearchesCubit(
            getRecentSearchesUseCase: getIt<GetRecentSearchesUseCase>(),
          ),
        ),
        BlocProvider<OrquestadorSearchCubit>(
          create: (context) {
            final searchCubit = context.read<SearchCubit>();
            final recentSearchesCubit = context.read<RecentSearchesCubit>();
            return OrquestadorSearchCubit(
              searchCubit: searchCubit,
              recentSearchesCubit: recentSearchesCubit,
            );
          },
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
