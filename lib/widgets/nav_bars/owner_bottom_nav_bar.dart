import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/analytics_main_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/manage_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/setting_screen.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/base_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/notification_screen.dart';

class OwnerBottomNavBar extends StatelessWidget {
  const OwnerBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBottomNavBar(
      items: [
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/analytics_icon.svg",
          label: "ANALYTICS",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyticsMainScreen()),
          ),
        ),
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/manage_icon.svg",
          label: "MANAGE",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageScreen()),
          ),
        ),
        NavItemData(
          iconPath: "assets/Images/BottomNavigationScreen/notification_icon.svg",
          label: "NOTIFICATION",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
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
