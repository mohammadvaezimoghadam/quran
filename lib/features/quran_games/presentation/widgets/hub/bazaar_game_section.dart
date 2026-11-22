import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran/common/extensions/context_extension.dart';
import '../../../domain/models/quran_game_item.dart';
import 'bazaar_game_card.dart';

/// ردیف افقی شامل هدر بخش و لیست اسکرول افقی کارت‌های بازی کافه‌بازار
class BazaarGameSection extends StatelessWidget {
  final QuranGameSection section;
  final ValueChanged<QuranGameItem> onGameTap;
  final VoidCallback? onActionTap;

  const BazaarGameSection({
    super.key,
    required this.section,
    required this.onGameTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // هدر بخش
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title & optional tag (آگهی / ویژه)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (section.tag != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        section.tag!,
                        style: const TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFB300),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Action button (بیشتر <)
              if (section.actionText.isNotEmpty)
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          section.actionText,
                          style: TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          CupertinoIcons.chevron_left,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 6.0),

        // لیست اسکرول افقی کارت‌ها
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: section.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14.0),
            itemBuilder: (context, index) {
              final game = section.items[index];
              return BazaarGameCard(
                item: game,
                onTap: () => onGameTap(game),
              );
            },
          ),
        ),
      ],
    );
  }
}
