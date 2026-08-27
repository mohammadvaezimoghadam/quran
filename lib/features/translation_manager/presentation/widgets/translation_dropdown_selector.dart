import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/translation_manager_controller.dart';
import '../../domain/entities/translation_entity.dart';

class TranslationDropdownSelector extends ConsumerStatefulWidget {
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  const TranslationDropdownSelector({
    super.key,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ConsumerState<TranslationDropdownSelector> createState() =>
      _TranslationDropdownSelectorState();
}

class _TranslationDropdownSelectorState extends ConsumerState<TranslationDropdownSelector> {
  String? _selectedTranslationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(translationManagerControllerProvider).value;
      if (state != null && state.activeTranslationId != null && mounted) {
        setState(() {
          _selectedTranslationId = state.activeTranslationId;
        });
      }
    });
  }

  Future<void> _handleApply(BuildContext context, TranslationEntity translation) async {
    final controller = ref.read(translationManagerControllerProvider.notifier);

    if (!translation.isDownloaded) {
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'دانلود ترجمه',
            style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            'شما باید ترجمه «${translation.name}» را دانلود کنید. مایل به دانلود هستید؟',
            style: TextStyle(
                fontFamily: AppTypography.fontFamily, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'انصراف',
                style: TextStyle(fontFamily: AppTypography.fontFamily),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'دانلود و اعمال',
                style: TextStyle(fontFamily: AppTypography.fontFamily),
              ),
            ),
          ],
        ),
      );

      if (shouldDownload != true) return;

      setState(() {
        _selectedTranslationId = translation.id;
      });

      await controller.downloadTranslation(translation);

      final state = ref.read(translationManagerControllerProvider).value;
      final updatedTranslation =
          state?.translations.firstWhere((t) => t.id == translation.id);

      if (updatedTranslation == null || !updatedTranslation.isDownloaded) {
        // Revert selection on failure
        setState(() {
          _selectedTranslationId = null;
        });
        if (context.mounted) {
          AppSnackBar.showError(context, 'خطا در دانلود ترجمه');
        }
        return;
      }
    }

    setState(() {
      _selectedTranslationId = translation.id;
    });
    
    await controller.setActiveTranslation(translation.id);

    if (context.mounted) {
      AppSnackBar.showSuccess(context, 'ترجمه ${translation.name} با موفقیت اعمال شد');
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationManagerControllerProvider);
    final translations = translationState.value?.translations ?? [];
    final activeId = translationState.value?.activeTranslationId;

    if (translationState.isLoading || translations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final effectiveSelectedId = _selectedTranslationId ?? activeId ?? translations.first.id;

    

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book_outlined, size: 18.0, color: widget.accentColor),
                  8.0.hSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مترجم قرآن',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: widget.textPrimary,
                        ),
                      ),
                      Text(
                        'انتخاب مترجم رسمی',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          color: widget.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: effectiveSelectedId,
                        isExpanded: true,
                        dropdownColor: colorScheme.surfaceContainerHigh,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: widget.accentColor),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          color: widget.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        items: translations.map((translation) {
                          final managerState = ref.watch(translationManagerControllerProvider).value;
                          final progress = managerState?.downloadProgress[translation.id];
                          final isDownloading = progress != null;

                          Widget iconWidget;
                          if (translation.isDownloaded) {
                            iconWidget = Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              size: 12,
                              color: Colors.green.shade600,
                            );
                          } else if (isDownloading) {
                            iconWidget = SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 2,
                                backgroundColor: widget.accentColor.withOpacity(0.2),
                                color: widget.accentColor,
                              ),
                            );
                          } else {
                            iconWidget = Icon(
                              CupertinoIcons.cloud_download,
                              size: 12,
                              color: widget.textSecondary,
                            );
                          }

                          return DropdownMenuItem<String>(
                            value: translation.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: iconWidget,
                                ),
                                Expanded(
                                  child: Text(
                                    translation.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      color: widget.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (ref.watch(translationManagerControllerProvider).value?.downloadProgress.isNotEmpty == true) ? null : (newVal) {
                          if (newVal != null && newVal != effectiveSelectedId) {
                            final newTranslation = translations.firstWhere((t) => t.id == newVal);
                            _handleApply(context, newTranslation);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // The Apply/Download button has been completely removed as per user request.
          // Download logic is now handled directly inside the Dropdown's onChanged event.
        ],
      ),
    );
  }
}
