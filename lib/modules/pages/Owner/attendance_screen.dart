import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  String selectedMonth = "July";
  String selectedYear = "2026";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0XFFFF3B30),
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
          width: 22,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.presentEmployeesTitle,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _attendanceProgressCard(context),
                        _statCard("assets/Images/AttendanceScreen/total_employee_icon.svg","20",AppLocalizations.of(context)!.totalEmployeeTitle),
                        _statCard("assets/Images/AttendanceScreen/on_leave_icon.svg","3",AppLocalizations.of(context)!.onLeaveTitle),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _staffDropdown(context),
                    const SizedBox(height: 25),

                    _buildCalendar(context),
                    const SizedBox(height: 18),

                    _attendanceDetailCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //================ HEADER =================
  Widget _buildHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Images/AttendanceScreen/background_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3B30),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(AppLocalizations.of(context)!.attendanceTitle,
                  style: const TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  //================ PROGRESS CARD =================
  Widget _attendanceProgressCard(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 45,
              width: 45,
              child: CircularProgressIndicator(
                value: .97,
                strokeWidth: 4,
                backgroundColor: Color(0XFFF5F5F5),
                color: Color(0XFFFF3B30),
              ),
            ),
            const SizedBox(height: 5),
            Text(AppLocalizations.of(context)!.totalAttendanceTitle,
                style: const TextStyle(fontSize: 11, color: Color(0XFF909090)))
          ],
        ),
      ),
    );
  }

  Widget _statCard(String icon, String value, String title) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Color(0XFFFF3B30))),
            Text(title, style: const TextStyle(fontSize: 11,color: Color(0XFF909090))),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0XFFE4E4E4)),
      );

  //================ STAFF DROPDOWN =================
  Widget _staffDropdown(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.person_outline,color: Color(0XFF8D8D8D)),
          const SizedBox(width: 8),
          Expanded(child: Text(AppLocalizations.of(context)!.staffNameHint,style: const TextStyle(color: Color(0XFF8D8D8D)))),
          const Icon(Icons.keyboard_arrow_down,color: Color(0XFF8D8D8D)),
        ],
      ),
    );
  }

  //================ CALENDAR =================
  Widget _buildCalendar(BuildContext context) {
    final days = [
      AppLocalizations.of(context)!.monShort,
      AppLocalizations.of(context)!.tueShort,
      AppLocalizations.of(context)!.wedShort,
      AppLocalizations.of(context)!.thuShort,
      AppLocalizations.of(context)!.friShort,
      AppLocalizations.of(context)!.satShort,
      AppLocalizations.of(context)!.sunShort,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.dateTitle,style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),

        Container(
          height: 85,
          decoration: BoxDecoration(
            color: const Color(0xffDED6D2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(15, (index) {
                int date = index + 1;
                bool isSelected = date == 4;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Column(
                    children: [
                      Text(days[index % 7],style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      isSelected
                          ? Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Color(0XFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text("$date",style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                            )
                          : Text("$date",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  //================ DETAIL CARD =================
  Widget _attendanceDetailCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pravin Ithape",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700)),
              Text("01 March 2026 to 31 March 2026",style: TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: Text("${AppLocalizations.of(context)!.totalHoursLabel}\n240h : 01m : 12s\n${AppLocalizations.of(context)!.presentLabel} - 30 ${AppLocalizations.of(context)!.daysLabel}")),
              const VerticalDivider(),
              Expanded(child: Text("${AppLocalizations.of(context)!.leavesLabel}\n${AppLocalizations.of(context)!.paidLeaveLabel} -\n${AppLocalizations.of(context)!.halfDayLabel} -\n${AppLocalizations.of(context)!.sickLeaveLabel} -\n${AppLocalizations.of(context)!.casualLeaveLabel} -")),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),

          Text(AppLocalizations.of(context)!.inventoryUsedTitle,style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${AppLocalizations.of(context)!.itemTypeLabel} - ${AppLocalizations.of(context)!.toolsLabel}"),
              Text("${AppLocalizations.of(context)!.shampooLabel} - 15"),
              Text("${AppLocalizations.of(context)!.usedLabel} - 05"),
              Text("${AppLocalizations.of(context)!.returnLabel} - 10"),
            ],
          ),
        ],
      ),
    );
  }
}

//================ CLIPPER =================
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * .55, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height * .35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}