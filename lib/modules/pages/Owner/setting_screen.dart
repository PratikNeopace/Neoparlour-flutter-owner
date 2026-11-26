import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/active_subscription_screen.dart';
import 'about_us_screen.dart';
import 'support_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/leave_request_staff_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/inventory_staff_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/my_referrals_screen.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/core/data/services/app_icon_service.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  /// Call this to open drawer
  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      barrierLabel: 'Drawer',
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 300),
     
      pageBuilder: (context, animation, secondaryAnimation) => const SettingScreen(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
   return GestureDetector(
      onTap: () => Navigator.pop(context), // close when tapping outside
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {}, // prevent close when tapping drawer
            child: _drawerContent(context),
          ),
        ),
      ),
    );
  }

  /// Drawer UI
  Widget _drawerContent(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.78;

    return Container(
      width: drawerWidth,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            /// Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0XFF2D2D2D),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// Logo
            SvgPicture.asset(
              "assets/Images/SplashScreen/neo_parlour_logo.svg",
              height: 75,
              width: 85,
            ),

            const SizedBox(height: 42),

            /// First Group
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final role = auth.user?.role.toUpperCase();
                final isOwner = role == 'SALON_OWNER' || role == 'OWNER';

                return _buildGroupContainer([
                  _buildRow(
                    "assets/Images/DrawerScreen/profile_icon.svg",
                    AppLocalizations.of(context)!.drawerProfile,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _divider(),
                  _buildRow(
                    "assets/Images/DrawerScreen/about_us_icon.svg",
                    AppLocalizations.of(context)!.drawerAboutUs,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    ),
                  ),
                  _divider(),
                  _buildRow(
                    "assets/Images/DrawerScreen/support_icon.svg",
                    AppLocalizations.of(context)!.drawerSupport,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportScreen()),
                    ),
                  ),
                  _divider(),
                  _buildRowIcon(
                    Icons.celebration_outlined,
                    "App Icon Theme 🪔",
                    onTap: () {
                      _showAppIconThemeDialog(context);
                    },
                  ),
                  if (isOwner) ...[
                    _divider(),
                    _buildRow(
                      "assets/Images/DrawerScreen/subscription_icon.svg",
                      AppLocalizations.of(context)!.drawerSubscription,
                      onTap: () {
                        // Close the drawer first
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ActiveSubscriptionScreen()),
                        );
                      }
                    ),
                  ] else ...[
                    _divider(),
                    _buildRowIcon(
                      Icons.card_giftcard,
                      AppLocalizations.of(context)!.drawerMyReferrals,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyReferralsScreen()),
                        );
                      }
                    ),
                    _divider(),
                    _buildRowIcon(
                      Icons.exit_to_app,
                      AppLocalizations.of(context)!.drawerLeaveRequest,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LeaveRequestStaffScreen()),
                        );
                      }
                    ),
                    _divider(),
                    _buildRowIcon(
                      Icons.inventory,
                      AppLocalizations.of(context)!.drawerInventory,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InventoryStaffScreen()),
                        );
                      }
                    ),
                  ],
                ]);
              },
            ),

            const SizedBox(height: 24),

            /// Second Group
            _buildGroupContainer([

              _buildRow(
                "assets/Images/DrawerScreen/logout_icon.svg",
                AppLocalizations.of(context)!.drawerLogout,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SalonOwnerLoginScreen(),
                      ),
                      (_) => false,
                    );
                  }
                },
              ),
            ]),

            const Spacer(),

            /// Footer
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                   Text(
                    AppLocalizations.of(context)!.versionFooter,
                    style: const TextStyle(
                       fontSize: 10,
                      color: Color(0XFF626262),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.drawerPoweredBy,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0XFF626262),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helpers
  Widget _buildGroupContainer(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0XFFDFDFDF)),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildRow(String icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -2),
      leading: SvgPicture.asset(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 15,
        color: Color(0XFF868686),
      ),
      onTap: onTap,
    );
  }

  Widget _buildRowIcon(IconData iconData, String title, {VoidCallback? onTap}) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(iconData, size: 24, color: const Color(0XFF2D2D2D)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 15,
        color: Color(0XFF868686),
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }

  void _showAppIconThemeDialog(BuildContext context) async {
    final currentIcon = await AppIconService.getCurrentIcon();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.celebration, color: Color(0XFFFF0B01), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "App Icon Theme",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0XFF131313),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/NeoParlourOwner-icon-launcher.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.apps, color: Colors.grey),
                    ),
                  ),
                ),
                title: Text(
                  'Classic NeoParlour',
                  style: GoogleFonts.poppins(
                    fontWeight: currentIcon == 'default' ? FontWeight.w600 : FontWeight.w400,
                    color: currentIcon == 'default' ? const Color(0XFFFF0B01) : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Default classic app icon',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                trailing: currentIcon == 'default'
                    ? const Icon(Icons.check_circle, color: Color(0XFFFF0B01))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await AppIconService.switchIcon(context, 'default', showPopup: true);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/NeoparlourDiwaliThemeOwner512_512.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.celebration, color: Colors.red),
                    ),
                  ),
                ),
                title: Text(
                  'Diwali Festive Theme ✨',
                  style: GoogleFonts.poppins(
                    fontWeight: currentIcon == 'diwali' ? FontWeight.w600 : FontWeight.w400,
                    color: currentIcon == 'diwali' ? const Color(0XFFFF0B01) : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Special 15-day seasonal festival icon',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                trailing: currentIcon == 'diwali'
                    ? const Icon(Icons.check_circle, color: Color(0XFFFF0B01))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await AppIconService.switchIcon(context, 'diwali', showPopup: true);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/NeoparlourChristmasThemeOwner512_512.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.green.shade100,
                      child: const Icon(Icons.park, color: Colors.green),
                    ),
                  ),
                ),
                title: Text(
                  'Christmas Festive Theme 🎄',
                  style: GoogleFonts.poppins(
                    fontWeight: currentIcon == 'christmas' ? FontWeight.w600 : FontWeight.w400,
                    color: currentIcon == 'christmas' ? const Color(0XFFFF0B01) : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Special Christmas seasonal festival icon',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                trailing: currentIcon == 'christmas'
                    ? const Icon(Icons.check_circle, color: Color(0XFFFF0B01))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await AppIconService.switchIcon(context, 'christmas', showPopup: true);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/NeoparlourNewYearThemeOwner512_512.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.amber.shade100,
                      child: const Icon(Icons.auto_awesome, color: Colors.orange),
                    ),
                  ),
                ),
                title: Text(
                  'Happy New Year ✨🎉',
                  style: GoogleFonts.poppins(
                    fontWeight: currentIcon == 'newyear' ? FontWeight.w600 : FontWeight.w400,
                    color: currentIcon == 'newyear' ? const Color(0XFFFF0B01) : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Special New Year seasonal festival icon',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                trailing: currentIcon == 'newyear'
                    ? const Icon(Icons.check_circle, color: Color(0XFFFF0B01))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await AppIconService.switchIcon(context, 'newyear', showPopup: true);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}