import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/Utils/app_colors.dart';

class CategorySelectionWidget extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Map<String, IconData> categoryIcons;
  final Function(String?) onCategoryChanged;
  final bool isDarkMode;

  const CategorySelectionWidget({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.categoryIcons,
    required this.onCategoryChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
            ),
            color: isDarkMode ? Colors.grey[850] : Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              icon: Icon(
                Iconsax.arrow_down_1,
                color: AppColors.lightPrimaryColor,
              ),
              onChanged: onCategoryChanged,
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        categoryIcons[value],
                        size: 20,
                        color: AppColors.lightPrimaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}