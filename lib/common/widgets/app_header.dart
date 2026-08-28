import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// AppHeader - Shared fixed header component for Hayat UI
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final bool showNotificationIcon;
  final Widget? customAction;

  const AppHeader({
    super.key,
    this.title = 'خانه',

    this.onNotificationTap,
    this.onAvatarTap,
    this.showNotificationIcon = true,
    this.customAction,
  });

  // Design Tokens (Hayat Modular System)
  static const Color bgSurface = Color(0xFF131313);
  static const Color containerHigh = Color(0xFF2A2A2A);
  static const Color primaryGreen = Color(0xFFB4CCBB);
  static const Color textPrimary = Color(0xFFE5E2E1);
  static const Color textSecondary = Color(0xFFC2C8C2);
  static const Color outlineVariant = Color(0xFF424843);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgSurface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar (Right in RTL / Start)
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: containerHigh,
              ),
              child: const ClipOval(
                child: Center(
                  child: Icon(
                    CupertinoIcons.person_fill,
                    color: textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),

          // Action / Notification Icon
          if (customAction != null)
            customAction!
          else if (showNotificationIcon)
            IconButton(
              onPressed: onNotificationTap ?? () {},
              icon: const Icon(
                CupertinoIcons.bell,
                color: textSecondary,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(66);
}
