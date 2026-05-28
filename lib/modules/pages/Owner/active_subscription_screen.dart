import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/data/services/subscription_service.dart';

class ActiveSubscriptionScreen extends StatefulWidget {
  const ActiveSubscriptionScreen({super.key});

  @override
  State<ActiveSubscriptionScreen> createState() => _ActiveSubscriptionScreenState();
}

class _ActiveSubscriptionScreenState extends State<ActiveSubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<dynamic> _subscriptions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSubscriptions();
    });
  }

  Future<void> _fetchSubscriptions() async {
    final authProvider = context.read<AuthProvider>();
    final salonId = authProvider.user?.salonId ?? authProvider.user?.id;
    
    if (salonId == null) {
      setState(() {
        _errorMessage = "Salon ID not found. Please log in again.";
        _isLoading = false;
      });
      return;
    }

    try {
      final subscriptions = await _subscriptionService.getSalonSubscriptions(salonId);
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "MY SUBSCRIPTIONS",
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_subscriptions.isEmpty) {
      return const Center(
        child: Text(
          "No subscriptions found.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final sub = _subscriptions[index];
        return _buildSubscriptionCard(sub);
      },
    );
  }

  Widget _buildSubscriptionCard(dynamic sub) {
    final String planCode = sub['planCode'] ?? 'Unknown';
    final String status = sub['status'] ?? 'Unknown';
    
    DateTime? startDate;
    DateTime? endDate;
    if (sub['startDate'] != null) {
      startDate = DateTime.tryParse(sub['startDate']);
    }
    if (sub['endDate'] != null) {
      endDate = DateTime.tryParse(sub['endDate']);
    }

    final startDateStr = startDate != null ? DateFormat('dd MMM yyyy').format(startDate) : 'N/A';
    final endDateStr = endDate != null ? DateFormat('dd MMM yyyy').format(endDate) : 'N/A';

    Color statusColor = Colors.orange;
    if (status.toLowerCase() == 'active') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'expired') {
      statusColor = Colors.red;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Plan: ${planCode.toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Start Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(startDateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("End Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(endDateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            if (sub['paymentId'] != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Payment ID: ${sub['paymentId']}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
