import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1615) : const Color(0xFFF7F5F0);
    final cardBgColor = isDark ? const Color(0xFF162220) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'تنظیمات',
          style: AppTypography.appBarTitle.copyWith(color: textColor),
        ),
        backgroundColor: cardBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildCard(
            context: context,
            child: Column(
              children: [
                // Audio Downloads
                _buildSettingsTile(
                  context: context,
                  icon: CupertinoIcons.arrow_down_circle_fill,
                  title: 'مدیریت دانلودهای صوتی',
                  subtitle: 'دانلود و مدیریت صوت قاریان و ترجمه‌ها',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  onTap: () => context.pushNamed(audioDownloadManagerRoute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162220) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAE7E3);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.goldMetallic, size: 26),
      title: Text(title, style: AppTypography.sectionHeader.copyWith(color: textColor)),
      subtitle: Text(subtitle, style: AppTypography.captionText.copyWith(color: subtitleColor)),
      trailing: Icon(CupertinoIcons.chevron_left, size: 16, color: subtitleColor),
      onTap: onTap,
    );
  }
}
