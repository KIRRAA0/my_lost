import 'package:flutter/material.dart';

import '../../../core/Utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isButtonEnabled;

  const CustomButton({
    required this.onPressed,
    required this.text,
    required this.isButtonEnabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate responsive font size based on screen dimensions
    final fontSize = screenWidth * 0.045; // Match intro screen button font size

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            height: 56, // Match intro screen button height
            decoration: BoxDecoration(
              gradient: isButtonEnabled
                  ? LinearGradient(
                      colors: isDarkMode 
                          ? [AppColors.darkPrimaryColor, AppColors.darkSecondaryColor]
                          : [AppColors.lightPrimaryColor, AppColors.lightSecondaryColor],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade500],
                    ),
              borderRadius: BorderRadius.circular(28), // Match intro screen button radius
              boxShadow: isButtonEnabled
                  ? [
                      BoxShadow(
                        color: (isDarkMode ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: isButtonEnabled ? onPressed : null,
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600, // Match intro screen button font weight
                  letterSpacing: 0.5, // Match intro screen button letter spacing
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}