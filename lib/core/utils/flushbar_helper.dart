import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class FlushbarHelper {
  static Flushbar? _currentFlushbar;

  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    if (!context.mounted) return;

    // Clean up generic exception prefixes for a better UI experience
    String cleanMessage = message;
    if (cleanMessage.startsWith("Error: Exception: ")) {
      cleanMessage = cleanMessage.substring(18);
    } else if (cleanMessage.startsWith("Exception: ")) {
      cleanMessage = cleanMessage.substring(11);
    } else if (cleanMessage.startsWith("Error: ")) {
      cleanMessage = cleanMessage.substring(7);
    }

    // Dismiss any existing flushbar to prevent overlay stacking
    if (_currentFlushbar != null && _currentFlushbar!.isShowing()) {
      _currentFlushbar!.dismiss();
    }

    _currentFlushbar = Flushbar(
      message: cleanMessage,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor:
          isSuccess ? Colors.green : Colors.red,

      // ✅ Correct responsive positioning
      margin: const EdgeInsets.symmetric(horizontal: 16)
          .copyWith(top: kToolbarHeight + 16),

      borderRadius: BorderRadius.circular(8),
      duration: const Duration(seconds: 3),
      messageColor: Colors.white,
    );

    _currentFlushbar!.show(context);
  }
}