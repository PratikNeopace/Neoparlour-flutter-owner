import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/notification_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';
import 'package:neo_parlour_owner/providers/order_provider.dart';
import 'package:neo_parlour_owner/data/models/order_model.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/data/models/leave_model.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final salonId = int.tryParse(auth.user?.tenantName ?? '') ?? 0;
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications(salonId: salonId, refresh: true);
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchBirthdays(salonId: salonId, refresh: true);
      Provider.of<InventoryProvider>(context, listen: false)
          .fetchPendingSwapRequests();
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchPendingLeaveRequests();
      Provider.of<OrderProvider>(context, listen: false)
          .fetchOrders(salonId: salonId, refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Color _getStatusColor(String status, String message) {
    if (message.toLowerCase().contains("missed")) return const Color(0xFFFF0B01);
    if (message.toLowerCase().contains("rescheduled")) return const Color(0xFF2196F3); // Blue for rescheduled
    
    switch (status.toLowerCase()) {
      case 'sent':
        return const Color(0xFF43A047); // Green
      case 'pending':
        return const Color(0xFFFFA000); // Amber
      default:
        return const Color(0xFFDADADA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: const OwnerBottomNavBar(),
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
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0XFFFF0B01),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Notifications"),
              Tab(text: "Birthdays"),
              Tab(text: "Requests"),
              Tab(text: "Orders"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsTab(),
                _buildBirthdaysTab(),
                _buildRequestsTab(),
                _buildProductRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return provider.isLoading && provider.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
            : provider.errorMessage != null
                ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)))
                : provider.notifications.isEmpty
                    ? const Center(child: Text("No notifications yet"))
                    : CustomRefreshIndicator(
                        onRefresh: () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          await provider.fetchNotifications(
                            salonId: int.tryParse(auth.user?.tenantName ?? '') ?? 0,
                            refresh: true,
                          );
                        },
                        color: const Color(0XFFFF0B01),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          itemCount: provider.notifications.length + (provider.totalPages > 1 ? 1 : 0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == provider.notifications.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                                child: PaginationWidget(
                                  currentPage: provider.currentPage,
                                  totalPages: provider.totalPages,
                                  onPageSelected: (page) {
                                    final auth = Provider.of<AuthProvider>(context, listen: false);
                                    provider.goToPage(
                                      page: page,
                                      salonId: int.tryParse(auth.user?.tenantName ?? '') ?? 0,
                                    );
                                  },
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

  Widget _buildBirthdaysTab() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return provider.isBirthdaysLoading && provider.birthdays.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
            : provider.birthdaysErrorMessage != null
                ? Center(child: Text(provider.birthdaysErrorMessage!, style: const TextStyle(color: Colors.red)))
                : provider.birthdays.isEmpty
                    ? const Center(child: Text("No Birthdays found !"))
                    : CustomRefreshIndicator(
                        onRefresh: () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          await provider.fetchBirthdays(
                            salonId: int.tryParse(auth.user?.tenantName ?? '') ?? 0,
                            refresh: true,
                          );
                        },
                        color: const Color(0XFFFF0B01),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          itemCount: provider.birthdays.length + (provider.birthdaysTotalPages > 1 ? 1 : 0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == provider.birthdays.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                                child: PaginationWidget(
                                  currentPage: provider.birthdaysCurrentPage,
                                  totalPages: provider.birthdaysTotalPages,
                                  onPageSelected: (page) {
                                    final auth = Provider.of<AuthProvider>(context, listen: false);
                                    provider.goToBirthdaysPage(
                                      page: page,
                                      salonId: int.tryParse(auth.user?.tenantName ?? '') ?? 0,
                                    );
                                  },
                                ),
                              );
                            }
                            
                            final item = provider.birthdays[index];
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

  Widget _buildRequestsTab() {
    return Consumer2<InventoryProvider, AttendanceProvider>(
      builder: (context, inventoryProvider, attendanceProvider, child) {
        final swaps = inventoryProvider.pendingSwapRequests;
        final leaves = attendanceProvider.pendingLeaveRequests;

        if ((inventoryProvider.isLoading && swaps.isEmpty) || (attendanceProvider.isLoading && leaves.isEmpty)) {
          return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
        }

        if (swaps.isEmpty && leaves.isEmpty) {
          return const Center(child: Text("No pending requests"));
        }

        return CustomRefreshIndicator(
          onRefresh: () async {
            await inventoryProvider.fetchPendingSwapRequests();
            await attendanceProvider.fetchPendingLeaveRequests();
          },
          color: const Color(0XFFFF0B01),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              if (swaps.isNotEmpty) ...[
                const Text("SWAP REQUESTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 10),
                ...swaps.map((req) => _buildSwapRequestCard(context, req, inventoryProvider)),
                const SizedBox(height: 20),
              ],
              if (leaves.isNotEmpty) ...[
                const Text("LEAVE REQUESTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 10),
                ...leaves.map((req) => _buildLeaveRequestCard(context, req, attendanceProvider)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaveRequestCard(BuildContext context, LeaveRequestModel req, AttendanceProvider provider) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final startDate = formatter.format(req.startDate);
    final endDate = formatter.format(req.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Staff ID: ${req.staffId} requested leave\nFrom: $startDate To: $endDate\nReason: ${req.reason}",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.close, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final msg = await provider.approveLeaveRequest(req.id);
                      if (context.mounted) {
                        FlushbarHelper.show(context, msg);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        FlushbarHelper.show(context, provider.errorMessage ?? "Failed to approve");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0B01),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("APPROVE", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final msg = await provider.rejectLeaveRequest(req.id);
                      if (context.mounted) {
                        FlushbarHelper.show(context, msg);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        FlushbarHelper.show(context, provider.errorMessage ?? "Failed to reject");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF909090),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("REJECT", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2, color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSwapRequestCard(BuildContext context, InventorySwapRequestModel req, InventoryProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "${req.requestedBy ?? 'Unknown'} wants to swap inventory with ${req.toStaff ?? 'Unknown'}\nTool : ${req.productName ?? 'Unknown'}   Qty : ${req.quantity.toInt()}",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.close, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final msg = await provider.approveSwapRequest(req.id);
                      if (context.mounted) {
                        FlushbarHelper.show(context, msg);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        FlushbarHelper.show(context, provider.errorMessage ?? "Failed to approve");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0B01),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("APPROVE", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final msg = await provider.rejectSwapRequest(req.id);
                      if (context.mounted) {
                        FlushbarHelper.show(context, msg);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        FlushbarHelper.show(context, provider.errorMessage ?? "Failed to reject");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF909090),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("REJECT", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2, color: Colors.white)),
                ),
              ),

            ],
          )
        ],
      ),
    );
  }



  Widget _buildProductRequestsTab() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final salonId = int.tryParse(auth.user?.tenantName ?? '') ?? 0;
                      provider.setMobileQuery(value, salonId);
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Search by Mobile Number...',
                      prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0XFFFF0B01)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['All', 'Ordered', 'Completed', 'Cancelled'].map((status) {
                        final isSelected = provider.selectedStatus.toLowerCase() == status.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            selectedColor: const Color(0XFFFF0B01).withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0XFFFF0B01) : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0XFFFF0B01) : Colors.grey.shade300,
                              ),
                            ),
                            showCheckmark: false,
                            onSelected: (selected) {
                              if (selected) {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                final salonId = int.tryParse(auth.user?.tenantName ?? '') ?? 0;
                                provider.setStatusFilter(status.toLowerCase(), salonId);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && provider.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
                  : provider.errorMessage != null
                      ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)))
                      : provider.orders.isEmpty
                          ? const Center(child: Text("No product requests found"))
                          : CustomRefreshIndicator(
                              onRefresh: () async {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                await provider.fetchOrders(
                                  salonId: int.tryParse(auth.user?.tenantName ?? '') ?? 0,
                                  refresh: true,
                                );
                              },
                              color: const Color(0XFFFF0B01),
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                                itemCount: provider.orders.length + (provider.totalPages > 1 ? 1 : 0),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (index == provider.orders.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                                      child: PaginationWidget(
                                        currentPage: provider.currentPage,
                                        totalPages: provider.totalPages,
                                        onPageSelected: (page) {
                                          final auth = Provider.of<AuthProvider>(context, listen: false);
                                          provider.goToPage(
                                            page: page,
                                            salonId: int.tryParse(auth.user?.tenantName ?? '') ?? 0,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  final order = provider.orders[index];
                                  return _buildOrderCard(context, order, provider);
                                },
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, OrderProvider provider) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
    String dateStr = '';
    try {
      final date = DateTime.parse(order.createdAt).toLocal();
      dateStr = formatter.format(date);
    } catch (_) {}

    final bool showActions = order.status.toLowerCase() == 'ordered' || order.status.toLowerCase() == 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${order.customerName} (${order.customerMobile})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: showActions ? const Color(0xFFFFA000).withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: showActions ? const Color(0xFFFFA000) : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
          const Divider(height: 20),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${item.quantity}x ${item.productName}", style: const TextStyle(fontSize: 12)),
                Text("₹${item.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("₹${order.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0XFFFF0B01))),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final msg = await provider.approveOrder(order.id);
                        if (context.mounted) {
                          FlushbarHelper.show(context, msg);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          FlushbarHelper.show(context, provider.errorMessage ?? "Failed to approve");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0B01),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("APPROVE", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final msg = await provider.rejectOrder(order.id);
                        if (context.mounted) {
                          FlushbarHelper.show(context, msg);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          FlushbarHelper.show(context, provider.errorMessage ?? "Failed to reject");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF909090),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("REJECT", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 2, color: Colors.white)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
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
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withOpacity(0.7),
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
              backgroundColor: Colors.white.withOpacity(0.4),
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
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 6)),
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
          color: statusColor.withOpacity(0.08),
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
                      Icon(Icons.close, size: 24, color: statusColor.withOpacity(0.8)),
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

class HeaderCurveClipper extends CustomClipper<Path> {
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