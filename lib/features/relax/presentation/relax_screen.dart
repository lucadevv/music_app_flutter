import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/features/relax/presentation/molecules/categories_list.dart';
import 'package:music_app/features/relax/presentation/organisms/music_cards_list.dart';
import 'package:music_app/features/relax/presentation/organisms/relax_header.dart';

@RoutePage()
class RelaxScreen extends StatelessWidget {
  const RelaxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: RelaxHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: CategoriesList(
                  selectedIndex: 0,
                  onCategorySelected: (index) {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: MusicCardsList()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
