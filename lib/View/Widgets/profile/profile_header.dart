
import 'package:flutter/material.dart';
import '../../../../core/Utils/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Container(
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
        child: Column(
          children: [
            // Header top row with back button and title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 22.0 : 26.0, // Increased size
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 26), // Increased size
                  onPressed: () {
                    print("object");
                  },
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // Profile avatar and name
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 45, // Increased size
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Name text with increased font size
            const Text(
              'Dr. Abdullah Yazid Saad Al-Azmi',
              style: TextStyle(
                fontSize: 22, // Increased from 20
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.005),

            // Profession row with increased font size
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.gavel,
                  color: Colors.white70,
                  size: 18, // Increased from 16
                ),
                const SizedBox(width: 6),
                Text(
                  'Attorney',
                  style: TextStyle(
                    fontSize: 16, // Increased from 14
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.01),

            // License information with increased font size
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Slightly increased padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                'License: 8973 Constitutional & Excellence',
                style: TextStyle(
                  fontSize: 14, // Increased from 12
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // My Work Button with increased font size
            ElevatedButton.icon(
              icon: const Icon(Icons.work, size: 22), // Increased from 20
              label: const Text(
                'My Work',
                style: TextStyle(
                  fontSize: 16, // Increased font size
                ),
              ),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), // Increased padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}