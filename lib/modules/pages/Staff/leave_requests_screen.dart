import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/data/models/leave_model.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        // Initial fetch for the current tab
        _fetchLeaveRequestsForTab(_tabController.index);
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchLeaveRequestsForTab(_tabController.index);
      }
    });
  }

  void _fetchLeaveRequestsForTab(int index, {int page = 0}) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    String? status;
    if (index == 0) status = 'PENDING';
    else if (index == 1) status = 'APPROVED';
    else if (index == 2) status = 'REJECTED';

    context.read<AttendanceProvider>().fetchStaffLeaveRequests(
      staffId: authProvider.user!.id,
      status: status,
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "LEAVE REQUESTS",
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
            Tab(text: "PENDING"),
            Tab(text: "APPROVED"),
            Tab(text: "REJECTED"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList('PENDING'),
          _buildLeaveList('APPROVED'),
          _buildLeaveList('REJECTED'),
        ],
      ),
    );
  }

  Widget _buildLeaveList(String status) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        _fetchLeaveRequestsForTab(_tabController.index);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
          }

          if (provider.errorMessage != null && provider.staffLeaveRequests.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.staffLeaveRequests.isEmpty) {
            return Center(
              child: Text(
                "No $status leave requests found.",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.staffLeaveRequests.length + 1,
            itemBuilder: (context, index) {
              if (index == provider.staffLeaveRequests.length) {
                return provider.leaveTotalPages > 1
                    ? PaginationWidget(
                        currentPage: provider.leaveCurrentPage,
                        totalPages: provider.leaveTotalPages,
                        onPageSelected: (page) => _fetchLeaveRequestsForTab(_tabController.index, page: page),
                      )
                    : const SizedBox.shrink();
              }
              final leave = provider.staffLeaveRequests[index];
              return _buildLeaveCard(leave);
            },
          );
        },
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequestModel leave) {
    final startDateStr = DateFormat('dd MMM yyyy').format(leave.startDate.toLocal());
    final endDateStr = DateFormat('dd MMM yyyy').format(leave.endDate.toLocal());
    final createdAtStr = DateFormat('dd MMM yyyy, hh:mm a').format(leave.createdAt!.toLocal());

    Color statusColor = Colors.orange;
    if (leave.status == 'APPROVED') statusColor = Colors.green;
    if (leave.status == 'REJECTED') statusColor = Colors.red;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                createdAtStr,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildDateItem("START DATE", startDateStr, Icons.calendar_today, Colors.blue),
              const SizedBox(width: 30),
              _buildDateItem("END DATE", endDateStr, Icons.calendar_today, Colors.purple),
            ],
          ),
          const Divider(height: 30),
          Text(
            "REASON",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            leave.reason,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          if (leave.status != 'PENDING' && leave.approvedBy != null) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(
                  "${leave.status == 'APPROVED' ? 'Approved' : 'Rejected'} by ${leave.approvedBy}",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String date, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          date,
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
