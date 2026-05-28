import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonth = DateTime.now().month;
  final List<String> _months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<AttendanceProvider>().fetchAttendanceHistory(staffId: authProvider.user!.id);
        context.read<AttendanceProvider>().fetchMonthlyAttendance(
          staffId: authProvider.user!.id,
          month: _selectedMonth,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "ATTENDANCE HISTORY",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0XFFFF0B01),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0XFFFF0B01),
          tabs: const [
            Tab(text: "RECENT"),
            Tab(text: "MONTHLY"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentSection(),
          _buildMonthlySection(),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        _fetchData();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.attendanceHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
          }

          if (provider.errorMessage != null && provider.attendanceHistory.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.attendanceHistory.isEmpty) {
            return const Center(
              child: Text(
                "No recent records found.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.attendanceHistory.length,
            itemBuilder: (context, index) {
              final attendance = provider.attendanceHistory[index];
              return _buildAttendanceCard(attendance);
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthlySection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                isExpanded: true,
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                      _months[index],
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMonth = value);
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.user != null) {
                      context.read<AttendanceProvider>().fetchMonthlyAttendance(
                        staffId: authProvider.user!.id,
                        month: _selectedMonth,
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Consumer<AttendanceProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
              }

              if (provider.monthlyAttendance.isEmpty) {
                return Center(
                  child: Text(
                    "No records found for ${_months[_selectedMonth - 1]}.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.monthlyAttendance.length,
                itemBuilder: (context, index) {
                  final attendance = provider.monthlyAttendance[index];
                  return _buildAttendanceCard(attendance);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(dynamic attendance) {
    final dateStr = DateFormat('dd MMMM yyyy').format(attendance.attendanceDate.toLocal());
    final dayStr = DateFormat('EEEE').format(attendance.attendanceDate.toLocal());
    
    final checkInStr = attendance.checkIn != null 
        ? DateFormat('hh:mm a').format(attendance.checkIn!.toLocal()) 
        : '--:--';
    final checkOutStr = attendance.checkOut != null 
        ? DateFormat('hh:mm a').format(attendance.checkOut!.toLocal()) 
        : '--:--';

    String durationStr = "--h : --m";
    if (attendance.checkIn != null && attendance.checkOut != null) {
      final diff = attendance.checkOut!.difference(attendance.checkIn!);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
      durationStr = "${hours}h : ${minutes}m";
    } else if (attendance.checkIn != null && attendance.checkOut == null && 
               attendance.attendanceDate.day == DateTime.now().day) {
      final diff = DateTime.now().difference(attendance.checkIn!);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
      durationStr = "${hours}h : ${minutes}m (Active)";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayStr,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0XFFFF0B01),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: attendance.status.toUpperCase() == 'PRESENT' 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      attendance.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: attendance.status.toUpperCase() == 'PRESENT' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    durationStr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeItem("PUNCH IN", checkInStr, Icons.login, Colors.green),
              _buildTimeItem("PUNCH OUT", checkOutStr, Icons.logout, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}