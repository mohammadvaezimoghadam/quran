import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import 'package:quran/common/extensions/int_extension.dart';
import 'package:quran/common/utils/jalali_date.dart';
import 'package:quran/common/widgets/app_snackbar.dart';
import 'package:quran/core/routes/route_name.dart';
import 'package:quran/core/theme/app_typography.dart';
import 'package:quran/features/surah_list/infrastructure/datasources/static_surahs_data.dart';
import 'package:quran/features/tafakor/application/controllers/tafakor_auth_controller.dart';
import 'package:quran/features/khatm/application/controllers/create_group_khatm_controller.dart';
import 'package:quran/features/khatm/application/controllers/group_khatm_list_controller.dart';
import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import '../widgets/shared/complete_name_bottom_sheet.dart';
import '../widgets/shared/group_khatm_share_sheet.dart';
import '../widgets/shared/guest_otp_bottom_sheet.dart';
import '../widgets/wizard/khatm_jalali_date_picker.dart';
import '../widgets/wizard/khatm_step_indicator.dart';
import '../widgets/wizard/khatm_wizard_navigation_buttons.dart';

/// Screen orchestrator for the 3-Step Group Khatm Creation Wizard («ایجاد ختم گروهی»).
/// Unified with the exact minimal Apple design language and component architecture
/// of the Personal Khatm wizard (CreateKhatmWizardScreen).
class CreateGroupKhatmScreen extends ConsumerStatefulWidget {
  const CreateGroupKhatmScreen({super.key});

  @override
  ConsumerState<CreateGroupKhatmScreen> createState() =>
      _CreateGroupKhatmScreenState();
}

class _CreateGroupKhatmScreenState
    extends ConsumerState<CreateGroupKhatmScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _countController = TextEditingController(
    text: '100',
  );

  int _currentStep = 0;
  bool _syndicateToTopic = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    HapticFeedback.lightImpact();
    setState(() => _currentStep = step);
  }

  void _handleNext() {
    if (_currentStep == 0) {
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        HapticFeedback.heavyImpact();
        AppSnackBar.showError(context, 'لطفاً نیت ختم را وارد کنید');
        return;
      }
      ref.read(createGroupKhatmControllerProvider.notifier).setTitle(title);
      ref
          .read(createGroupKhatmControllerProvider.notifier)
          .setDescription(_descController.text.trim());
      _goToStep(1);
    } else if (_currentStep == 1) {
      final state = ref.read(createGroupKhatmControllerProvider);
      if (state.unitType == GroupKhatmUnitType.surah) {
        if (state.targetSurah == null) {
          ref
              .read(createGroupKhatmControllerProvider.notifier)
              .setTargetSurah(36); // Default Yasin
        }
      }
      _goToStep(2);
    } else {
      _handleSubmit();
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppSnackBar.showError(context, 'لطفاً نیت ختم را وارد کنید');
      _goToStep(0);
      return;
    }

    final isAuthenticated = ref.read(isTafakorAuthenticatedProvider);
    if (!isAuthenticated) {
      final loggedIn = await GuestOtpBottomSheet.show(
        context,
        title: 'ورود به حساب تفکر',
        description:
            'برای ثبت و مدیریت ختم گروهی، لطفاً ابتدا وارد حساب خود شوید.',
      );
      if (!loggedIn || !mounted) return;
    }

    final currentUser = ref.read(tafakorUserProvider);
    if (currentUser == null || !currentUser.hasFullName) {
      final nameSaved = await CompleteNameBottomSheet.show(
        context,
        description:
            'برای ایجاد ختم گروهی و نمایش نام بانی ختم، لطفاً نام و نام خانوادگی خود را وارد کنید.',
      );
      if (!nameSaved || !mounted) return;
    }

    final notifier = ref.read(createGroupKhatmControllerProvider.notifier);
    notifier.setTitle(title);
    notifier.setDescription(_descController.text.trim());

    var campaign = await notifier.submit();

    if (campaign == null && mounted) {
      final submitState = ref.read(createGroupKhatmControllerProvider);
      if (submitState.errorCode == 'profile_name_required') {
        final nameSaved = await CompleteNameBottomSheet.show(
          context,
          description:
              'برای ایجاد ختم گروهی و نمایش نام بانی ختم، لطفاً نام و نام خانوادگی خود را وارد کنید.',
        );
        if (nameSaved && mounted) {
          campaign = await notifier.submit();
        }
      }
    }

    if (campaign != null && mounted) {
      final createdCampaign = campaign;
      HapticFeedback.mediumImpact();
      ref.read(groupKhatmListControllerProvider.notifier).refreshAll();

      context.pushReplacementNamed(
        groupKhatmDetailRoute,
        pathParameters: {'code': createdCampaign.inviteCode},
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GroupKhatmShareSheet.show(context, campaign: createdCampaign);
        }
      });
    } else if (mounted) {
      final error = ref.read(createGroupKhatmControllerProvider).errorMessage;
      if (error != null) {
        AppSnackBar.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createGroupKhatmControllerProvider);
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0) {
          _goToStep(_currentStep - 1);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ایجاد ختم گروهی',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: colors.cardBackground,
          leading: IconButton(
            tooltip: _currentStep > 0 ? 'مرحله قبل' : 'بازگشت',
            icon: Icon(
              CupertinoIcons.chevron_forward,
              size: 24,
              color: colorScheme.onSurface,
            ),
            splashRadius: 22,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_currentStep > 0) {
                _goToStep(_currentStep - 1);
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pop();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.8),
            child: Container(
              color: colors.cardBorder,
              height: 0.8,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── ۱. نوار وضعیت مراحل مشترک (KhatmStepIndicator) ──────────────
              KhatmStepIndicator(
                currentStep: _currentStep,
                stepLabels: const ['نیت ختم', 'تقسیم سهم‌ها', 'تایید نهایی'],
                onStepTapped: (idx) => _goToStep(idx),
              ),

              // ── ۲. محتوای گام فعال ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentStep(context, state, colors, colorScheme),
                  ),
                ),
              ),

              // ── ۳. دکمه‌های ناوبری استاندارد (KhatmWizardNavigationButtons) ──
              KhatmWizardNavigationButtons(
                isLoading: state.isSubmitting,
                isBackVisible: _currentStep > 0,
                nextLabel:
                    _currentStep == 2 ? 'ایجاد' : 'ادامه',
                onNext: _handleNext,
                onBack: () => _goToStep(_currentStep - 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(
    BuildContext context,
    CreateGroupKhatmState state,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Intention(context, state, colors, colorScheme);
      case 1:
        return _buildStep2UnitAllocation(context, state, colors, colorScheme);
      case 2:
        return _buildStep3Confirmation(context, state, colors, colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // گام ۱: اطلاعات و نیت ختم (مطابق KhatmTitleInput)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep1Intention(
    BuildContext context,
    CreateGroupKhatmState state,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final isDark = context.isDark;
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFEEEBE4);
    final inputBorder = BorderSide(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 0.8,
    );

    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // فیلد ۱: نیت ختم
        Text(
          'نیت ختم',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          maxLength: 50,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'مثلاً: هدیه به روح پدرم، سلامتی امام زمان (عج)',
            filled: true,
            fillColor: inputBg,
            hintStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: inputBorder,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: inputBorder,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 18),

        // فیلد ۲: توضیحات (اختیاری)
        Text(
          'توضیحات (اختیاری)',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          maxLength: 100,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            counterText: '',
            hintText:
                'متن دلخواه جهت نمایش به شرکت‌کنندگان، نیت ثواب و فاتحه...',
            filled: true,
            fillColor: inputBg,
            hintStyle: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: inputBorder,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: inputBorder,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // گام ۲: نحوه تقسیم سهم‌ها (مطابق استایل مینیمال اپل)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep2UnitAllocation(
    BuildContext context,
    CreateGroupKhatmState state,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final isDark = context.isDark;
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFEEEBE4);
    final inputBorder = BorderSide(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 0.8,
    );

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'نحوه تقسیم سهم‌ها',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        // گزینه ۱: ۳۰ جزء کامل قرآن کریم
        _buildUnitSelectionTile(
          context: context,
          title: '۳۰ جزء قرآن کریم',
          subtitle: '۳۰ سهم • هر شرکت‌کننده یک جزء کامل (حدود ۲۰ صفحه)',
          isSelected: state.unitType == GroupKhatmUnitType.juz,
          onTap: () {
            ref
                .read(createGroupKhatmControllerProvider.notifier)
                .setUnitType(GroupKhatmUnitType.juz);
          },
          inputBg: inputBg,
          inputBorder: inputBorder,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 10),

        // گزینه ۲: ۱۲۰ حزب قرآن کریم
        _buildUnitSelectionTile(
          context: context,
          title: '۱۲۰ حزب قرآن کریم',
          subtitle: '۱۲۰ سهم • سهم‌های کوتاه‌تر (حدود ۵ صفحه) برای قرائت سریع',
          isSelected: state.unitType == GroupKhatmUnitType.hizb,
          onTap: () {
            ref
                .read(createGroupKhatmControllerProvider.notifier)
                .setUnitType(GroupKhatmUnitType.hizb);
          },
          inputBg: inputBg,
          inputBorder: inputBorder,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 10),

        // گزینه ۳: ختم یک سوره مشخص
        _buildUnitSelectionTile(
          context: context,
          title: 'ختم یک سوره مشخص',
          subtitle: 'تعداد دلخواه • قرائت مکرر یک سوره (یس، واقعه، الرحمن، ملک)',
          isSelected: state.unitType == GroupKhatmUnitType.surah,
          onTap: () {
            ref
                .read(createGroupKhatmControllerProvider.notifier)
                .setUnitType(GroupKhatmUnitType.surah);
          },
          inputBg: inputBg,
          inputBorder: inputBorder,
          colorScheme: colorScheme,
        ),

        // در صورت انتخاب سوره مشخص: انتخاب سوره و تعداد
        if (state.unitType == GroupKhatmUnitType.surah) ...[
          const SizedBox(height: 18),
          Text(
            'سوره مبارکه',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: state.targetSurah ?? 36,
            dropdownColor: colors.cardBackground,
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: inputBorder,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: inputBorder,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            items: kStaticQuranSurahs.map((s) {
              return DropdownMenuItem<int>(
                value: s.number,
                child: Text(
                  '${s.number.toPersianDigit()}. سوره ${s.name} (${s.numberOfAyahs.toPersianDigit()} آیه)',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref
                    .read(createGroupKhatmControllerProvider.notifier)
                    .setTargetSurah(val);
              }
            },
          ),
          const SizedBox(height: 18),

          Text(
            'تعداد کل قرائت هدف',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStepperTextBtn(
                label: '−',
                onTap: () {
                  final current = int.tryParse(_countController.text) ?? 100;
                  if (current > 1) {
                    final next = current > 10 ? current - 10 : 1;
                    _countController.text = next.toString();
                    ref
                        .read(createGroupKhatmControllerProvider.notifier)
                        .setTargetCount(next);
                  }
                },
                inputBg: inputBg,
                inputBorder: inputBorder,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: inputBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: inputBorder,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val) ?? 100;
                    ref
                        .read(createGroupKhatmControllerProvider.notifier)
                        .setTargetCount(parsed);
                  },
                ),
              ),
              const SizedBox(width: 8),
              _buildStepperTextBtn(
                label: '+',
                onTap: () {
                  final current = int.tryParse(_countController.text) ?? 100;
                  final next = current + 10;
                  _countController.text = next.toString();
                  ref
                      .read(createGroupKhatmControllerProvider.notifier)
                      .setTargetCount(next);
                },
                inputBg: inputBg,
                inputBorder: inputBorder,
                colorScheme: colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // چیپ‌های متنی آماده
          Wrap(
            spacing: 8,
            children: [14, 40, 100, 1000].map((count) {
              final isSelected = state.targetCount == count ||
                  _countController.text == count.toString();
              return ActionChip(
                label: Text('${count.toPersianDigit()} بار'),
                backgroundColor: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : inputBg,
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                ),
                labelStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _countController.text = count.toString();
                  ref
                      .read(createGroupKhatmControllerProvider.notifier)
                      .setTargetCount(count);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // گام ۳: مهلت و تایید نهایی (مطابق KhatmConfirmationCard)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep3Confirmation(
    BuildContext context,
    CreateGroupKhatmState state,
    dynamic colors,
    ColorScheme colorScheme,
  ) {
    final isDark = context.isDark;
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFEEEBE4);
    final inputBorder = BorderSide(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 0.8,
    );

    String unitSummary;
    if (state.unitType == GroupKhatmUnitType.juz) {
      unitSummary = '۳۰ جزء کامل قرآن کریم';
    } else if (state.unitType == GroupKhatmUnitType.hizb) {
      unitSummary = '۱۲۰ حزب قرآن کریم';
    } else {
      final surah = kStaticQuranSurahs.firstWhere(
        (s) => s.number == (state.targetSurah ?? 36),
        orElse: () => kStaticQuranSurahs.first,
      );
      unitSummary =
          '${state.targetCount.toPersianDigit()} بار سوره مبارکه ${surah.name}';
    }

    final currentJalali = state.deadline != null
        ? JalaliDate.fromDateTime(state.deadline!)
        : JalaliDate.fromDateTime(DateTime.now().add(const Duration(days: 30)));

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // مهلت پایان ختم با تاریخ شمسی
        KhatmJalaliDatePicker(
          label: 'مهلت پایان ختم',
          selectedDate: currentJalali,
          onDateChanged: (jalali) {
            ref
                .read(createGroupKhatmControllerProvider.notifier)
                .setDeadline(jalali.toDateTime());
          },
        ),
        const SizedBox(height: 16),

        // ردیف تنظیم دسترسی به ختم (ویترین عمومی / اختصاصی)
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.fromBorderSide(inputBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نمایش عمومی',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'در صورت خاموش بودن، ختم فقط با لینک دعوت قابل مشاهده است',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: state.isPublic,
                activeTrackColor: colorScheme.primary,
                onChanged: (val) {
                  ref
                      .read(createGroupKhatmControllerProvider.notifier)
                      .setIsPublic(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ردیف انتشار در تاپیک تفکر
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.fromBorderSide(inputBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'انتشار در تاپیک تفکر',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اشتراک خودکار با اعضای انجمن تفکر جهت مشارکت سریع‌تر',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: _syndicateToTopic,
                activeTrackColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() => _syndicateToTopic = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── کارت خلاصه مشخصات ختم (مشابه KhatmConfirmationCard) ───
        Container(
          decoration: BoxDecoration(
            color: colors.cardBackgroundSubtle,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'خلاصه مشخصات ختم گروهی',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اطلاعات زیر را بررسی و تایید کنید',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              Container(
                height: 0.8,
                color: colors.cardBorder.withValues(alpha: 0.4),
                margin: const EdgeInsets.symmetric(vertical: 16),
              ),
              _buildSummaryRow(
                label: 'نیت ختم:',
                value: _titleController.text.isNotEmpty
                    ? _titleController.text.trim()
                    : 'بدون عنوان',
                valueColor: colorScheme.primary,
                colorScheme: colorScheme,
              ),
              if (_descController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildSummaryRow(
                  label: 'توضیحات:',
                  value: _descController.text.trim(),
                  colorScheme: colorScheme,
                ),
              ],
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'نحوه تقسیم سهم‌ها:',
                value: unitSummary,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'وضعیت مشاهده:',
                value: state.isPublic
                    ? 'عمومی (قابل مشاهده برای همه)'
                    : 'اختصاصی (فقط با لینک دعوت)',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 10),
              _buildSummaryRow(
                label: 'مهلت تکمیل:',
                value: currentJalali.formatLong(),
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ویجت‌های کمکی فلت و مینیمال
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildUnitSelectionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color inputBg,
    required BorderSide inputBorder,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : inputBorder.color,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            // رادیوی مینیمال
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  width: isSelected ? 5.5 : 1.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperTextBtn({
    required String label,
    required VoidCallback onTap,
    required Color inputBg,
    required BorderSide inputBorder,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.fromBorderSide(inputBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
