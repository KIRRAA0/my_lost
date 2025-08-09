import 'package:flutter/material.dart';
import '../../../../core/Utils/app_colors.dart';

class InfoRowData {
  final String label;
  final String value;
  final IconData icon;

  InfoRowData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoRowData> rows;

  const ProfileInfoSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        _buildInfoCard(context),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12), // Increased bottom padding
      child: Row(
        children: [
          Icon(
            icon,
            size: 20, // Increased from 18
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Increased from 16
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18), // Increased from 16
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
            blurRadius: 8.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _buildInfoRow(rows[i]),
            if (i < rows.length - 1)
              Divider(
                color: AppColors.primaryColor.withOpacity(0.1),
                height: 24,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(InfoRowData data) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10), // Increased from 8
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            data.icon,
            size: 18, // Increased from 16
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 14), // Increased from 12
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 14, // Increased from 12
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 3), // Slightly increased
              Text(
                data.value,
                style: const TextStyle(
                  fontSize: 16, // Increased from 14
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}