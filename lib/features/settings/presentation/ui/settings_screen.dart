import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/presentation/widgets/quick_settings_drawer.dart';
import '../../../translation_manager/presentation/widgets/translation_manager_bottom_sheet.dart';

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
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEAE7E3);

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
                // 1. Text & Quran Reader Display Settings
                _buildSettingsTile(
                  context: context,
                  icon: CupertinoIcons.textformat_size,
                  title: 'تنظیمات متن و قرائت',
                  subtitle: 'اندازه قلم، نوع خط، فاصله خطوط و رنگ اعراب',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  onTap: () => QuickSettingsDrawer.show(context),
                ),
                Divider(height: 1, color: dividerColor),

                // 2. Translation Management
                _buildSettingsTile(
                  context: context,
                  icon: CupertinoIcons.book_fill,
                  title: 'مدیریت ترجمه‌ها',
                  subtitle: 'انتخاب مترجم و تنظیمات نمایش ترجمه',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  onTap: () => TranslationManagerBottomSheet.show(context),
                ),
                Divider(height: 1, color: dividerColor),

                // 3. About Quran Tafakor
                _buildSettingsTile(
                  context: context,
                  icon: CupertinoIcons.info_circle_fill,
                  title: 'درباره قرآن تفکر',
                  subtitle: 'نسخه ۱.۰.۰',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'قرآن تفکر',
                      applicationVersion: '۱.۰.۰',
                      applicationIcon: const Icon(
                        CupertinoIcons.book,
                        size: 40,
                        color: AppColors.goldAccent,
                      ),
                      children: const [
                        Text(
                          'اپلیکیشن جامع قرآن تفکر با رسم‌الخط‌های استاندارد، ترجمه‌های معتبر و امکانات پیشرفته مطالعه قرآن کریم.',
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    );
                  },
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
