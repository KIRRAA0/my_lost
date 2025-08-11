import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/Utils/app_colors.dart';
import '../Common/custom_text_field.dart';

class ItemDetailsFormWidget extends StatelessWidget {
  final TextEditingController itemNameController;
  final TextEditingController itemDescriptionController;
  final TextEditingController additionalInfoController;

  const ItemDetailsFormWidget({
    super.key,
    required this.itemNameController,
    required this.itemDescriptionController,
    required this.additionalInfoController,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: itemNameController,
          labelText: 'Item Name',
          hintText: 'e.g., iPhone 13, Blue Wallet',
          icon: Iconsax.tag,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the item name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: itemDescriptionController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the item in detail...',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                      AppColors.lightSecondaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.note,
                  color: AppColors.lightPrimaryColor,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.lightPrimaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppColors.darkSurfaceColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: additionalInfoController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Additional Information (Optional)',
              hintText: 'Any other details about the item...',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                      AppColors.lightSecondaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.info_circle,
                  color: AppColors.lightPrimaryColor,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.lightPrimaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppColors.darkSurfaceColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}