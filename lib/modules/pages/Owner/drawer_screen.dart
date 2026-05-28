import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      useRootNavigator: false, // keep current screen visible
      barrierDismissible: true,
      barrierLabel: 'Drawer',
      barrierColor: Colors.transparent, // overlay handled inside widget
      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (_, __, ___) => const DrawerScreen(),

      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final drawerWidth = sw * 0.78;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // tap outside closes drawer
      child: Stack(
        children: [
          /// DARK OVERLAY (background dim)
          Container(color: Colors.black.withOpacity(0.15)),
      
          /// RIGHT DRAWER
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {}, // prevent closing when tapping drawer
              child: Container(
                width: drawerWidth,
                height: double.infinity,
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
      
                      SvgPicture.asset(
                        "assets/Images/SplashScreen/neo_parlour_logo.svg",
                        height: 75,
                        width: 85,
                      ),
      
                      const SizedBox(height: 42),
      
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final role = auth.user?.role.toUpperCase();
                          final isOwner = role == 'SALON_OWNER' || role == 'OWNER';

                          return _buildGroupContainer([
                            _buildRow(
                              "assets/Images/DrawerScreen/profile_icon.svg",
                              'Profile',
                            ),
                            _divider(),
                            _buildRow(
                              "assets/Images/DrawerScreen/about_us_icon.svg",
                              'About Us',
                            ),
                            _divider(),
                            _buildRow(
                              "assets/Images/DrawerScreen/support_icon.svg",
                              'Support',
                            ),
                            _divider(),
                            _buildRow(
                              "assets/Images/DrawerScreen/booking_icon.svg",
                              'My Bookings',
                            ),
                            if (isOwner) ...[
                              _divider(),
                              _buildRow(
                                "assets/Images/DrawerScreen/subscription_icon.svg",
                                'Subscription',
                              ),
                            ],
                          ]);
                        },
                      ),
      
                      const SizedBox(height: 24),
      
                      _buildGroupContainer([
                        _buildRow(
                          "assets/Images/DrawerScreen/password_icon.svg",
                          'Change Password',
                        ),
                        _divider(),
                        _buildRow(
                          "assets/Images/DrawerScreen/logout_icon.svg",
                          'LOGOUT',
                        ),
                      ]),
      
                      const Spacer(),
      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Powered By Neopaceinfotech LLP',
                          style: TextStyle(
                            color: Color(0XFF626262),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupContainer(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0XFFDFDFDF)),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildRow(String imageIcon, String title) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -2),
      // FIXED: Added .asset constructor here
      leading: SvgPicture.asset(imageIcon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 15,
        color: Color(0XFF868686),
      ),
      onTap: () {},
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }
}
