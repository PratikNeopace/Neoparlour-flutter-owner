import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/notification_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/staff_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';

class StaffNotificationScreen extends StatefulWidget {
  const StaffNotificationScreen({super.key});

  @override
  State<StaffNotificationScreen> createState() => _StaffNotificationScreenState();
}

class _StaffNotificationScreenState extends State<StaffNotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final salonId = auth.user?.salonId ?? int.tryParse(auth.user?.tenantName ?? '') ?? 0;
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications(salonId: salonId, refresh: true);
    });
  }

  Color _getStatusColor(String status, String message) {
    if (message.toLowerCase().contains("missed")) return const Color(0xFFFF0B01);
    if (message.toLowerCase().contains("rescheduled")) return const Color(0xFF2196F3);

    switch (status.toLowerCase()) {
      case 'sent':
        return const Color(0xFF43A047);
      case 'pending':
        return const Color(0xFFFFA000);
      default:
        return const Color(0xFFDADADA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: const StaffBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final role = authProvider.user?.role.toUpperCase();
          if (role == 'SALON_OWNER' || role == 'OWNER') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeStaffScreen()),
              (route) => false,
            );
          }
        },
        backgroundColor: const Color(0XFFFF0B01),
        shape: const CircleBorder(),
        child: SvgPicture.asset("assets/Images/BottomNavigationScreen/home_icon.svg"),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildNotificationsTab()),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
        }
        if (provider.errorMessage != null && provider.notifications.isEmpty) {
          return Center(
            child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
          );
        }
        if (provider.notifications.isEmpty) {
          return const Center(child: Text("No notifications yet"));
        }

        return CustomRefreshIndicator(
          onRefresh: () async {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            await provider.fetchNotifications(
              salonId: auth.user?.salonId ?? int.tryParse(auth.user?.tenantName ?? '') ?? 0,
              refresh: true,
            );
          },
          color: const Color(0XFFFF0B01),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == provider.notifications.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  provider.fetchNotifications(salonId: auth.user?.salonId ?? int.tryParse(auth.user?.tenantName ?? '') ?? 0);
                });
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0XFFFF0B01)),
                  ),
                );
              }

              final item = provider.notifications[index];
              final displayMsg = item.ownerMessage ?? item.message;

              return _notificationItem(
                context: context,
                message: displayMsg,
                statusColor: _getStatusColor(item.status, displayMsg),
                hasBorder: item.status == 'pending',
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _HeaderCurveClipper(),
          child: Container(
            height: 225,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/NotificationScreen/background_notification.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        const Positioned(
          bottom: 30,
          left: 23,
          child: Text(
            "NOTIFICATIONS",
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
          ),
        ),
        Positioned(
          bottom: -5,
          right: 22,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0XFFFF0B01),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.notifications, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  void _showNotificationDetail(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "DETAILED VIEW",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0XFFFF0B01)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFFF0B01),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationItem({
    required BuildContext context,
    required String message,
    required Color statusColor,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onLongPress: () => _showNotificationDetail(context, message),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: statusColor, width: 2) : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.close, size: 24, color: statusColor.withValues(alpha: 0.8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.55, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height * 0.35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}