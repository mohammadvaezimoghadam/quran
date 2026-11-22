import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../main_navigation/application/tab_navigation_controller.dart';
import '../../application/hoopoe_game_controller.dart';
import '../../domain/models/quran_game_item.dart';
import '../../infrastructure/datasources/quran_games_catalog.dart';
import '../widgets/hub/bazaar_category_fab.dart';
import '../widgets/hub/bazaar_game_section.dart';
import '../widgets/hub/game_categories_bottom_sheet.dart';
import '../widgets/hub/game_detail_bottom_sheet.dart';
import 'hoopoe_roadmap_screen.dart';

/// هاب بازی‌های قرآنی به سبک فروشگاه بازی کافه‌بازار
/// ساختار معماری:
/// - مدل داده‌ها در [QuranGameItem] و [QuranGameSection]
/// - کاتالوگ بازی‌ها در [QuranGamesCatalog]
/// - ویجت‌های اختصاصی در [BazaarGameSection]، [BazaarGameCard]، [BazaarCategoryFab]
/// - دیالوگ‌ها در [GameDetailBottomSheet] و [GameCategoriesBottomSheet]
class QuranGamesHubScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const QuranGamesHubScreen({
    super.key,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  ConsumerState<QuranGamesHubScreen> createState() =>
      _QuranGamesHubScreenState();
}

class _QuranGamesHubScreenState extends ConsumerState<QuranGamesHubScreen> {
  bool _isNavigatingToRoadmap = false;
  String _selectedCategory = 'همه بازی‌ها';

  @override
  Widget build(BuildContext context) {
    if (_isNavigatingToRoadmap) {
      return HoopoeRoadmapScreen(
        onExitToHub: () {
          setState(() {
            _isNavigatingToRoadmap = false;
          });
        },
      );
    }

    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final controller = ref.read(hoopoeGameControllerProvider.notifier);

    final totalStars = controller.totalStarsEarned;
    final maxStars = controller.maxPossibleStars;

    final bgColor = isDark ? const Color(0xFF10131B) : const Color(0xFFF7F8FA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leading: widget.showBackButton
              ? IconButton(
                  icon: const Icon(CupertinoIcons.back),
                  onPressed:
                      widget.onBackPressed ??
                      () {
                        ref
                            .read(tabNavigationControllerProvider.notifier)
                            .handleBackPress();
                      },
                )
              : null,
          title: Text(
            'بازی‌های قرآنی',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            _buildStarsStatusChip(totalStars, maxStars),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 6.0, bottom: 90.0),
              children: [
                // 1. خفن‌ترین بازی‌های قرآنی (شامل بازی هدهد)
                BazaarGameSection(
                  section: QuranGamesCatalog.getFeaturedNewGames(
                    totalStars: totalStars,
                  ),
                  onGameTap: _handleGameSelection,
                  onActionTap: () =>
                      _showSectionToast('خفن‌ترین بازی‌های جدید'),
                ),

                const SizedBox(height: 18.0),

                // 2. گشت و گذار در بازی‌ها (با برچسب ویژه)
                BazaarGameSection(
                  section: QuranGamesCatalog.getExploreGames(),
                  onGameTap: _handleGameSelection,
                ),

                const SizedBox(height: 18.0),

                // 3. بازی‌های کم‌حجم
                BazaarGameSection(
                  section: QuranGamesCatalog.getLightweightGames(),
                  onGameTap: _handleGameSelection,
                  onActionTap: () => _showSectionToast('بازی‌های کم‌حجم'),
                ),

                const SizedBox(height: 18.0),

                // 4. چالش‌های جدید رو از دست نده
                BazaarGameSection(
                  section: QuranGamesCatalog.getUpcomingChallenges(),
                  onGameTap: _handleGameSelection,
                  onActionTap: () => _showSectionToast('چالش‌های جدید'),
                ),
              ],
            ),

            // دکمه شناور دسته‌بندی با ۴ نقطه رنگی کافه‌بازار
            Positioned(
              left: 20,
              bottom: 24,
              child: BazaarCategoryFab(
                onTap: _openCategoriesSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// چیپ وضعیت ستاره‌ها در AppBar
  Widget _buildStarsStatusChip(int totalStars, int maxStars) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.star_fill,
                size: 14,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(width: 4),
              Text(
                '$totalStars / $maxStars',
                style: const TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC107),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// مدیریت کلیک روی هر بازی
  void _handleGameSelection(QuranGameItem game) {
    if (game.isPlayable && game.id == 'hoopoe_flight') {
      HapticFeedback.lightImpact();
      setState(() {
        _isNavigatingToRoadmap = true;
      });
    } else {
      GameDetailBottomSheet.show(context, game);
    }
  }

  /// باز کردن باتم‌شیت دسته‌بندی‌ها
  void _openCategoriesSheet() {
    GameCategoriesBottomSheet.show(
      context: context,
      selectedCategory: _selectedCategory,
      onSelectCategory: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  void _showSectionToast(String sectionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'بخش $sectionTitle به‌زودی در به‌روزرسانی‌های بعدی کامل‌تر می‌شود.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'IRANSans'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
