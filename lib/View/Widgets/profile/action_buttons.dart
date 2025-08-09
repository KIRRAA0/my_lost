import 'package:flutter/material.dart';
import '../../../../core/Utils/app_colors.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Session Count Summary Card
        Container(
          padding: const EdgeInsets.all(18), // Increased from 16
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  fontSize: 18, // Increased from 16
                ),
              ),
              const SizedBox(height: 14), // Increased from 12
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactStat('Total', '17', Icons.calendar_month),
                  _buildCompactStat('Principal', '10', Icons.person),
                  _buildCompactStat('Deputy', '7', Icons.people_outline),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24), // Increased from 20

        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today, size: 22), // Increased size
          label: const Text(
            'Schedule New Session',
            style: TextStyle(fontSize: 16), // Increased size
          ),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14), // Increased from 12
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
        const SizedBox(height: 14), // Increased from 12
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, size: 22), // Increased size
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 16), // Increased size
          ),
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: BorderSide(color: AppColors.primaryColor),
            padding: const EdgeInsets.symmetric(vertical: 14), // Increased from 12
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 24), // Increased from 20
      ],
    );
  }

  Widget _buildCompactStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12), // Increased from 10
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 26, // Increased from 22
          ),
        ),
        const SizedBox(height: 10), // Increased from 8
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Increased from 16
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14, // Increased from 12
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}