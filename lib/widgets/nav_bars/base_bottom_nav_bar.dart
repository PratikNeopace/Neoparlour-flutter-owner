import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavItemData {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const NavItemData({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });
}

class BaseBottomNavBar extends StatelessWidget {
  final List<NavItemData> items;
  final Widget? floatingActionButton;

  const BaseBottomNavBar({
    super.key,
    required this.items,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Basic shared layout constants
    final double systemNavBar = MediaQuery.of(context).padding.bottom;
    const double navHeight = 70;
    const double notchRadius = 28;
    const double notchMargin = 6;

    // Split items into two groups (left and right of the FAB)
    final int midPoint = (items.length / 2).ceil();
    final List<NavItemData> leftItems = items.take(midPoint).toList();
    final List<NavItemData> rightItems = items.skip(midPoint).toList();

    return SizedBox(
      height: navHeight + notchMargin + systemNavBar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, navHeight + notchMargin + systemNavBar),
              painter: NavBarPainter(
                notchRadius: notchRadius,
                notchMargin: notchMargin,
                systemNavBar: systemNavBar,
              ),
              child: SizedBox(
                height: navHeight + notchMargin + systemNavBar,
                child: Column(
                  children: [
                    const SizedBox(height: notchMargin),
                    SizedBox(
                      height: navHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ...leftItems.map((item) => _buildNavItem(context, item)),
                          const SizedBox(width: 50), // Gap for the FloatingActionButton
                          ...rightItems.map((item) => _buildNavItem(context, item)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItemData item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: SvgPicture.asset(
                item.iconPath,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(Color(0XFF868686), BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.label,
              style: const TextStyle(
                color: Color(0XFF868686),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final double notchRadius;
  final double notchMargin;
  final double systemNavBar;

  const NavBarPainter({
    required this.notchRadius,
    required this.notchMargin,
    required this.systemNavBar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final double cx = size.width / 2;
    final double r = notchRadius;
    final double m = notchMargin;
    final double top = m;

    final path = Path()
      ..moveTo(0, top)
      ..lineTo(cx - r - m, top)
      ..arcToPoint(
        Offset(cx + r + m, top),
        radius: Radius.circular(r + m),
        clockwise: false,
      )
      ..lineTo(size.width, top)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
