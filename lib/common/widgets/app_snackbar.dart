import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: action,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );

    // Guaranteed forced dismissal after duration
    Future.delayed(duration + const Duration(milliseconds: 200), () {
      messenger.hideCurrentSnackBar();
    });
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green.shade600, CupertinoIcons.checkmark_circle);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red.shade600, CupertinoIcons.exclamationmark_circle);
  }

  static void showInfo(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      Colors.blue.shade600,
      CupertinoIcons.info_circle,
      action: action,
      duration: duration,
    );
  }
}
