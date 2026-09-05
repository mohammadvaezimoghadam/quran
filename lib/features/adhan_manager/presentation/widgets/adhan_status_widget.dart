import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/controllers/adhan_settings_controller.dart';
import 'adhan_quick_settings_dialog.dart';

class AdhanStatusWidget extends ConsumerWidget {
  const AdhanStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adhanSettingsControllerProvider);

    // Check if at least one adhan is enabled
    final isAnyEnabled = state.isGlobalEnabled && (
      state.isFajrEnabled ||
      state.isDhuhrEnabled ||
      state.isAsrEnabled ||
      state.isMaghribEnabled ||
      state.isIshaEnabled
    );

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const AdhanQuickSettingsDialog(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Icon(
          isAnyEnabled ? CupertinoIcons.volume_up : CupertinoIcons.volume_off,
          color: isAnyEnabled ? AppColors.goldMetallic : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}
