import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/theme/app_dimens.dart';

class SurahErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const SurahErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.marginPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: context.colorScheme.error,
              size: 48,
            ),
            AppDimens.stackMd.vSpace,
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            AppDimens.stackLg.vSpace,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text(AppConstants.retryButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
