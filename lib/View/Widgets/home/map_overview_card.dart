import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../logic/cubits/home/home_cubit.dart';
import '../../../logic/cubits/home/home_state.dart';

class MapOverviewCard extends StatelessWidget {
  const MapOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(16), // Reduced from 24
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppColors.darkSurfaceColor.withValues(alpha: 0.98),
                      AppColors.darkCardColor.withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.98),
                      AppColors.lightSurfaceColor.withValues(alpha: 0.95),
                    ],
            ),
            borderRadius: BorderRadius.circular(20), // Reduced from 24
            border: Border.all(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.lightPrimaryColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 24, // Reduced from 32
                offset: const Offset(0, 12), // Reduced from 16
                spreadRadius: -4,
              ),
              BoxShadow(
                color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                blurRadius: 6, // Reduced from 8
                offset: const Offset(0, 3), // Reduced from 4
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced header with gradient icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced from 10
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.lightPrimaryColor,
                          AppColors.lightPrimaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10), // Reduced from 12
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 6, // Reduced from 8
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 18, // Reduced from 20
                    ),
                  ),
                  const SizedBox(width: 10), // Reduced from 12
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 16, // Reduced from 18
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Live statistics',
                          style: TextStyle(
                            fontSize: 11, // Reduced from 12
                            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live indicator - made smaller
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10), // Reduced from 12
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5, // Reduced from 6
                          height: 5, // Reduced from 6
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3), // Reduced from 4
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 9, // Reduced from 10
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14), // Reduced from 20
              // Enhanced stats row - made more compact
              Row(
                children: [
                  _buildCompactStatItem(
                    'Items', 
                    '${state.allItems.length}', 
                    Icons.inventory_2_rounded, 
                    Colors.blue,
                    isDarkMode,
                  ),
                  const SizedBox(width: 12), // Reduced from 16
                  _buildCompactStatItem(
                    'Categories', 
                    '${HomeCubit.categories.length - 1}', 
                    Icons.category_rounded, 
                    Colors.purple,
                    isDarkMode,
                  ),
                  const SizedBox(width: 12), // Reduced from 16
                  _buildCompactStatItem(
                    'Recent', 
                    '3', 
                    Icons.schedule_rounded, 
                    Colors.orange,
                    isDarkMode,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactStatItem(
    String label, 
    String value, 
    IconData icon, 
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced from 16
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14), // Reduced from 16
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6), // Reduced from 8
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10), // Reduced from 12
              ),
              child: Icon(
                icon,
                size: 18, // Reduced from 20
                color: color,
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
            Text(
              value,
              style: TextStyle(
                fontSize: 18, // Reduced from 20
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2), // Reduced from 4
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Reduced from 11
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
