import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../logic/cubits/home/home_cubit.dart';
import '../../../logic/cubits/home/home_state.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isSearchExpanded = state is HomeLoaded ? state.isSearchExpanded : false;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppColors.darkSurfaceColor,
                      AppColors.darkCardColor.withValues(alpha: 0.95),
                    ]
                  : [
                      AppColors.lightSurfaceColor,
                      Colors.white.withValues(alpha: 0.95),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Main header row
                  Row(
                    children: [
                      // Enhanced logo container
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.lightPrimaryColor,
                                AppColors.lightPrimaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/Logo.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Enhanced title section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'My Lost',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'BETA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightPrimaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Reconnect with your belongings',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Enhanced action buttons
                      Row(
                        children: [
                          _buildHeaderActionButton(
                            icon: isSearchExpanded ? Icons.close : Icons.search_rounded,
                            onTap: () => context.read<HomeCubit>().toggleSearch(),
                            isDarkMode: isDarkMode,
                            isActive: isSearchExpanded,
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderActionButton(
                            icon: Icons.notifications_rounded,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Notifications feature coming soon!'),
                                  backgroundColor: AppColors.lightPrimaryColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            isDarkMode: isDarkMode,
                            showNotificationBadge: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Animated search bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isSearchExpanded ? 56 : 0,
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isSearchExpanded ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildSearchBar(isDarkMode),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isActive = false,
    bool showNotificationBadge = false,
  }) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive
                    ? AppColors.lightPrimaryColor.withValues(alpha: 0.1)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04)),
                border: Border.all(
                  color: isActive
                      ? AppColors.lightPrimaryColor.withValues(alpha: 0.3)
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08)),
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? AppColors.lightPrimaryColor
                    : (isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ),
        ),
        if (showNotificationBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkCardColor.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Builder(
        builder: (context) => TextField(
          decoration: InputDecoration(
            hintText: 'Search lost items...',
            hintStyle: TextStyle(
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.lightPrimaryColor,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 14,
          ),
          onChanged: (value) {
            context.read<HomeCubit>().searchItems(value);
          },
        ),
      ),
    );
  }
}
