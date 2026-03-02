import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/search/presentation/cubit/orquestador_search_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/recent_searches_cubit.dart';
import '../cubit/search_cubit.dart' show SearchCubit, SearchState;

/// Widget que escucha los cambios del SearchCubit, RecentSearchesCubit y OrquestadorSearchCubit
/// Maneja las actualizaciones de estado
class SearchListeners extends StatelessWidget {
  final Widget child;

  const SearchListeners({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener para actualizar el estado de búsqueda en el orquestador
        BlocListener<SearchCubit, SearchState>(
          listener: (context, state) {
            final orquestador = context.read<OrquestadorSearchCubit>();
            orquestador.updateSearchState(state);
          },
        ),
        // Listener para actualizar el estado de búsquedas recientes en el orquestador
        BlocListener<RecentSearchesCubit, RecentSearchesState>(
          listener: (context, state) {
            final orquestador = context.read<OrquestadorSearchCubit>();
            orquestador.updateRecentSearchesState(state);
          },
        ),
        // Listener para efectos del orquestador
        BlocListener<OrquestadorSearchCubit, OrquestadorSearchState>(
          listener: (context, state) {
            final effect = state.effect;
            if (effect == null) return;

            if (effect is ShowErrorEffect) {
              context.read<OrquestadorSearchCubit>().clearEffect();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(effect.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: child,
    );
  }
}
