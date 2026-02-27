import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/home/presentation/widgets/mood_genre_card_widget.dart';
import 'package:music_app/features/search/presentation/cubit/categories_cubit.dart';
import 'package:music_app/main.dart';

/// Widget para mostrar el grid de categorías (moods/genres) en la pantalla de búsqueda
class CategoriesGridWidget extends StatefulWidget {
  const CategoriesGridWidget({super.key});

  @override
  State<CategoriesGridWidget> createState() => _CategoriesGridWidgetState();
}

class _CategoriesGridWidgetState extends State<CategoriesGridWidget> {
  late final CategoriesCubit _categoriesCubit;

  @override
  void initState() {
    super.initState();
    // Crear una única instancia del cubit
    _categoriesCubit = getIt<CategoriesCubit>();
    // Cargar categorías al iniciar
    _categoriesCubit.loadCategories();
  }

  @override
  void dispose() {
    _categoriesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoriesCubit,
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          // Si está cargando, mostrar shimmer o loading
          if (state.status == CategoriesStatus.loading) {
            return _buildLoadingGrid();
          }

          // Si hay error o no hay categorías, no mostrar nada
          if (state.status == CategoriesStatus.failure || state.categories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Browse all',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: state.categories.length > 8 ? 8 : state.categories.length,
                  itemBuilder: (context, index) {
                    return MoodGenreCardWidget(moodGenre: state.categories[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Browse all',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
