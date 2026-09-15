import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../application/controllers/quick_access_controller.dart';
import '../../domain/entities/quick_access_tool_entity.dart';
import 'pinned_surah_picker_bottom_sheet.dart';

class QuickAccessPickerBottomSheet extends ConsumerWidget {
  final int slotIndex;

  const QuickAccessPickerBottomSheet({
    super.key,
    required this.slotIndex,
  });

  static Future<void> show(BuildContext context, int slotIndex) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAccessPickerBottomSheet(slotIndex: slotIndex),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final controller = ref.read(quickAccessControllerProvider.notifier);
    final availableTools = controller.getAvailableToolsForPicker();

    return Container(
      decoration: BoxDecoration(
        color: colors.dialogSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            16.vSpace,

            // Sheet Title
            Row(
              children: [
                48.hSpace,
                const Expanded(
                  child: Text(
                    'انتخاب ابزار برای این جایگاه',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'بستن',
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 24,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            12.vSpace,

            if (availableTools.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    'تمام ابزارهای در دسترس هم‌اکنون در جایگاه‌ها قرار دارند.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableTools.length,
                separatorBuilder: (context, index) => 6.vSpace,
                itemBuilder: (context, index) {
                  final tool = availableTools[index];

                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      if (tool.type == QuickAccessToolType.pinnedSurah) {
                        PinnedSurahPickerBottomSheet.show(
                          context,
                          slotIndex: slotIndex,
                        );
                      } else {
                        await controller.assignToolToSlot(slotIndex, tool.type);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorScheme.primary
                                  .withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                            ),
                            child: Icon(
                              tool.iconData,
                              color: colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          14.hSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tool.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!tool.isReady) ...[
                                      8.hSpace,
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                                        ),
                                        child: const Text(
                                          'به‌زودی',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                4.vSpace,
                                Text(
                                  tool.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_left,
                            size: 16,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
