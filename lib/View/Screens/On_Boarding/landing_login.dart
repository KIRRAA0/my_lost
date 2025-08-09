import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Utils/app_colors.dart';
import '../../Widgets/Common/custom_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      AppColors.darkBackgroundColor,
                      AppColors.darkSurfaceColor,
                      AppColors.darkCardColor,
                    ]
                  : [
                      AppColors.lightBackgroundColor,
                      AppColors.lightSurfaceColor,
                      Colors.white,
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Icon(
                        Icons.account_circle,
                        size: 32,
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
                
                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Welcome Content
                        Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.25),
                            border: Border.all(
                              color: isDarkMode 
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode 
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/Logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        Text(
                          'My Lost',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Never lose anything again - find your lost items easily',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Features List
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? AppColors.darkSurfaceColor.withOpacity(0.5)
                                : AppColors.lightSurfaceColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode 
                                  ? AppColors.darkPrimaryColor.withOpacity(0.3)
                                  : AppColors.lightPrimaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'App Features',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildFeatureItem(
                                icon: Icons.search,
                                title: 'Smart Search',
                                subtitle: 'Find your lost items quickly',
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                icon: Icons.location_on,
                                title: 'Location Tracking',
                                subtitle: 'Track where you lost items',
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                icon: Icons.category,
                                title: 'Categorization',
                                subtitle: 'Organize items by categories',
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle: 'Get alerted about found items',
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child:                         CustomButton(
                          text: 'Get Started',
                          isButtonEnabled: true,
                          onPressed: () {
                            context.go('/home');
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.go('/home');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? AppColors.darkPrimaryColor.withOpacity(0.2)
                : AppColors.lightPrimaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}