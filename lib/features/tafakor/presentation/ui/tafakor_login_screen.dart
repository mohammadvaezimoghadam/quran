import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/tafakor_auth_controller.dart';
import '../../domain/entities/tafakor_auth_state.dart';

/// Formatter that automatically converts English/Arabic digits to Persian digits.
class PersianNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final converted = newValue.text.toPersianDigit();
    return TextEditingValue(
      text: converted,
      selection: newValue.selection,
    );
  }
}

class TafakorLoginScreen extends ConsumerStatefulWidget {
  const TafakorLoginScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TafakorLoginScreen()),
    );
  }

  @override
  ConsumerState<TafakorLoginScreen> createState() => _TafakorLoginScreenState();
}

class _TafakorLoginScreenState extends ConsumerState<TafakorLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();
  final _smartAuth = SmartAuth.instance;

  @override
  void dispose() {
    _smartAuth.removeUserConsentApiListener();
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _listenForSms() async {
    try {
      final res = await _smartAuth.getSmsWithUserConsentApi();
      if (res.hasData && res.data?.code != null) {
        if (mounted) {
          final code = res.data!.code!;
          _otpController.text = code.toPersianDigit();
          // Pinput triggers onCompleted automatically upon setting text
        }
      }
    } catch (e) {
      debugPrint('[SmartAuth] Error listening for SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TafakorAuthState>(tafakorAuthControllerProvider, (prev, next) {
      if (prev?.isCodeSent != true && next.isCodeSent) {
        _listenForSms();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _otpFocus.requestFocus();
        });
      }

      if (next.error != null && next.error != prev?.error) {
        HapticFeedback.heavyImpact();
        AppSnackBar.showError(context, next.error!.message);
      }

      if (prev?.user == null && next.user != null) {
        HapticFeedback.mediumImpact();
        AppSnackBar.showSuccess(context, 'ورود با موفقیت انجام شد');
        Navigator.of(context).pop(true);
      }
    });

    final authState = ref.watch(tafakorAuthControllerProvider);
    final controller = ref.read(tafakorAuthControllerProvider.notifier);

    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: 'بازگشت',
            icon: Icon(
              CupertinoIcons.chevron_forward,
              size: 22,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      !authState.isCodeSent ? 'ورود به تفکر' : 'کد تأیید',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    8.vSpace,
                    if (!authState.isCodeSent)
                      Text(
                        'شماره موبایل خود را وارد کنید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          color: isDark ? Colors.white60 : colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ارسال‌شده به ${(authState.phone ?? "").toPersianDigit()}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.5,
                              color: isDark ? Colors.white60 : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          8.hSpace,
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _smartAuth.removeUserConsentApiListener();
                              _otpController.clear();
                              controller.resetToPhoneInput();
                            },
                            child: Text(
                              'ویرایش',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    32.vSpace,

                    // Step 1: Phone input
                    if (!authState.isCodeSent) ...[
                      _buildPhoneStep(context, authState, controller, colorScheme, colors, isDark),
                    ] else ...[
                      // Step 2: OTP input
                      _buildOtpStep(context, authState, controller, colorScheme, colors, isDark),
                    ],
                    28.vSpace,
                    _buildPrivacyNotice(context, colorScheme, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(
    BuildContext context,
    TafakorAuthState state,
    TafakorAuthController controller,
    ColorScheme colorScheme,
    dynamic colors,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            PersianNumberFormatter(),
            LengthLimitingTextInputFormatter(11),
          ],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '۰۹xxxxxxxxx',
            hintStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              letterSpacing: 1.0,
              color: isDark
                  ? Colors.white30
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.40),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E1E22)
                : const Color(0xFFF3F3F5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) {
            if (!state.isLoading) {
              controller.requestOtp(_phoneController.text.toEnglishDigit());
            }
          },
        ),
        20.vSpace,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: state.isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  controller.requestOtp(_phoneController.text.toEnglishDigit());
                },
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'دریافت کد',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(
    BuildContext context,
    TafakorAuthState state,
    TafakorAuthController controller,
    ColorScheme colorScheme,
    dynamic colors,
    bool isDark,
  ) {
    final minutes = (state.resendCountdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.resendCountdown % 60).toString().padLeft(2, '0');
    final formattedTimer = '$minutes:$seconds'.toPersianDigit();

    final pinBoxColor = isDark
        ? const Color(0xFF1E1E22)
        : const Color(0xFFF3F3F5);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: pinBoxColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: pinBoxColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: pinBoxColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            controller: _otpController,
            focusNode: _otpFocus,
            length: 4,
            autofocus: true,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            keyboardType: TextInputType.number,
            inputFormatters: [PersianNumberFormatter()],
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            onCompleted: (pin) {
              if (!state.isLoading) {
                HapticFeedback.mediumImpact();
                controller.verifyOtp(pin.toEnglishDigit());
              }
            },
          ),
        ),
        20.vSpace,
        Center(
          child: state.resendCountdown > 0
              ? Text(
                  '$formattedTimer تا ارسال مجدد',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : colorScheme.onSurfaceVariant,
                  ),
                )
              : TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          _smartAuth.removeUserConsentApiListener();
                          controller.resendOtp();
                          _listenForSms();
                        },
                  child: Text(
                    'ارسال مجدد کد',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
        ),
        20.vSpace,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: state.isLoading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  controller.verifyOtp(_otpController.text.toEnglishDigit());
                },
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'ورود',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNotice(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showPrivacyPolicyDialog(context, isDark),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text.rich(
              TextSpan(
                text: 'ورود به تفکر به منزله پذیرش ',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  height: 1.5,
                  color: isDark
                      ? Colors.white54
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
                children: [
                  TextSpan(
                    text: 'قوانین و حریم خصوصی',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const TextSpan(text: ' است.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'سیاست حریم خصوصی و امنیت',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'شماره تلفن همراه شما صرفاً جهت احراز هویت، ورود امن و همگام‌سازی ابری یادداشت‌ها و دفاتر تدبر در پلتفرم تفکر استفاده می‌شود.\n\n'
            'ما متعهد به حفظ محرمانگی و حریم خصوصی شما هستیم و اطلاعات شما هرگز در اختیار شخص یا سرویس ثالثی قرار نخواهد گرفت.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              height: 1.65,
              color: isDark
                  ? Colors.white70
                  : colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'متوجه شدم',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
