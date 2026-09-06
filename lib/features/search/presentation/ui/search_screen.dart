import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/controllers/recent_searches_controller.dart';
import '../../application/controllers/search_controller.dart';
import '../../application/states/search_state.dart';
import '../../domain/entities/search_filter_type.dart';
import '../../domain/entities/search_result_item.dart';
import '../widgets/search_empty_state.dart';
import '../widgets/search_filter_chips.dart';
import '../widgets/search_recent_history_view.dart';
import '../widgets/search_result_ayah_card.dart';
import '../widgets/search_result_surah_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSelectSearchTerm(String term) {
    _textController.text = term;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    ref.read(searchControllerProvider.notifier).searchImmediate(term);
  }

  void _navigateToItem(SearchResultItem item) {
    // Immediately commit the active query to history when user selects a result
    ref.read(searchControllerProvider.notifier).commitQueryToHistoryNow();

    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': item.surahNumber.toString()},
      queryParameters: {
        'name': item.surahName,
        if (item.ayahNumber != null) 'ayah': item.ayahNumber.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Fixed Search Bar (Stable Header - Never rebuilds unnecessarily)
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 8.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      CupertinoIcons.arrow_right,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    splashRadius: 22,
                  ),

                  // Integrated Search Input Container
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2825)
                            : const Color(0xFFF2EFEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2DDD5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          12.hSpace,
                          Icon(
                            CupertinoIcons.search,
                            size: 19,
                            color: isDark
                                ? AppColors.goldAccent
                                : AppColors.primary,
                          ),
                          10.hSpace,
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) {
                                ref
                                    .read(searchControllerProvider.notifier)
                                    .commitQueryToHistoryNow();
                              },
                              onChanged: (val) {
                                ref
                                    .read(searchControllerProvider.notifier)
                                    .onQueryChanged(val);
                              },
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'جستجو در نام سوره، آیه، ترجمه...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white38
                                      : const Color(0xFF989288),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          // Isolated Action Indicator (Loading or Clear button)
                          Consumer(
                            builder: (context, ref, _) {
                              final isLoading = ref.watch(
                                searchControllerProvider
                                    .select((s) => s.isLoading),
                              );
                              final hasQuery = ref.watch(
                                searchControllerProvider
                                    .select((s) => s.query.isNotEmpty),
                              );

                              if (isLoading) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        isDark
                                            ? AppColors.goldAccent
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (hasQuery) {
                                return IconButton(
                                  onPressed: () {
                                    _textController.clear();
                                    ref
                                        .read(
                                            searchControllerProvider.notifier)
                                        .clearSearch();
                                  },
                                  icon: Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                  splashRadius: 18,
                                );
                              }

                              return 10.hSpace;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Filter Chips (Isolated Consumer with targeted selector)
            Consumer(
              builder: (context, ref, _) {
                final isEmptyQuery = ref.watch(
                  searchControllerProvider.select((s) => s.isEmptyQuery),
                );
                if (isEmptyQuery) return const SizedBox.shrink();

                final activeFilter = ref.watch(
                  searchControllerProvider.select((s) => s.activeFilter),
                );
                final totalCount = ref.watch(
                  searchControllerProvider.select((s) => s.totalCount),
                );
                final surahCount = ref.watch(
                  searchControllerProvider.select((s) => s.surahCount),
                );
                final ayahCount = ref.watch(
                  searchControllerProvider.select((s) => s.ayahCount),
                );
                final translationCount = ref.watch(
                  searchControllerProvider.select((s) => s.translationCount),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SearchFilterChips(
                    selectedFilter: activeFilter,
                    onFilterSelected: (filter) {
                      ref
                          .read(searchControllerProvider.notifier)
                          .setFilter(filter);
                    },
                    totalResults: totalCount,
                    surahCount: surahCount,
                    ayahCount: ayahCount,
                    translationCount: translationCount,
                  ),
                );
              },
            ),

            // 3. Main Dynamic Content Area
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final searchState = ref.watch(searchControllerProvider);

                  // A. Initial View: Recent History
                  if (searchState.isEmptyQuery) {
                    final recentSearches = ref.watch(recentSearchesProvider);
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SearchRecentHistoryView(
                        recentSearches: recentSearches,
                        onSearchSelected: _onSelectSearchTerm,
                        onRemoveSearch: (term) {
                          ref
                              .read(recentSearchesProvider.notifier)
                              .removeSearch(term);
                        },
                        onClearAll: () {
                          ref
                              .read(recentSearchesProvider.notifier)
                              .clearAll();
                        },
                      ),
                    );
                  }

                  // B. Initial Loading before any results arrive
                  if (searchState.isLoading && searchState.results.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.goldAccent : AppColors.primary,
                        ),
                      ),
                    );
                  }

                  // C. No Results Found for active filter
                  final displayedResults = searchState.displayedResults;
                  if (displayedResults.isEmpty && !searchState.isLoading) {
                    return SearchEmptyState(query: searchState.query);
                  }

                  // D. Results List
                  final surahs = (searchState.activeFilter == SearchFilterType.all ||
                          searchState.activeFilter == SearchFilterType.surahs)
                      ? searchState.surahResults
                      : <SearchResultItem>[];

                  final ayahs = searchState.activeFilter == SearchFilterType.surahs
                      ? <SearchResultItem>[]
                      : (searchState.activeFilter == SearchFilterType.ayahs
                          ? searchState.arabicAyahResults
                          : (searchState.activeFilter == SearchFilterType.translations
                              ? searchState.translationAyahResults
                              : searchState.results.where((i) => i.isAyah).toList()));

                  final ayahHeaderTitle = searchState.activeFilter == SearchFilterType.translations
                      ? 'ترجمه فارسی (${ayahs.length.toPersianDigit()})'
                      : (searchState.activeFilter == SearchFilterType.ayahs
                          ? 'متن آیات (${ayahs.length.toPersianDigit()})'
                          : 'آیات و ترجمه‌ها (${ayahs.length.toPersianDigit()})');

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4.0, bottom: 24.0),
                    itemCount: _calculateItemCount(surahs, ayahs),
                    itemBuilder: (context, index) {
                      return _buildItemAt(
                        context: context,
                        index: index,
                        searchState: searchState,
                        surahs: surahs,
                        ayahs: ayahs,
                        ayahHeaderTitle: ayahHeaderTitle,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateItemCount(List<SearchResultItem> surahs, List<SearchResultItem> ayahs) {
    int count = 0;
    if (surahs.isNotEmpty) {
      count += 1 + surahs.length;
    }
    if (ayahs.isNotEmpty) {
      count += 1 + ayahs.length;
    }
    return count;
  }

  Widget _buildItemAt({
    required BuildContext context,
    required int index,
    required SearchState searchState,
    required List<SearchResultItem> surahs,
    required List<SearchResultItem> ayahs,
    required String ayahHeaderTitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasSurahs = surahs.isNotEmpty;

    if (hasSurahs) {
      if (index == 0) {
        return _buildSectionHeader(
          'سوره‌ها (${surahs.length.toPersianDigit()})',
          isDark,
        );
      }

      if (index <= surahs.length) {
        final surahItem = surahs[index - 1];
        return SearchResultSurahCard(
          item: surahItem,
          query: searchState.query,
          onTap: () => _navigateToItem(surahItem),
        );
      }
    }

    final ayahStartIndex = hasSurahs ? surahs.length + 1 : 0;
    if (index == ayahStartIndex) {
      return _buildSectionHeader(ayahHeaderTitle, isDark);
    }

    final ayahIndex = index - ayahStartIndex - 1;
    if (ayahIndex >= 0 && ayahIndex < ayahs.length) {
      final ayahItem = ayahs[ayahIndex];
      return SearchResultAyahCard(
        item: ayahItem,
        query: searchState.query,
        onTap: () => _navigateToItem(ayahItem),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 14.0,
        bottom: 6.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.goldAccent : AppColors.primary,
        ),
      ),
    );
  }
}
