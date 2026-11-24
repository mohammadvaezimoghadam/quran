import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/extensions/string_extension.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';
import 'complete_name_bottom_sheet.dart';

/// Seamless BottomSheet for Guest users to quickly authenticate via OTP
/// and immediately resume their pending action (e.g. reserve slot or create group khatm).
class GuestOtpBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final String description;

  const GuestOtpBottomSheet({
    super.key,
    required this.title,
    required this.description,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GuestOtpBottomSheet(
        title: title,
        description: description,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<GuestOtpBottomSheet> createState() => _GuestOtpBottomSheetState();
}

class _GuestOtpBottomSheetState extends ConsumerState<GuestOtpBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();

  bool _isCodeSent = false;
  bool _isCompletingName = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    final phone = _phoneController.text.toEnglishDigit().trim();
    if (phone.length != 11 || !phone.startsWith('09')) {
      AppSnackBar.showError(context, 'شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود');
      return;
    }

    setState(() => _isLoading = true);
    final notifier = ref.read(tafakorAuthControllerProvider.notifier);
    final success = await notifier.requestOtp(phone);
    setState(() => _isLoading = false);

    if (success && mounted) {
      setState(() => _isCodeSent = true);
      _otpFocus.requestFocus();
    } else if (mounted) {
      final error = ref.read(tafakorAuthControllerProvider).error?.message;
      if (error != null) {
        AppSnackBar.showError(context, error);
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.toEnglishDigit().trim();
    if (otp.length != 4) {
      AppSnackBar.showError(context, 'کد تأیید باید ۴ رقم باشد');
      return;
    }

    setState(() => _isLoading = true);
    final notifier = ref.read(tafakorAuthControllerProvider.notifier);
    final success = await notifier.verifyOtp(otp);
    setState(() => _isLoading = false);

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      final user = ref.read(tafakorUserProvider);
      if (user != null && user.hasFullName) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isCompletingName = true);
      }
    } else if (mounted) {
      final error = ref.read(tafakorAuthControllerProvider).error?.message;
      if (error != null) {
        AppSnackBar.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(tafakorAuthControllerProvider);

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackgroundSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
    );

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
              const SizedBox(height: 16),

              if (_isCompletingName)
                CompleteNameFormContent(
                  title: 'تکمیل نام و نام خانوادگی',
                  description:
                      'برای مشارکت در ختم گروهی و نمایش نام شما، لطفاً نام و نام خانوادگی خود را وارد کنید.',
                  onCompleted: () => Navigator.of(context).pop(true),
                )
              else ...[
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
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                if (!_isCodeSent) ...[
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: '۰۹xxxxxxxxx',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: colors.cardBackgroundSubtle,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      onSubmitted: (_) => _handleRequestOtp(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRequestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                              radius: 10,
                            )
                          : Text(
                              'دریافت کد تأیید',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      controller: _otpController,
                      focusNode: _otpFocus,
                      length: 4,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: colorScheme.primary),
                        ),
                      ),
                      onCompleted: (_) => _handleVerifyOtp(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: authState.resendCountdown > 0
                            ? null
                            : () => _handleRequestOtp(),
                        child: Text(
                          authState.resendCountdown > 0
                              ? 'ارسال مجدد کد (${authState.resendCountdown.toPersianDigit()} ثانیه)'
                              : 'ارسال مجدد کد',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: authState.resendCountdown > 0
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isCodeSent = false;
                            _otpController.clear();
                          });
                        },
                        child: Text(
                          'تغییر شماره',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                              radius: 10,
                            )
                          : Text(
                              'تأیید و ادامه',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
