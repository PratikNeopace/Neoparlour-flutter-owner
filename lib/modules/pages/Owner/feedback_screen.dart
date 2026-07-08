import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/feedback_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';


class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentTab();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _fetchCurrentTab();
    }
  }

  void _fetchCurrentTab() {
    final provider = Provider.of<FeedbackProvider>(context, listen: false);
    if (_tabController.index == 0) {
      provider.fetchPendingFeedback();
    } else {
      provider.fetchApprovedFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
          width: 22,
          height: 22,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // ─── TAB BAR ────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0XFFFF0B01),
                indicatorWeight: 3,
                labelColor: const Color(0XFFFF0B01),
                unselectedLabelColor: const Color(0XFF909090),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: "PENDING"),
                  Tab(text: "APPROVED"),
                ],
              ),
            ),
            // ─── TAB CONTENT ────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedbackTab(isPending: true),
                  _buildFeedbackTab(isPending: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB CONTENT =================
  Widget _buildFeedbackTab({required bool isPending}) {
    return Consumer<FeedbackProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final emptyLabel = isPending
            ? "No Pending Feedback Found"
            : "No Approved Feedback Found";

        return CustomRefreshIndicator(
          onRefresh: () async => _fetchCurrentTab(),
          color: const Color(0XFFFF0B01),
          child: provider.feedbacks.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Text(
                        emptyLabel,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: provider.feedbacks.length,
                  itemBuilder: (context, index) =>
                      _feedbackCard(provider.feedbacks[index], isPending),
                ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Images/FeedbackScreen/background_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502),
                  ],
                ),
              ),
              child: const Text(
                "FEEDBACK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
          ),
        ),
        Positioned(
          right: 15,
          bottom: 15,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0XFFFF0B01),
            child: SvgPicture.asset(
              height: 30,
              width: 30,
              "assets/Images/FeedbackScreen/floating_btn.svg",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }


  // ================= FEEDBACK CARD =================
  Widget _feedbackCard(dynamic feedback, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isPending
              ? const Color(0XFF909090)
              : Colors.green.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0XFFF0F0F0),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.person, size: 28, color: Color(0XFFB0B0B0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Customer #${feedback.customerId ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${feedback.rating ?? 0.0}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.comment ?? '',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0XFF8D8D8D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Approved badge ────────────────────────────────────────────
          if (!isPending) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0XFFE0E0E0)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        "APPROVED",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                if (feedback.createdAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(feedback.createdAt!),
                    style: const TextStyle(fontSize: 11, color: Color(0XFF8D8D8D)),
                  ),
                ],
              ],
            ),
          ],
          // ── Pending action buttons ─────────────────────────────────────
          if (isPending) ...[
            const SizedBox(height: 15),
            const Divider(height: 1, color: Color(0XFFE0E0E0)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Consumer<FeedbackProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                try {
                                  await provider.rejectFeedback(feedback.id!);
                                  if (context.mounted) {
                                    FlushbarHelper.show(
                                        context, "Feedback rejected successfully!",
                                        isSuccess: true);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    FlushbarHelper.show(context, "Error: $e");
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[400]!),
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text("REJECT",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                try {
                                  await provider.approveFeedback(feedback.id!);
                                  if (context.mounted) {
                                    FlushbarHelper.show(
                                        context, "Feedback approved successfully!",
                                        isSuccess: true);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    FlushbarHelper.show(context, "Error: $e");
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFFFF0B01),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text("APPROVE",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return isoDate;
    }
  }
}

// ================= CLIPPER =================
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.55, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height * 0.35,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}