import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/Utils/app_colors.dart';
import '../Common/custom_text_field.dart';

class LocationSectionWidget extends StatelessWidget {
  final String currentAddress;
  final bool isLoadingLocation;
  final bool showManualLocation;
  final TextEditingController manualLocationController;
  final VoidCallback onRefreshLocation;
  final VoidCallback onToggleManualLocation;
  final bool isDarkMode;

  const LocationSectionWidget({
    super.key,
    required this.currentAddress,
    required this.isLoadingLocation,
    required this.showManualLocation,
    required this.manualLocationController,
    required this.onRefreshLocation,
    required this.onToggleManualLocation,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradientStart.withValues(alpha: 0.1),
                AppColors.gradientEnd.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lightPrimaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.location,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isLoadingLocation)
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.lightPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Detecting location...'),
                            ],
                          )
                        else
                          Text(
                            currentAddress,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.refresh),
                        onPressed: onRefreshLocation,
                        color: AppColors.lightPrimaryColor,
                        tooltip: 'Refresh location',
                      ),
                      IconButton(
                        icon: Icon(showManualLocation ? Iconsax.location : Iconsax.edit),
                        onPressed: onToggleManualLocation,
                        color: AppColors.lightPrimaryColor,
                        tooltip: showManualLocation ? 'Use GPS' : 'Enter manually',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showManualLocation) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: manualLocationController,
            labelText: 'Manual Location',
            hintText: 'Enter the location where you found the item...',
            icon: Iconsax.map,
            validator: (value) {
              if (showManualLocation && (value == null || value.isEmpty)) {
                return 'Please enter the location';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}