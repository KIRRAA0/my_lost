import 'package:flutter/material.dart';
import '../../../core/Utils/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Header with curved bottom
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 20.0 : 24.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings items
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    _buildSettingCategory('Account', context),
                    _buildSettingItem(Icons.person, 'Account Information', context),
                    _buildSettingItem(Icons.notifications, 'Notifications', context),
                    _buildSettingItem(Icons.lock, 'Privacy and Security', context),

                    SizedBox(height: screenHeight * 0.02),
                    _buildSettingCategory('Preferences', context),
                    _buildSettingItem(Icons.language, 'Language', context),
                    _buildSettingItem(Icons.dark_mode, 'Theme', context),
                    _buildSettingItem(Icons.font_download, 'Font Size', context),

                    SizedBox(height: screenHeight * 0.02),
                    _buildSettingCategory('Support', context),
                    _buildSettingItem(Icons.help, 'Help & Support', context),
                    _buildSettingItem(Icons.policy, 'Terms and Conditions', context),
                    _buildSettingItem(Icons.info, 'About', context),

                    // Version info at bottom
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.04,
                        bottom: screenHeight * 0.02,
                      ),
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCategory(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.05),
            blurRadius: 5.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primaryColor,
        ),
        onTap: () {
          // Handle tap
        },
      ),
    );
  }
}