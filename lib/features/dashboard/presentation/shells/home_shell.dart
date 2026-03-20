import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import 'package:music_app/features/player/domain/player_facade.dart';

@RoutePage()
class HomeShell extends StatelessWidget implements AutoRouteWrapper {
  const HomeShell({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    // GetHomeUseCase y PlayerFacade son dependencias no-reactivas, usamos GetIt
    // HomeCubit y OrquestadorHomeCubit se crean aquí con BlocProvider
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) =>
              HomeCubit(GetIt.I<GetHomeUseCase>(), GetIt.I<PlayerFacade>()),
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
