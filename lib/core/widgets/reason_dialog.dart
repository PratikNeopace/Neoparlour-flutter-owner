import 'package:flutter/material.dart';

class ReasonDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final List<String> predefinedReasons;
  final String confirmText;
  final Color confirmColor;

  const ReasonDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.predefinedReasons,
    this.confirmText = "CONFIRM",
    this.confirmColor = const Color(0XFFFF0B01),
  });

  @override
  State<ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<ReasonDialog> {
  String? _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Select Reason",
                border: OutlineInputBorder(),
              ),
              items: widget.predefinedReasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedReason = val;
                });
              },
            ),
            if (_selectedReason == "Other") ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customReasonController,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                ),
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedReason == null) return;
            
            final reason = _selectedReason == "Other" 
                ? _customReasonController.text 
                : _selectedReason;
                
            if (reason!.trim().isEmpty) return;
            
            Navigator.pop(context, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.confirmColor,
          ),
          child: Text(widget.confirmText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
