import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/surah_list_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../mini_audio_player/presentation/widgets/mini_audio_player_bar.dart';
import '../../../page_navigation/presentation/widgets/page_navigation_bottom_sheet.dart';
import '../../../../common/widgets/reciter/reciter_avatar_button.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../widgets/surah_error_view.dart';
import '../widgets/surah_list_item.dart';
import '../../domain/entities/surah_entity.dart';

/// Root screen – uses StatefulWidget so that the FocusNode survives rebuilds
/// and we can explicitly control keyboard dismiss on navigation.
class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only select what we need to avoid full-page rebuilds
    final isLoading = ref.watch(
      surahListControllerProvider.select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      surahListControllerProvider.select((s) => s.errorMessage),
    );
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return Scaffold(
      extendBody: true,
      appBar: IslamicKatibahAppBar(
        surahName: AppConstants.surahListScreenTitle,
        fontFamily: fontFamily,
        showSearchField: true,
        searchFocusNode: _searchFocusNode,
        searchController: _searchController,
        searchPrefixWidget: const ReciterAvatarButton(radius: 18, showLabel: false),
        onSearchChanged: (query) {
          ref.read(surahListControllerProvider.notifier).searchSurahs(query);
        },
      ),
      body: _buildBody(context, isLoading, errorMessage),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          PageNavigationBottomSheet.show(context);
        },
        label: const Text(
          'تلاوت نور',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.softGoldText,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkPrimaryContainer
            : Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      bottomNavigationBar: const MiniAudioPlayerBar(),
    );
  }

  Widget _buildBody(BuildContext context, bool isLoading, String? errorMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return SurahErrorView(
        errorMessage: errorMessage,
        onRetry: () {
          ref.read(surahListControllerProvider.notifier).build();
        },
      );
    }

    // Watch filteredSurahs only inside the body so AppBar doesn't rebuild on search changes
    final filteredSurahs = ref.watch(
      surahListControllerProvider.select((s) => s.filteredSurahs),
    );

    if (filteredSurahs.isEmpty) {
      return const Center(
        child: Text(
          AppConstants.noSurahFound,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      itemCount: filteredSurahs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        return SurahListItem(
          surah: surah,
          onTap: () => _handleSurahTap(surah),
        );
      },
    );
  }

  void _handleSurahTap(SurahEntity surah) {
    final reciter = ref.read(quranAudioControllerProvider).selectedReciter;
    final isDownloaded = reciter != null &&
        ref.read(audioStorageServiceProvider).isSurahDownloaded(reciter.id, surah.number);

    if (!isDownloaded) {
      final fontScript = ref.read(
        quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
      );
      final surahFontFamily = AppTypography.getFontFamilyByScript(fontScript);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              children: [
                const TextSpan(text: 'صوت سوره '),
                TextSpan(
                  text: surah.name,
                  style: TextStyle(
                    fontFamily: surahFontFamily,
                    fontSize: 20,
                    color: AppColors.goldAccent,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          content: const Text(
            'صوت این سوره به‌طور کامل موجود نیست. می‌توانید سوره را بخوانید و تا آیه دانلودشده گوش دهید.',
            style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openReader(surah);
                  },
                  child: const Text('خواندن سوره', style: TextStyle(fontFamily: AppTypography.fontFamily)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _dismissSearchAndNavigate(() {
                      context.pushNamed(
                        audioDownloadManagerRoute,
                        queryParameters: {'surahId': surah.number.toString()},
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('دانلود صوت', style: TextStyle(fontFamily: AppTypography.fontFamily, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      _openReader(surah);
    }
  }

  void _openReader(SurahEntity surah) {
    _dismissSearchAndNavigate(() {
      ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);
      context.pushNamed(
        quranReaderRoute,
        pathParameters: {'id': surah.number.toString()},
        queryParameters: {'name': surah.name},
      );
    });
  }

  /// Unfocus the search field, clear query, then navigate.
  /// Using addPostFrameCallback ensures the keyboard is dismissed
  /// BEFORE the navigation happens, so it won't re-appear on pop.
  void _dismissSearchAndNavigate(VoidCallback navigate) {
    _searchFocusNode.unfocus();
    _searchController.clear();
    ref.read(surahListControllerProvider.notifier).searchSurahs('');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) navigate();
    });
  }
}
