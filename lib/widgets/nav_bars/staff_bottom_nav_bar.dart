import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/setting_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_analytics_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/attendance_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_notification_screen.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/base_bottom_nav_bar.dart';

class StaffBottomNavBar extends StatelessWidget {
  const StaffBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBottomNavBar(
      items: [
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/analytics_icon.svg",
          label: "ANALYTICS",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAnalyticsScreen()),
          ),
        ),
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/attendance_icon.svg",
          label: "ATTENDANCE",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceScreen()),
            );
          },
        ),
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/notification_icon.svg",
          label: "NOTIFICATION",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffNotificationScreen()),
          ),
        ),
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/setting_icon.svg",
          label: "SETTING",
          onTap: () => SettingScreen.show(context),
        ),
      ],
    );
  }
}
