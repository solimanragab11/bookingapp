import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/widgets/category_card.dart';

class CategoryList extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryList({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'All', 'icon': Icons.all_inclusive, 'id': 'all'},
      {'name': 'Football', 'icon': Icons.sports_soccer, 'id': 'football'},
      {'name': 'Padel', 'icon': Icons.sports_tennis, 'id': 'padel'},
      {'name': 'PS', 'icon': Icons.sports_esports, 'id': 'playstation'},
      {'name': 'Cafe', 'icon': Icons.local_cafe, 'id': 'cafe'},
    ];

    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final String catId = category['id'] as String;
          final IconData icon = category['icon'] as IconData;
          final bool isSelected = selectedCategory == catId;

          return CategoryCard(
            categoryId: catId,
            icon: icon,
            isSelected: isSelected,
            onTap: () {
              onCategoryChanged(catId);
              context.read<HomeCubit>().getPlacesByCat(catId);
            },
          );
        },
      ),
    );
  }
}
