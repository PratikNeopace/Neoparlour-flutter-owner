import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';

import 'package:neo_parlour_owner/widgets/usage_details_dialog.dart';

class AssignedStaffScreen extends StatefulWidget {
  final InventoryResponse inventory;

  const AssignedStaffScreen({super.key, required this.inventory});

  @override
  State<AssignedStaffScreen> createState() => _AssignedStaffScreenState();
}

class _AssignedStaffScreenState extends State<AssignedStaffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false)
          .fetchStaffAssignments(widget.inventory.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "Staff Assignments - ${widget.inventory.name}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isAssignmentsLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
          }

          if (provider.errorMessage != null && provider.staffAssignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${provider.errorMessage}", style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.fetchStaffAssignments(widget.inventory.id),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (provider.staffAssignments.isEmpty) {
            return const Center(
              child: Text("No staff assigned to this item yet"),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.staffAssignments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final assignment = provider.staffAssignments[index];
              return _buildAssignmentCard(assignment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(StaffInventoryResponse assignment) {
    final assignedDate = assignment.assignedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(assignment.assignedAt!.toLocal())
        : 'Unknown Date';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0XFFFF0B01),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.staffName ?? "Unknown Staff",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Assigned by: ${assignment.assignedBy ?? 'System'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showReassignDialog(assignment),
                icon: const Icon(Icons.edit_note, color: Color(0XFFFF0B01)),
                tooltip: "Reassign / Update Usage",
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat("Allocated", "${assignment.allocatedQuantity}"),
              _buildStat("Used", "${assignment.usedQuantity ?? 0.0}"),
              _buildStat("Remaining", "${assignment.remainingQuantity ?? assignment.allocatedQuantity}"),
              _buildStat("Appointments", "${assignment.appointmentCount ?? 0}"),
              _buildStat("Unit", widget.inventory.unitType.name),
            ],
          ),
          const SizedBox(height: 12),
          if (assignment.notes != null && assignment.notes!.isNotEmpty) ...[
            const Text(
              "Notes:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
            ),
            Text(
              assignment.notes!,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Assigned: $assignedDate",
                style: const TextStyle(color: Color(0XFFFF0B01), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              OutlinedButton(
                onPressed: () => _showUsageDetailsDialog(assignment),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0XFFFF0B01),
                  side: const BorderSide(color: Color(0XFFFF0B01)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("View Usage", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUsageDetailsDialog(StaffInventoryResponse assignment) {
    showDialog(
      context: context,
      builder: (context) => UsageDetailsDialog(
        assignmentId: assignment.id,
        itemName: widget.inventory.name,
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  void _showReassignDialog(StaffInventoryResponse assignment) {
    final usedQtyController = TextEditingController(text: "${assignment.usedQuantity ?? 0.0}");
    final newTotalQtyController = TextEditingController(text: "${assignment.allocatedQuantity}");
    final notesController = TextEditingController(text: assignment.notes ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Assignment - ${assignment.staffName}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Used Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: usedQtyController,
                  readOnly: true,
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("New Total Allocated Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: newTotalQtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: "Enter total quantity",
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: "Update notes...",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                final used = double.tryParse(usedQtyController.text) ?? 0.0;
                final total = double.tryParse(newTotalQtyController.text) ?? 0.0;

                try {
                  await Provider.of<InventoryProvider>(context, listen: false).reassignInventory(
                    assignment.id,
                    widget.inventory.id,
                    used,
                    total,
                    notesController.text,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    FlushbarHelper.show(context, "Assignment updated successfully");
                  }
                } catch (e) {
                  if (mounted) {
                    FlushbarHelper.show(context, "Error: $e");
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFFFF0B01)),
              child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
