import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import 'package:music_app/main.dart';

@RoutePage()
class HomeShell extends StatelessWidget implements AutoRouteWrapper {
  const HomeShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(getIt<GetHomeUseCase>(), getIt<PlayerBlocBloc>()),
        ),
        BlocProvider<OrquestadorHomeCubit>(
          create: (context) {
            final homeCubit = context.read<HomeCubit>();
            return OrquestadorHomeCubit(homeCubit: homeCubit);
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
