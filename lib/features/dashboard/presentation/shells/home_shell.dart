import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';

@RoutePage()
class HomeShell extends StatelessWidget implements AutoRouteWrapper {
  const HomeShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (ctx) =>
              HomeCubit(GetIt.I<GetHomeUseCase>(), ctx.read<PlayerBlocBloc>()),
        ),
        BlocProvider<OrquestadorHomeCubit>(
          create: (context) =>
              OrquestadorHomeCubit(homeCubit: context.read<HomeCubit>()),
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
