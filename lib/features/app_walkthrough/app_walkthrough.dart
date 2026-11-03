import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'application/walkthrough_controller.dart';
import 'domain/walkthrough_registry.dart';
import 'domain/walkthrough_target_id.dart';
import 'presentation/widgets/long_press_gesture_anim.dart';
import 'presentation/widgets/pinch_zoom_gesture_anim.dart';
import 'presentation/widgets/walkthrough_card_bubble.dart';

export 'domain/walkthrough_target_id.dart';
export 'presentation/walkthrough_anchor.dart';
export 'application/walkthrough_controller.dart';

/// Single, completely isolated entry point for the entire App Walkthrough feature.
class AppWalkthrough {
  /// Master switch to enable or disable in-app walkthrough globally
  static const bool isEnabled = true;


  // Active tour state guards to prevent concurrent/overlapping tours
  static bool _isHomeTourActive = false;
  static bool _isReaderTourActive = false;
  static bool _isAyahDialogTourActive = false;
  static bool _isTafakorNotesTourActive = false;
  static bool _isEditorTourActive = false;
  static bool _isStudySettingsTourActive = false;
  static bool _isAmbianceTourActive = false;
  static bool _isSleepTimerTourActive = false;

  /// Shows Home Screen walkthrough tour if not previously seen (or always in test mode).
  static void showHomeTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isHomeTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.home)) {
      return;
    }

    final targets = _buildHomeTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.home);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.home);
      },
    );

    if (targets.isEmpty) return;

    _isHomeTourActive = true;
    controller.markCompleted(WalkthroughTourKey.home);
    _showTutorial(
      context: context,
      targets: targets,
      onComplete: () {
        _isHomeTourActive = false;
        controller.markCompleted(WalkthroughTourKey.home);
      },
    );
  }

  /// Shows Quran Reader walkthrough tour if not previously seen (or always in test mode).
  static void showReaderTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isReaderTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.reader)) {
      return;
    }

    final targets = _buildReaderTargets(
      context: context,
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.reader);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.reader);
      },
    );

    if (targets.isEmpty) return;

    _isReaderTourActive = true;
    controller.markCompleted(WalkthroughTourKey.reader);
    _showTutorial(
      context: context,
      targets: targets,
      onComplete: () {
        _isReaderTourActive = false;
        controller.markCompleted(WalkthroughTourKey.reader);
      },
    );
  }

  /// Shows Ayah Action Bottom Sheet walkthrough tour for Tafakor item.
  static void showAyahDialogTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isAyahDialogTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.ayahDialog)) {
      return;
    }

    if (!WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.dialogTafakorItem)) {
      return;
    }

    final targets = _buildAyahDialogTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.ayahDialog);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.ayahDialog);
      },
    );

    if (targets.isEmpty) return;

    _isAyahDialogTourActive = true;
    controller.markCompleted(WalkthroughTourKey.ayahDialog);
    _showTutorial(
      context: context,
      targets: targets,
      rootOverlay: true,
      onComplete: () {
        _isAyahDialogTourActive = false;
        controller.markCompleted(WalkthroughTourKey.ayahDialog);
      },
    );
  }

  /// Shows Tafakor Community (Ayah Notes Sheet) walkthrough tour for the Write button.
  static void showTafakorNotesTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isTafakorNotesTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.tafakorNotes)) {
      return;
    }

    if (!WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.tafakorWriteButton)) {
      return;
    }

    final targets = _buildTafakorNotesTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.tafakorNotes);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.tafakorNotes);
      },
    );

    if (targets.isEmpty) return;

    _isTafakorNotesTourActive = true;
    controller.markCompleted(WalkthroughTourKey.tafakorNotes);
    _showTutorial(
      context: context,
      targets: targets,
      rootOverlay: true,
      onComplete: () {
        _isTafakorNotesTourActive = false;
        controller.markCompleted(WalkthroughTourKey.tafakorNotes);
      },
    );
  }

  /// Shows Tafakor Editor Screen walkthrough tour for the writing area and send button.
  static void showEditorTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isEditorTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.tafakorEditor)) {
      return;
    }

    final targets = _buildEditorTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.tafakorEditor);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.tafakorEditor);
      },
    );

    if (targets.isEmpty) return;

    _isEditorTourActive = true;
    controller.markCompleted(WalkthroughTourKey.tafakorEditor);
    _showTutorial(
      context: context,
      targets: targets,
      onComplete: () {
        _isEditorTourActive = false;
        controller.markCompleted(WalkthroughTourKey.tafakorEditor);
      },
    );
  }

  /// Shows Study Settings (Quick Settings Drawer) walkthrough tour.
  static void showStudySettingsTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    required ValueChanged<int> onSwitchTab,
    bool force = false,
  }) {
    if (!isEnabled || _isStudySettingsTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.studySettings)) {
      return;
    }

    final targets = _buildStudySettingsTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.studySettings);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.studySettings);
      },
    );

    if (targets.isEmpty) return;

    _isStudySettingsTourActive = true;
    controller.markCompleted(WalkthroughTourKey.studySettings);
    _showTutorial(
      context: context,
      targets: targets,
      rootOverlay: true,
      beforeFocus: (target) async {
        if (target.identify == 'settings_translation_selector') {
          onSwitchTab(1);
          await Future.delayed(const Duration(milliseconds: 220));
        } else if (target.identify == 'settings_reciter_selector' ||
                   target.identify == 'settings_audio_translation_mode') {
          onSwitchTab(2);
          await Future.delayed(const Duration(milliseconds: 220));
        }
      },
      onComplete: () {
        _isStudySettingsTourActive = false;
        controller.markCompleted(WalkthroughTourKey.studySettings);
      },
    );
  }

  /// Shows Audio Ambiance Bottom Sheet walkthrough tour for toggle switch.
  static void showAmbianceTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isAmbianceTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.ambianceDialog)) {
      return;
    }

    if (!WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.ambianceToggleSwitch)) {
      return;
    }

    final targets = _buildAmbianceTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.ambianceDialog);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.ambianceDialog);
      },
    );

    if (targets.isEmpty) return;

    _isAmbianceTourActive = true;
    controller.markCompleted(WalkthroughTourKey.ambianceDialog);
    _showTutorial(
      context: context,
      targets: targets,
      rootOverlay: true,
      onComplete: () {
        _isAmbianceTourActive = false;
        controller.markCompleted(WalkthroughTourKey.ambianceDialog);
      },
    );
  }

  /// Shows Sleep Timer Bottom Sheet walkthrough tour for toggle switch.
  static void showSleepTimerTourIfNeeded({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) {
    if (!isEnabled || _isSleepTimerTourActive) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    if (!force && controller.hasSeenTour(WalkthroughTourKey.sleepTimerDialog)) {
      return;
    }

    if (!WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.sleepTimerToggleSwitch)) {
      return;
    }

    final targets = _buildSleepTimerTargets(
      onFinish: () {
        controller.markCompleted(WalkthroughTourKey.sleepTimerDialog);
      },
      onSkip: () {
        controller.markCompleted(WalkthroughTourKey.sleepTimerDialog);
      },
    );

    if (targets.isEmpty) return;

    _isSleepTimerTourActive = true;
    controller.markCompleted(WalkthroughTourKey.sleepTimerDialog);
    _showTutorial(
      context: context,
      targets: targets,
      rootOverlay: true,
      onComplete: () {
        _isSleepTimerTourActive = false;
        controller.markCompleted(WalkthroughTourKey.sleepTimerDialog);
      },
    );
  }

  /// Resets all walkthrough tours so the user can re-trigger them.
  static Future<void> resetAll(WidgetRef ref) {
    return ref.read(walkthroughControllerProvider.notifier).resetAll();
  }

  // ─── INTERNAL TARGET BUILDERS (Fixed Bottom Layout & Boxless Typography) ─

  static List<TargetFocus> _buildHomeTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    const totalSteps = 4;

    final fixedBottomPosition = CustomTargetContentPosition(
      bottom: 28,
      left: 16,
      right: 16,
    );

    // 1. فهرست سوره‌ها
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.homeSurahList)) {
      targets.add(
        TargetFocus(
          identify: 'home_surah_list',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.homeSurahList),
          shape: ShapeLightFocus.RRect,
          radius: 16,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: fixedBottomPosition,
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'فهرست سوره‌ها',
                description:
                    'دسترسی سریع به ۱۱۴ سوره قرآن، جزءها، احزاب و جستجوی آسان در کل آیات.',
                currentStep: 1,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 2. ترجمه‌ها
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.homeTranslations)) {
      targets.add(
        TargetFocus(
          identify: 'home_translations',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.homeTranslations),
          shape: ShapeLightFocus.RRect,
          radius: 16,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: fixedBottomPosition,
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'بانک ترجمه‌ها',
                description:
                    'انتخاب، دانلود و تغییر آسان ترجمه‌های معتبر (فولادوند، مکارم، انصاریان و...) برای نمایش زیر آیات.',
                currentStep: 2,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 3. تفاسیر
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.homeTafsir)) {
      targets.add(
        TargetFocus(
          identify: 'home_tafsir',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.homeTafsir),
          shape: ShapeLightFocus.RRect,
          radius: 16,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: fixedBottomPosition,
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'تفسیر قرآن',
                description:
                    'مطالعه و دانلود تفاسیر ارزشمند المیزان، نمونه، نور و... با قابلیت مطالعه همزمان با آیات.',
                currentStep: 3,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 4. تفکر
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.homeTafakor)) {
      targets.add(
        TargetFocus(
          identify: 'home_tafakor',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.homeTafakor),
          shape: ShapeLightFocus.RRect,
          radius: 16,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: fixedBottomPosition,
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'جامعه اهل تفکر',
                description:
                    'فضایی آرام برای ثبت تاملات شخصی شما و مطالعه یادداشت‌ها و تفکرات دیگران بر روی آیات و موضوعات قرآنی.',
                currentStep: 4,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    return targets;
  }

  static List<TargetFocus> _buildReaderTargets({
    required BuildContext context,
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    const totalSteps = 5;

    // 1. بزرگ‌نمایی با دو انگشت (Pinch-to-zoom) – Full-screen backdrop blur behind it
    targets.add(
      TargetFocus(
        identify: 'reader_pinch_zoom',
        targetPosition: TargetPosition(const Size(0, 0), const Offset(-500, -500)),
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
            ),
            builder: (ctx, controller) {
              final screenHeight = MediaQuery.sizeOf(ctx).height;
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Stack(
                  children: [
                    // Centered Pinch-Zoom gesture animation (prominent, spacious)
                    Positioned(
                      top: (screenHeight * 0.42) - 130,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: PinchZoomGestureAnim(),
                      ),
                    ),

                    // Bottom typography & outline buttons
                    Positioned(
                      bottom: 28,
                      left: 16,
                      right: 16,
                      child: WalkthroughCardBubble(
                        controller: controller,
                        title: 'بزرگ‌نمایی با دو انگشت',
                        description:
                            'در هر کجای صفحه قرآن، با باز و بسته کردن دو انگشت خود، می‌توانید اندازه قلم آیات و ترجمه را به دلخواه تنظیم کنید.',
                        currentStep: 1,
                        totalSteps: totalSteps,
                        onFinish: onFinish,
                        onSkip: onSkip,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // 2. لمس طولانی روی آیه (Long Press on Ayah) – Hand placed directly on the Ayah box
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.readerFirstAyah)) {
      final ayahKey = WalkthroughRegistry.getKey(WalkthroughTargetId.readerFirstAyah);
      targets.add(
        TargetFocus(
          identify: 'reader_long_press',
          keyTarget: ayahKey,
          shape: ShapeLightFocus.RRect,
          radius: 14,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
              ),
              builder: (ctx, controller) {
                // Calculate exact center of the targeted ayah box
                final renderBox = ayahKey.currentContext?.findRenderObject() as RenderBox?;
                Offset? ayahCenter;
                if (renderBox != null && renderBox.hasSize) {
                  final offset = renderBox.localToGlobal(Offset.zero);
                  ayahCenter = offset + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
                }
                final screenHeight = MediaQuery.sizeOf(ctx).height;
                final screenWidth = MediaQuery.sizeOf(ctx).width;
                final handY = ayahCenter?.dy ?? (screenHeight * 0.32);
                final handX = ayahCenter?.dx ?? (screenWidth * 0.5);

                return Stack(
                  children: [
                    // Hand animation placed directly on top of the highlighted Ayah
                    Positioned(
                      top: handY - 45,
                      left: handX - 45,
                      width: 90,
                      height: 90,
                      child: const IgnorePointer(
                        child: LongPressGestureAnim(),
                      ),
                    ),

                    // Bottom typography & navigation buttons
                    Positioned(
                      bottom: 28,
                      left: 16,
                      right: 16,
                      child: WalkthroughCardBubble(
                        controller: controller,
                        title: 'لمس طولانی روی آیه',
                        description:
                            'با نگه‌داشتن انگشت خود روی هر آیه، جعبه‌ابزار جامع شامل صوت، جامعه تفکر، کپی و اشتراک‌گذاری باز می‌شود.',
                        currentStep: 2,
                        totalSteps: totalSteps,
                        onFinish: onFinish,
                        onSkip: onSkip,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    // 3. دکمه تنظیمات در پلیر (Settings in Player)
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.readerPlayerSettings)) {
      targets.add(
        TargetFocus(
          identify: 'reader_player_settings',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.readerPlayerSettings),
          shape: ShapeLightFocus.RRect,
          radius: 10,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 85,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'تنظیمات نمایش و قلم',
                description:
                    'دسترسی سریع به فونت‌های اصیل قرآن (عثمان‌طه، نیریزی، وزیر)، اندازه قلم، حالت شب و روز و تنظیمات صفحه‌بندی.',
                currentStep: 3,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 4. تایمر خواب در پلیر (Sleep Timer in Player)
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.readerSleepTimer)) {
      targets.add(
        TargetFocus(
          identify: 'reader_sleep_timer',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.readerSleepTimer),
          shape: ShapeLightFocus.RRect,
          radius: 10,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 85,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'تایمر خواب هوشمند',
                description:
                    'امکان تنظیم زمان مشخص برای توقف خودکار پخش صوت قرآن هنگام استراحت یا خواب شبانه.',
                currentStep: 4,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 5. نغمه‌های پس‌زمینه و افکت‌ها در پلیر (Ambient Audio in Player)
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.readerAmbientAudio)) {
      targets.add(
        TargetFocus(
          identify: 'reader_ambient_audio',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.readerAmbientAudio),
          shape: ShapeLightFocus.Circle,
          radius: 20,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 85,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'نغمه‌های پس‌زمینه و طنین حرم',
                description:
                    'امکان همراه کردن تلاوت قاری با صدای آرامش‌بخش باران یا طبیعت، و فعال‌سازی افکت طنین معنوی مسجد و حرم.',
                currentStep: 5,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    return targets;
  }

  static List<TargetFocus> _buildAyahDialogTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    const totalSteps = 1;

    // جامعه تفکر در باتم شیت آیه
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.dialogTafakorItem)) {
      targets.add(
        TargetFocus(
          identify: 'dialog_tafakor_item',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.dialogTafakorItem),
          shape: ShapeLightFocus.RRect,
          radius: 14,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 90,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'جامعه تفکر و تدبر در آیه',
                description:
                    'فضایی آرام برای ثبت تاملات شخصی شما و مطالعه یادداشت‌ها و تفکرات دیگران پیرامون این آیه شریفه.',
                currentStep: 1,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    return targets;
  }

  static List<TargetFocus> _buildTafakorNotesTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    const totalSteps = 1;

    // دکمه نگارش تفکر در پایین جامعه تفکر
    if (WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.tafakorWriteButton)) {
      targets.add(
        TargetFocus(
          identify: 'tafakor_write_button',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.tafakorWriteButton),
          shape: ShapeLightFocus.RRect,
          radius: 14,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 90,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'ثبت و نگارش تفکر',
                description:
                    'با لمس این دکمه وارد دفتر نگارش می‌شوید تا تاملات، تدبر و نکات شخصی خود را پیرامون این آیه شریفه بنویسید.',
                currentStep: 1,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    return targets;
  }

  static List<TargetFocus> _buildEditorTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];

    final hasAttachedAyah = WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.editorAttachedAyah);
    final hasInputField = WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.editorInputField);
    final hasSendButton = WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.editorSendButton);

    int totalSteps = 0;
    if (hasAttachedAyah) totalSteps++;
    if (hasInputField) totalSteps++;
    if (hasSendButton) totalSteps++;
    if (totalSteps == 0) return targets;

    int currentStep = 1;

    // 1. آیه پیوست‌شده به یادداشت
    if (hasAttachedAyah) {
      final step = currentStep++;
      targets.add(
        TargetFocus(
          identify: 'editor_attached_ayah',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.editorAttachedAyah),
          shape: ShapeLightFocus.RRect,
          radius: 14,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                bottom: 28,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'پیوست خودکار آیه',
                description:
                    'متن و ترجمه آیه مبارک به صورت خودکار به یادداشت شما پیوست شده است و می‌توانید تدبر خود را ذیل آن اضافه کنید.',
                currentStep: step,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 2. محل تایپ و نگارش یادداشت
    if (hasInputField) {
      final step = currentStep++;
      targets.add(
        TargetFocus(
          identify: 'editor_input_field',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.editorInputField),
          shape: ShapeLightFocus.RRect,
          radius: 14,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 85,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'محل نگارش تامل و تدبر',
                description:
                    'در این قسمت می‌توانید متن، تحلیل یا نکات تدبری خود را بدون نیاز به ابزارهای پیچیده تایپ نمایید.',
                currentStep: step,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    // 3. دکمه ارسال پست
    if (hasSendButton) {
      final step = currentStep++;
      targets.add(
        TargetFocus(
          identify: 'editor_send_button',
          keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.editorSendButton),
          shape: ShapeLightFocus.Circle,
          radius: 22,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 85,
                left: 16,
                right: 16,
              ),
              builder: (ctx, controller) => WalkthroughCardBubble(
                controller: controller,
                title: 'ارسال و انتشار پست',
                description:
                    'پس از اتمام نگارش، با فشردن دکمه ارسال، یادداشت شما در جامعه تفکر ثبت و منتشر خواهد شد.',
                currentStep: step,
                totalSteps: totalSteps,
                onFinish: onFinish,
                onSkip: onSkip,
              ),
            ),
          ],
        ),
      );
    }

    return targets;
  }

  static List<TargetFocus> _buildStudySettingsTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    const totalSteps = 3;

    // 1. انتخاب و تغییر ترجمه قرآن (Tab 1: ترجمه)
    targets.add(
      TargetFocus(
        identify: 'settings_translation_selector',
        keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.settingsTranslationSelector),
        shape: ShapeLightFocus.RRect,
        radius: 12,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 85,
              left: 16,
              right: 16,
            ),
            builder: (ctx, controller) => WalkthroughCardBubble(
              controller: controller,
              title: 'انتخاب و تغییر ترجمه قرآن',
              description:
                  'از این منو می‌توانید ترجمه دلخواه خود (فولادوند، مکارم، انصاریان و...) را انتخاب و دانلود کنید تا در زیر آیات نمایش داده شود.',
              currentStep: 1,
              totalSteps: totalSteps,
              onFinish: onFinish,
              onSkip: onSkip,
            ),
          ),
        ],
      ),
    );

    // 2. تغییر قاری تلاوت قرآن (Tab 2: صوت و تلاوت)
    targets.add(
      TargetFocus(
        identify: 'settings_reciter_selector',
        keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.settingsReciterSelector),
        shape: ShapeLightFocus.RRect,
        radius: 14,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 40,
              left: 16,
              right: 16,
            ),
            builder: (ctx, controller) => WalkthroughCardBubble(
              controller: controller,
              title: 'تغییر قاری تلاوت قرآن',
              description:
                  'با انتخاب قاری دلخواه خود (عبدالباسط، پرهیزگار، منشاوی و...)، صوت تلاوت با نوای ایشان پخش می‌شود. همچنین با زدن «لیست کامل»، به بیش از ۳۰ قاری دسترسی دارید.',
              currentStep: 2,
              totalSteps: totalSteps,
              onFinish: onFinish,
              onSkip: onSkip,
            ),
          ),
        ],
      ),
    );

    // 3. نحوه فعال‌سازی ترجمه گویا (Tab 2: صوت و تلاوت)
    targets.add(
      TargetFocus(
        identify: 'settings_audio_translation_mode',
        keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.settingsAudioTranslationMode),
        shape: ShapeLightFocus.RRect,
        radius: 14,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 40,
              left: 16,
              right: 16,
            ),
            builder: (ctx, controller) => WalkthroughCardBubble(
              controller: controller,
              title: 'نحوه فعال‌سازی ترجمه گویا',
              description:
                  'برای شنیدن صوت ترجمه همراه با تلاوت، حالت پخش را روی «تلاوت+ترجمه» یا «ترجمه» قرار دهید تا صوت ترجمه فارسی آیه به صورت خودکار پخش گردد.',
              currentStep: 3,
              totalSteps: totalSteps,
              onFinish: onFinish,
              onSkip: onSkip,
            ),
          ),
        ],
      ),
    );

    return targets;
  }

  static List<TargetFocus> _buildAmbianceTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    if (!WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.ambianceToggleSwitch)) {
      return targets;
    }

    targets.add(
      TargetFocus(
        identify: 'ambiance_toggle_switch',
        keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.ambianceToggleSwitch),
        shape: ShapeLightFocus.RRect,
        radius: 16,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 40,
              left: 16,
              right: 16,
            ),
            builder: (ctx, controller) => WalkthroughCardBubble(
              controller: controller,
              title: 'فعال و غیرفعال‌سازی نغمه',
              description:
                  'با روشن کردن این کلید، نغمه آرام‌بخش طبیعت یا باران همراه با تلاوت قرآن پخش می‌شود و با خاموش کردن آن، صدای پس‌زمینه متوقف خواهد شد.',
              currentStep: 1,
              totalSteps: 1,
              onFinish: onFinish,
              onSkip: onSkip,
            ),
          ),
        ],
      ),
    );

    return targets;
  }

  static List<TargetFocus> _buildSleepTimerTargets({
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    final targets = <TargetFocus>[];
    if (!WalkthroughRegistry.isTargetMounted(WalkthroughTargetId.sleepTimerToggleSwitch)) {
      return targets;
    }

    targets.add(
      TargetFocus(
        identify: 'sleep_timer_toggle_switch',
        keyTarget: WalkthroughRegistry.getKey(WalkthroughTargetId.sleepTimerToggleSwitch),
        shape: ShapeLightFocus.RRect,
        radius: 16,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 40,
              left: 16,
              right: 16,
            ),
            builder: (ctx, controller) => WalkthroughCardBubble(
              controller: controller,
              title: 'فعال و غیرفعال‌سازی تایمر خواب',
              description:
                  'با روشن کردن این کلید، تایمر خواب فعال شده و پس از پایان زمان مشخص‌شده یا اتمام سوره، پخش صوت خودکار متوقف خواهد شد.',
              currentStep: 1,
              totalSteps: 1,
              onFinish: onFinish,
              onSkip: onSkip,
            ),
          ),
        ],
      ),
    );

    return targets;
  }

  static void _showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    required VoidCallback onComplete,
    FutureOr<void> Function(TargetFocus)? beforeFocus,
    bool rootOverlay = false,
  }) {
    TutorialCoachMark(
      targets: targets,
      beforeFocus: beforeFocus,
      colorShadow: const Color(0xFF0A0C0E),
      opacityShadow: 0.88,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      textSkip: 'رد شدن',
      hideSkip: true,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 320),
      unFocusAnimationDuration: const Duration(milliseconds: 220),
      onClickOverlay: (target) {
        onComplete();
      },
      onFinish: onComplete,
      onSkip: () {
        onComplete();
        return true;
      },
    ).show(context: context, rootOverlay: rootOverlay);
  }
}
