import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';

class UsageDetailsDialog extends StatefulWidget {
  final int assignmentId;
  final String itemName;

  const UsageDetailsDialog({
    super.key,
    required this.assignmentId,
    required this.itemName,
  });

  @override
  State<UsageDetailsDialog> createState() => _UsageDetailsDialogState();
}

class _UsageDetailsDialogState extends State<UsageDetailsDialog> {
  bool _isLoading = true;
  List<StaffOpenInventoryResponse> _usageDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await Provider.of<InventoryProvider>(context, listen: false)
          .fetchOpenedProductsCounts(widget.assignmentId);
      setState(() {
        _usageDetails = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Usage Details: ${widget.itemName}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
              )
            else if (_usageDetails.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text("No usage records found.", style: TextStyle(color: Colors.grey)),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _usageDetails.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final usage = _usageDetails[index];
                    final openDate = usage.openedAt != null 
                        ? DateFormat("dd MMM, hh:mm a").format(usage.openedAt!.toLocal())
                        : "N/A";
                    final finishDate = usage.finishedAt != null 
                        ? DateFormat("dd MMM, hh:mm a").format(usage.finishedAt!.toLocal())
                        : "Active";

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Opened: $openDate",
                                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: usage.isFinished ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  usage.isFinished ? "FINISHED" : "OPENED",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: usage.isFinished ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildPopupStat("Quantity", usage.openedQuantity.toStringAsFixed(1)),
                              const SizedBox(width: 20),
                              _buildPopupStat("Appointments", "${usage.appointmentCount ?? 0}"),
                            ],
                          ),
                          if (usage.isFinished) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Finished at: $finishDate",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                          if (usage.notes != null && usage.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Note: ${usage.notes}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}
