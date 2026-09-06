import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/quran_markdown_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_ai_controller.dart';
import '../../domain/entities/quran_ai_request.dart';

/// Luxury AI Companion Bottom Sheet for deep Quranic linguistic and thematic contemplation
class QuranAiBottomSheet extends ConsumerStatefulWidget {
  final QuranAiRequest request;

  const QuranAiBottomSheet({
    super.key,
    required this.request,
  });

  static Future<void> show(
    BuildContext context, {
    required QuranAiRequest request,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranAiBottomSheet(request: request),
    );
  }

  @override
  ConsumerState<QuranAiBottomSheet> createState() => _QuranAiBottomSheetState();
}

class _QuranAiBottomSheetState extends ConsumerState<QuranAiBottomSheet> {
  late final TextEditingController _chatController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _chatController = TextEditingController();
    _scrollController = ScrollController();

    // Prepare context WITHOUT sending an automatic request
    Future.microtask(() {
      ref
          .read(quranAiControllerProvider.notifier)
          .prepareContext(widget.request);
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendQuestion(String questionText) {
    final clean = questionText.trim();
    if (clean.isEmpty) return;

    _chatController.clear();
    FocusScope.of(context).unfocus();
    ref.read(quranAiControllerProvider.notifier).askQuestion(clean);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<({String title, String desc, IconData icon, String query})>
      _getSuggestions(bool isWord) {
    if (isWord) {
      final word = widget.request.selectedText.trim();
      return [
        (
          title: 'ریشه‌شناسی و معنای لغوی',
          desc: 'بررسی ریشه ثلاثی، اشتقاق و معانی دقیق در لغت‌نامه‌های اصیل عربی',
          icon: CupertinoIcons.textformat_abc_dottedunderline,
          query:
              'لطفاً ریشه ثلاثی، اشتقاق، وجوه معنایی و مفهوم دقیق واژه «$word» را در بافت این آیه تبیین کنید.',
        ),
        (
          title: 'راز انتخاب این واژه',
          desc: 'چرا دقیقاً این کلمه آمده و تفاوت آن با واژه‌های مترادف چیست؟',
          icon: CupertinoIcons.sparkles,
          query:
              'چرا در این آیه دقیقاً واژه «$word» به کار رفته و چه تفاوت معنایی و بیانی با سایر واژگان مشابه دارد؟',
        ),
        (
          title: 'ظرافت‌های بلاغی و ادبی',
          desc: 'آهنگ کلام، زیبایی‌های ادبی و اعجاز بیانی در این آیه',
          icon: CupertinoIcons.book_fill,
          query:
              'ظرافت‌های بلاغی، زیبایی‌های ادبی و اعجاز بیانی مربوط به واژه «$word» را در این آیه بررسی کنید.',
        ),
        (
          title: 'پیام کاربردی برای زندگی من',
          desc: 'چگونه آموزه این کلمه را در زندگی روزمره امروز پیاده کنیم؟',
          icon: CupertinoIcons.heart_fill,
          query:
              'پیام تدبری و کاربرد عملی واژه «$word» برای آرامش روح و تصمیم‌گیری در زندگی روزمره امروز چیست؟',
        ),
      ];
    } else {
      return [
        (
          title: 'تفسیر و مفاهیم تدبری آیه',
          desc: 'تبیین عمیق و درس‌های اصلی نهفته در این آیه شریفه',
          icon: CupertinoIcons.sparkles,
          query:
              'لطفاً یک تفسیر و تحلیل تدبری جامع، دلنشین و کاربردی از پیام‌های اصلی این آیه ارائه دهید.',
        ),
        (
          title: 'ظرافت‌های لغوی و بلاغی',
          desc: 'ریشه‌شناسی واژگان کلیدی، اعجاز ادبی و ترکیب‌های کلامی',
          icon: CupertinoIcons.textformat_abc_dottedunderline,
          query:
              'نکات ظریف لغوی، ریشه‌شناسی واژگان کلیدی و زیبایی‌های بلاغی و ساختاری این آیه را بیان فرمایید.',
        ),
        (
          title: 'راهکار عملی برای زندگی امروز',
          desc: 'تمرین روانی و رفتاری برای رهایی از اضطراب و آرامش درون',
          icon: CupertinoIcons.heart_fill,
          query:
              'چگونه می‌توان پیام این آیه را در سبک زندگی، تصمیمات و رهایی از اضطراب‌های دنیای امروز پیاده کرد؟',
        ),
        (
          title: 'شأن نزول و بستر تاریخی',
          desc: 'پیش‌زمینه و داستان نزول آیه در دوران رسالت پیامبر (ص)',
          icon: CupertinoIcons.clock_fill,
          query:
              'شأن نزول، پیش‌زمینه تاریخی و بستر صدور این آیه شریفه در تاریخ اسلام چه بوده است؟',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final arabicFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    final aiState = ref.watch(quranAiControllerProvider);

    final sheetBg = isDark ? const Color(0xFF141C1A) : const Color(0xFFF9F8F6);
    final cardBg = isDark ? const Color(0xFF1B2522) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE8E4DC);
    final goldColor = isDark ? const Color(0xFFF4E0A5) : const Color(0xFFB38327);

    final isWord = widget.request.isWordAnalysis;
    final suggestions = _getSuggestions(isWord);
    final hasStartedChat = aiState.messages.isNotEmpty || aiState.isLoading;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Drag Handle
            10.vSpace,
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            12.vSpace,

            // 2. Luxury Header with AI Icon and Quran Coordinates
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.goldAccent.withValues(alpha: 0.15)
                          : const Color(0xFFF2ECE0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.goldAccent.withValues(alpha: 0.3)
                            : const Color(0xFFDFD4C2),
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.sparkles,
                      color: isDark ? AppColors.goldAccent : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isWord ? 'تدبر هوشمند در واژه' : 'تدبر هوشمند در آیه',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            6.hSpace,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFEDE9E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.request.surahName} • آیه ${widget.request.ayahNumber.toPersianDigit()}',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        2.vSpace,
                        Text(
                          '«${widget.request.selectedText.trim()}»',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: arabicFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: goldColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close Button
                  IconButton(
                    tooltip: 'بستن',
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: isDark ? Colors.white38 : Colors.black26,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            10.vSpace,
            Divider(height: 1, color: borderColor),

            // 3. Horizontal Suggestion Chips (تنها زمانی که چت آغاز شده در بالا نمایش داده می‌شوند)
            if (hasStartedChat)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: suggestions.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ActionChip(
                          avatar: Icon(
                            item.icon,
                            size: 13,
                            color: isDark ? AppColors.goldAccent : AppColors.primary,
                          ),
                          label: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              color: isDark ? Colors.white70 : const Color(0xFF3F3C36),
                            ),
                          ),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFEFECE5),
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onPressed: aiState.isLoading
                              ? null
                              : () => _sendQuestion(item.query),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // 4. Main Body: Either Starter Question Boxes (حالت اولیه) or Conversation List (حالت گفتگو)
            Expanded(
              child: Builder(
                builder: (context) {
                  // A. Initial State: Show Question Starter Boxes in Center
                  if (!hasStartedChat && aiState.errorMessage == null) {
                    return _buildStarterBoxes(
                      context: context,
                      suggestions: suggestions,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      goldColor: goldColor,
                    );
                  }

                  // B. Initial Loading State
                  if (aiState.isLoading && aiState.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.goldAccent : AppColors.primary,
                              ),
                            ),
                          ),
                          16.vSpace,
                          Text(
                            'در حال تحلیل و تدبر قرآنی با هوش مصنوعی...',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // C. Error State (When no messages exist yet)
                  if (aiState.errorMessage != null && aiState.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: Colors.redAccent,
                              size: 44,
                            ),
                            12.vSpace,
                            Text(
                              aiState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                color: Colors.redAccent,
                                height: 1.5,
                              ),
                            ),
                            16.vSpace,
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDark ? AppColors.goldAccent : AppColors.primary,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(quranAiControllerProvider.notifier)
                                    .retry();
                              },
                              icon: const Icon(CupertinoIcons.refresh, size: 16),
                              label: const Text(
                                'تلاش مجدد',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // D. Messages Conversation List
                  return ListView.separated(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    itemCount: aiState.messages.length + (aiState.isLoading ? 1 : 0),
                    separatorBuilder: (_, _) => 12.vSpace,
                    itemBuilder: (context, index) {
                      // Loading bubble for follow-ups
                      if (index == aiState.messages.length) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? AppColors.goldAccent
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                8.hSpace,
                                Text(
                                  'در حال نگارش پاسخ...',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final message = aiState.messages[index];
                      return _buildMessageBubble(
                        context: context,
                        message: message,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        goldColor: goldColor,
                      );
                    },
                  );
                },
              ),
            ),

            // 5. Bottom Interactive Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161E1B) : Colors.white,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF3EFE9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: _chatController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendQuestion(_chatController.text),
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'سوال خود را درباره این آیه بنویسید...',
                          hintStyle: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),
                  ),
                  8.hSpace,
                  IconButton(
                    onPressed: aiState.isLoading
                        ? null
                        : () => _sendQuestion(_chatController.text),
                    icon: Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      color: aiState.isLoading
                          ? (isDark ? Colors.white24 : Colors.black12)
                          : (isDark ? AppColors.goldAccent : AppColors.primary),
                      size: 32,
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

  Widget _buildMessageBubble({
    required BuildContext context,
    required dynamic message,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color goldColor,
  }) {
    final isUser = message.isUser as bool;
    final text = message.text as String;

    if (isUser) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.3)
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : const Color(0xFFC8E6C9),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    // AI Response Bubble
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: 15,
                color: goldColor,
              ),
              6.hSpace,
              Text(
                'تحلیل و تدبر هوش مصنوعی',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'کپی متن پاسخ',
                icon: Icon(
                  CupertinoIcons.doc_on_doc,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  AppSnackBar.showSuccess(context, 'متن پاسخ کپی شد.');
                },
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          10.vSpace,
          QuranMarkdownView(
            text: text,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Starter Question Boxes rendered in the center before any messages are sent
  Widget _buildStarterBoxes({
    required BuildContext context,
    required List<({String title, String desc, IconData icon, String query})> suggestions,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color goldColor,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1EDE6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5DDD0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.chat_bubble_2_fill, size: 15, color: goldColor),
                  8.hSpace,
                  Text(
                    'درباره چه موضوعی مایلید تدبر و گفتگو کنیم؟',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          14.vSpace,
          ...suggestions.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => _sendQuestion(item.query),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 13.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor, width: 1.1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.goldAccent.withValues(alpha: 0.12)
                                : const Color(0xFFF7F2EA),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.goldAccent.withValues(alpha: 0.25)
                                  : const Color(0xFFE8DFD1),
                            ),
                          ),
                          child: Icon(item.icon, color: goldColor, size: 19),
                        ),
                        14.hSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF2C2A26),
                                ),
                              ),
                              3.vSpace,
                              Text(
                                item.desc,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11.5,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        8.hSpace,
                        Icon(
                          CupertinoIcons.chevron_left,
                          size: 15,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
