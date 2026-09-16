import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/network/network_info_helper.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../download_manager/infrastructure/datasources/download_manager_local_datasource.dart';
import '../../../subscription/application/vip_subscription_controller.dart';
import '../../../subscription/domain/policy/audio_vip_policy.dart';
import '../../../subscription/presentation/widgets/vip_required_dialog.dart';
import '../../../subscription/presentation/utils/audio_vip_helper.dart';
import '../../application/states/download_manager_state.dart';
import '../../application/states/download_manager_selected_surahs_provider.dart';
import '../../application/controllers/audio_download_controller.dart';

class DownloadManagerActionBar extends ConsumerWidget {
  const DownloadManagerActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(downloadManagerSelectedReciterProvider);
    final selectedSurahs = ref.watch(downloadManagerSelectedSurahsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = selectedReciter != null && selectedSurahs.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () async {
                  final isWifiOnly = ref
                      .read(downloadManagerLocalDataSourceProvider)
                      .getWifiOnlyPreference();
                  if (isWifiOnly) {
                    final isWifi = await NetworkInfoHelper.isWifiConnected();
                    if (!isWifi) {
                      if (context.mounted) {
                        AppSnackBar.showError(
                          context,
                          'تنظیم «فقط با وای‌فای» فعال است اما دستگاه به وای‌فای متصل نیست.',
                        );
                      }
                      return;
                    }
                  }

                  final isVip = ref.read(hasVipAccessProvider);
                  final isTranslation = selectedReciter.styleId == 4;

                  final permittedSurahs = <int>[];
                  final lockedSurahs = <int>[];

                  for (final sId in selectedSurahs) {
                    final allowed = isTranslation
                        ? AudioVipPolicy.canPlayAudioTranslation(isVip: isVip)
                        : AudioVipPolicy.canPlayReciter(
                            reciterIdentifier: selectedReciter.identifier,
                            surahId: sId,
                            isVip: isVip,
                          );
                    if (allowed) {
                      permittedSurahs.add(sId);
                    } else {
                      lockedSurahs.add(sId);
                    }
                  }

                  if (lockedSurahs.isNotEmpty && permittedSurahs.isEmpty) {
                    if (context.mounted) {
                      if (isTranslation) {
                        VipRequiredDialog.show(
                          context: context,
                          reciterName: selectedReciter.name,
                          isTranslation: true,
                        );
                      } else {
                        AudioVipHelper.checkAndPromptVip(
                          context: context,
                          ref: ref,
                          surahId: lockedSurahs.first,
                          targetReciter: selectedReciter,
                        );
                      }
                    }
                    return;
                  }

                  final surahCount = permittedSurahs.length;
                  for (final surahId in permittedSurahs) {
                    ref
                        .read(audioDownloadControllerProvider.notifier)
                        .startDownload(
                          reciter: selectedReciter,
                          surahId: surahId,
                        );
                  }
                  ref
                      .read(downloadManagerSelectedSurahsProvider.notifier)
                      .setSurahs({});

                  if (context.mounted) {
                    if (lockedSurahs.isNotEmpty) {
                      AppSnackBar.showWarning(
                        context,
                        'دانلود ${surahCount.toPersianDigit()} سوره رایگان شروع شد. دانلود سایر سوره‌ها با صدای ${selectedReciter.name} نیازمند اشتراک VIP است.',
                      );
                      VipRequiredDialog.show(
                        context: context,
                        reciterName: selectedReciter.name,
                        isTranslation: isTranslation,
                      );
                    } else {
                      AppSnackBar.showSuccess(
                        context,
                        'دانلود ${surahCount.toPersianDigit()} سوره شروع شد.',
                      );
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
            disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            selectedSurahs.isEmpty
                ? 'لطفاً سوره‌های مورد نظر را انتخاب کنید'
                : 'دانلود ${selectedSurahs.length.toPersianDigit()} سوره انتخاب شده',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: isEnabled 
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
          ),
        ),
      ),
    );
  }
}
