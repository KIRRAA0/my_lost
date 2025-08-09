import 'package:flutter/material.dart';
import '../../Widgets/profile/action_buttons.dart';
import '../../Widgets/profile/info_section.dart';
import '../../Widgets/profile/profile_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Header with curved bottom
            const ProfileHeader(),

            // Profile information
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attendance Statistics Section
                    ProfileInfoSection(
                      title: 'Session Attendance',
                      icon: Icons.event_seat,
                      rows: [
                        InfoRowData(
                          label: 'Total Sessions',
                          value: '17 Sessions',
                          icon: Icons.calendar_view_day,
                        ),
                        InfoRowData(
                          label: 'Attended as Principal',
                          value: '10 Sessions',
                          icon: Icons.person,
                        ),
                        InfoRowData(
                          label: 'Attended as Deputy',
                          value: '7 Sessions',
                          icon: Icons.people,
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Administrative Work Section
                    ProfileInfoSection(
                      title: 'Administrative Work',
                      icon: Icons.work,
                      rows: [
                        InfoRowData(
                          label: 'Administrative Tasks',
                          value: '17 Tasks',
                          icon: Icons.assignment,
                        ),
                        InfoRowData(
                          label: 'Expert Sessions Attended',
                          value: '17 Sessions',
                          icon: Icons.psychology,
                        ),
                        InfoRowData(
                          label: 'Investigation Sessions Attended',
                          value: '17 Sessions',
                          icon: Icons.find_in_page,
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Action buttons
                    const ActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}