import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/features/khatm/domain/entities/group_khatm_campaign.dart';

/// Viral post-creation invitation BottomSheet displayed right after a Group Khatm is created.
/// Features short link preview, copy, messaging apps, and "I will take the first part myself".
class GroupKhatmShareSheet extends StatelessWidget {
  final GroupKhatmCampaign campaign;
  final VoidCallback? onTakeFirstSlot;

  const GroupKhatmShareSheet({
    super.key,
    required this.campaign,
    this.onTakeFirstSlot,
  });

  static Future<void> show(
    BuildContext context, {
    required GroupKhatmCampaign campaign,
    VoidCallback? onTakeFirstSlot,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GroupKhatmShareSheet(
        campaign: campaign,
        onTakeFirstSlot: onTakeFirstSlot,
      ),
    );
  }

  String get _inviteUrl => 'https://tafakormag.ir/k/${campaign.inviteCode}';

  String get _inviteMessage {
    return 'سلام و عرض ادب\nشما به ختم گروهی «${campaign.title}» دعوت شده‌اید.\nبرای انتخاب سهم و همراهی در این امر معنوی روی پیوند زیر بزنید:\n$_inviteUrl';
  }

  Future<void> _launchAppUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(_inviteMessage);
      }
    } catch (_) {
      await Share.share(_inviteMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Celebratory Icon & Title
          Icon(
            CupertinoIcons.checkmark_seal_fill,
            size: 40,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'ختم گروهی با موفقیت ساخته شد',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'با دعوت از دوستان و خانواده، این ختم نورانی را سریع‌تر به پایان برسانید.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          // Short link box with copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.cardBackgroundSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'کپی پیوند',
                  icon: Icon(CupertinoIcons.doc_on_doc, size: 20, color: colorScheme.primary),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: _inviteUrl));
                    AppSnackBar.showSuccess(context, 'پیوند ختم کپی شد');
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _inviteUrl,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick share buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareIconButton(
                context,
                title: 'ایتا',
                icon: CupertinoIcons.chat_bubble_2_fill,
                onTap: () {
                  final url = 'https://eitaa.com/share/url?url=${Uri.encodeComponent(_inviteUrl)}&text=${Uri.encodeComponent(_inviteMessage)}';
                  _launchAppUrl(context, url);
                },
              ),
              _buildShareIconButton(
                context,
                title: 'بله',
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                onTap: () {
                  final url = 'https://ble.ir/share/url?url=${Uri.encodeComponent(_inviteUrl)}&text=${Uri.encodeComponent(_inviteMessage)}';
                  _launchAppUrl(context, url);
                },
              ),
              _buildShareIconButton(
                context,
                title: 'تلگرام',
                icon: CupertinoIcons.paperplane_fill,
                onTap: () {
                  final url = 'https://t.me/share/url?url=${Uri.encodeComponent(_inviteUrl)}&text=${Uri.encodeComponent(_inviteMessage)}';
                  _launchAppUrl(context, url);
                },
              ),
              _buildShareIconButton(
                context,
                title: 'پیامک',
                icon: CupertinoIcons.envelope_fill,
                onTap: () {
                  final url = 'sms:?body=${Uri.encodeComponent(_inviteMessage)}';
                  _launchAppUrl(context, url);
                },
              ),
              _buildShareIconButton(
                context,
                title: 'سایر',
                icon: CupertinoIcons.share,
                onTap: () => Share.share(_inviteMessage),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Secondary CTA: "اولین جزء را خودم برمی‌دارم"
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onTakeFirstSlot?.call();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.cardBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'اولین جزء را خودم برمی‌دارم',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildShareIconButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.cardBackgroundSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(icon, size: 20, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
