import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';

/// Shared form body for collecting the user's required first & last name.
/// Reused by both [CompleteNameBottomSheet] and [GuestOtpBottomSheet] so validation
/// and persistence stay in one place.
class CompleteNameFormContent extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String submitLabel;
  final VoidCallback onCompleted;

  const CompleteNameFormContent({
    super.key,
    required this.title,
    required this.description,
    this.submitLabel = 'ذخیره و ادامه',
    required this.onCompleted,
  });

  @override
  ConsumerState<CompleteNameFormContent> createState() =>
      _CompleteNameFormContentState();
}

class _CompleteNameFormContentState
    extends ConsumerState<CompleteNameFormContent> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();

  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final user = ref.read(tafakorUserProvider);
    if (user != null) {
      if (user.firstName.trim().isNotEmpty) {
        _firstNameController.text = user.firstName.trim();
      }
      if (user.lastName.trim().isNotEmpty) {
        _lastNameController.text = user.lastName.trim();
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorText = 'لطفاً نام و نام خانوادگی خود را به‌طور کامل وارد کنید.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final ok = await ref
        .read(tafakorAuthControllerProvider.notifier)
        .updateProfile(firstName: firstName, lastName: lastName);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      HapticFeedback.mediumImpact();
      widget.onCompleted();
    } else {
      final serverErr = ref.read(tafakorAuthControllerProvider).error?.message;
      setState(() {
        _errorText =
            serverErr ?? 'خطا در ذخیره اطلاعات؛ لطفاً دوباره تلاش کنید.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _firstNameController,
          focusNode: _firstNameFocus,
          autofocus: true,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.next,
          maxLength: 50,
          onSubmitted: (_) => _lastNameFocus.requestFocus(),
          decoration: _inputDecoration(
            context: context,
            label: 'نام',
            hint: 'مثلاً: علی',
            colors: colors,
            colorScheme: colorScheme,
          ),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lastNameController,
          focusNode: _lastNameFocus,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.done,
          maxLength: 50,
          onSubmitted: (_) => _submit(),
          decoration: _inputDecoration(
            context: context,
            label: 'نام خانوادگی',
            hint: 'مثلاً: رضایی',
            colors: colors,
            colorScheme: colorScheme,
          ),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 10,
                  )
                : Text(
                    widget.submitLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required dynamic colors,
    required ColorScheme colorScheme,
  }) {
    return InputDecoration(
      counterText: '',
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 13,
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 13,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
      ),
      filled: true,
      fillColor: colors.cardBackgroundSubtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.3),
      ),
    );
  }
}

/// Minimal Sacred-Serenity bottom sheet requiring first_name and last_name
/// before creating or joining a Group Khatm campaign.
class CompleteNameBottomSheet extends StatelessWidget {
  final String title;
  final String description;

  const CompleteNameBottomSheet({
    super.key,
    required this.title,
    required this.description,
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'تکمیل نام و نام خانوادگی',
    String description =
        'برای شرکت در ختم گروهی و نمایش نام شما به همراهان، لطفاً نام و نام خانوادگی خود را وارد کنید.',
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CompleteNameBottomSheet(
        title: title,
        description: description,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 16),
              CompleteNameFormContent(
                title: title,
                description: description,
                onCompleted: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
