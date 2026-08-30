import 'package:flutter/cupertino.dart';
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
import '../../application/controllers/favorite_surahs_controller.dart';
import '../widgets/surah_action_dialog.dart';
import '../widgets/surah_error_view.dart';
import '../widgets/surah_list_item.dart';
import '../widgets/surah_sort_bottom_sheet.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.clear();
      ref.read(surahListControllerProvider.notifier).searchSurahs('');
    });
  }

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
    final isOnlyFavorites = ref.watch(
      surahListControllerProvider.select((s) => s.isOnlyFavorites),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _searchController.clear();
          ref.read(surahListControllerProvider.notifier).searchSurahs('');
        }
      },
      child: Scaffold(
      extendBody: true,
      appBar: IslamicKatibahAppBar(
        surahName: isOnlyFavorites ? 'فهرست شخصی' : AppConstants.surahListScreenTitle,
        fontFamily: fontFamily,
        showSearchField: true,
        searchFocusNode: _searchFocusNode,
        searchController: _searchController,
        searchPrefixWidget: const ReciterAvatarButton(radius: 25, showLabel: false),
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.device_laptop,
              color: AppColors.softGoldText,
              size: 22,
            ),
            tooltip: 'دستگاه هوشمند NodeMCU',
            onPressed: () => context.pushNamed(smartDeviceRoute),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              CupertinoIcons.ellipsis_vertical,
              color: AppColors.softGoldText,
              size: 22,
            ),
            tooltip: 'گزینه‌ها',
            onSelected: (value) {
              if (value == 'sort') {
                SurahSortBottomSheet.show(context);
              } else if (value == 'custom_list') {
                ref.read(surahListControllerProvider.notifier).toggleOnlyFavorites();
              } else if (value == 'smart_device') {
                context.pushNamed(smartDeviceRoute);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.sort_down, size: 20, color: AppColors.goldAccent),
                    SizedBox(width: 8),
                    Text(
                      'مرتب‌سازی',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'custom_list',
                child: Row(
                  children: [
                    Icon(
                      isOnlyFavorites ? CupertinoIcons.list_bullet : CupertinoIcons.star_fill,
                      size: 20,
                      color: AppColors.goldAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnlyFavorites ? 'نمایش همه سوره‌ها' : 'فهرست شخصی',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'smart_device',
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.device_laptop,
                      size: 20,
                      color: AppColors.goldAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'دستگاه هوشمند NodeMCU',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        onSearchChanged: (query) {
          ref.read(surahListControllerProvider.notifier).searchSurahs(query);
        },
      ),
      body: _buildBody(context, isLoading, errorMessage, isOnlyFavorites),
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
    ),
  );
}

  Widget _buildBody(
    BuildContext context,
    bool isLoading,
    String? errorMessage,
    bool isOnlyFavorites,
  ) {
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

    // Watch filteredSurahs & favorite IDs
    final initialFiltered = ref.watch(
      surahListControllerProvider.select((s) => s.filteredSurahs),
    );
    final favoriteSurahIds = ref.watch(favoriteSurahsProvider);

    final filteredSurahs = isOnlyFavorites
        ? initialFiltered
            .where((surah) => favoriteSurahIds.contains(surah.number))
            .toList()
        : initialFiltered;

    if (filteredSurahs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            isOnlyFavorites
                ? 'فهرست شخصی شما خالی است.\nبا زدن آیکون ستاره در کنار هر سوره می‌توانید آن را به این فهرست اضافه کنید.'
                : AppConstants.noSurahFound,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              color: Colors.grey,
              height: 1.6,
            ),
          ),
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

  void _handleSurahTap(SurahEntity surah) async {
    final reciter = ref.read(quranAudioControllerProvider).selectedReciter;
    final storageService = ref.read(audioStorageServiceProvider);

    bool isDownloaded = false;
    if (reciter != null) {
      final isMarked = storageService.isSurahDownloaded(reciter.id, surah.number);
      final firstAyahPath = await storageService.getLocalAyahAudioPath(
        reciterId: reciter.id,
        surahId: surah.number,
        ayahNumber: 1,
      );
      isDownloaded = isMarked || firstAyahPath != null;
    }

    if (!isDownloaded) {
      if (!mounted) return;
      final fontScript = ref.read(
        quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
      );
      final surahFontFamily = AppTypography.getFontFamilyByScript(fontScript);

      SurahActionDialog.show(
        context: context,
        surah: surah,
        surahFontFamily: surahFontFamily,
        onReadSurah: () => _openReader(surah),
        onDownloadAudio: () {
          final router = GoRouter.of(context);
          _dismissSearchAndNavigate(() {
            router.pushNamed(
              audioDownloadManagerRoute,
              queryParameters: {'surahId': surah.number.toString()},
            );
          });
        },
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
