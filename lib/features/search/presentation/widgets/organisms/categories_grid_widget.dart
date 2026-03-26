import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/home/presentation/widgets/molecules/mood_genre_card_widget.dart';
import 'package:music_app/features/search/domain/use_cases/get_categories_usecase.dart';
import 'package:music_app/features/search/presentation/cubit/categories_cubit.dart';
import 'package:music_app/main.dart';

/// Widget para mostrar el grid de categorías (moods/genres) en la pantalla de búsqueda
class CategoriesGridWidget extends StatelessWidget {
  const CategoriesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriesCubit(getIt<GetCategoriesUseCase>())..loadCategories(),
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          // Si está cargando, mostrar shimmer o loading
          if (state.status == CategoriesStatus.loading) {
            return _buildLoadingGrid();
          }

          // Si hay error o no hay categorías, no mostrar nada
          if (state.status == CategoriesStatus.failure ||
              state.categories.isEmpty) {
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
                    color: AppColorsDark.onSurface,
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
                  itemCount: state.categories.length > 8
                      ? 8
                      : state.categories.length,
                  itemBuilder: (context, index) {
                    return MoodGenreCardWidget(
                      moodGenre: state.categories[index],
                    );
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
              color: AppColorsDark.onSurface,
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
                  color: AppColorsDark.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColorsDark.onSurface.withValues(alpha: 0.2),
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
