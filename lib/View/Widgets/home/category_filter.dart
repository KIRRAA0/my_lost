import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../data/Models/lost_item_model.dart';
import '../../../logic/cubits/home/home_cubit.dart';
import '../../../logic/cubits/home/home_state.dart';

class CategoryFilter extends StatelessWidget {
  final Function(LostItem)? onMarkerTap;
  
  const CategoryFilter({super.key, this.onMarkerTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final selectedCategory = state is HomeLoaded ? state.selectedCategory : 'All';
        
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: HomeCubit.categories.length,
            itemBuilder: (context, index) {
              final category = HomeCubit.categories[index];
              final isSelected = category == selectedCategory;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.read<HomeCubit>().filterByCategory(category, onMarkerTap: onMarkerTap),
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.lightPrimaryColor,
                                    AppColors.lightPrimaryColor.withValues(alpha: 0.8),
                                  ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : isDarkMode
                                  ? AppColors.darkSurfaceColor.withValues(alpha: 0.95)
                                  : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : isDarkMode
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.lightPrimaryColor.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: isSelected ? 8 : 4,
                              offset: Offset(0, isSelected ? 4 : 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isDarkMode
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
