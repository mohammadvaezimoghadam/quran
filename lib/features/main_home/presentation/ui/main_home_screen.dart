import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_header.dart';
import '../../../../core/routes/route_name.dart';
import '../../../ehda/presentation/ui/ehda_screen.dart';
import '../../../profile/presentation/ui/profile_screen.dart';
import '../../../tafakkur/presentation/ui/tafakkur_detail_screen.dart';
import '../../../tafakkur/presentation/ui/tafakkur_screen.dart';

// Design Tokens (Hayat Modular Dark System)
const Color bgSurface = Color(0xFF131313);
const Color containerLow = Color(0xFF1C1B1B);
const Color containerMid = Color(0xFF201F1F);
const Color containerHigh = Color(0xFF2A2A2A);
const Color primaryGreen = Color(0xFFB4CCBB);
const Color primaryContainer = Color(0xFF1A2F23);
const Color mintAccent = Color(0xFFA8CFBC);
const Color textPrimary = Color(0xFFE5E2E1);
const Color textSecondary = Color(0xFFC2C8C2);
const Color outlineVariant = Color(0xFF424843);
const Color errorRed = Color(0xFFFFB4AB);

/// MainHomeScreen - Completely hardcoded UI matching design_1 (Hayat Modular System)
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSurface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Active Tab Page
            IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTabContent(context),
                const TafakkurScreen(),
                const EhdaScreen(),
                const ProfileScreen(),
              ],
            ),

            // Fixed Glassmorphism Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTabContent(BuildContext context) {
    return Column(
      children: [
        // Fixed Header for Home
        const AppHeader(title: 'خانه'),

        // Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 120, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bento Grid Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildBentoGrid(context),
                ),

                const SizedBox(height: 16),

                // Donation Campaigns Section
                _buildDonationCampaignsSection(context),

                const SizedBox(height: 32),

                // Trending Discussions Section
                _buildTrendingDiscussionsSection(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Bento Grid Section
  // ---------------------------------------------------------------------------
  Widget _buildBentoGrid(BuildContext context) {
    return SizedBox(
      height: 185,
      child: Row(
        children: [
          // 1. Tall Vertical Radio Golha Card (1/3 width, full 185px height)
          Expanded(
            flex: 4,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: containerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    'assets/images/radio_gramophone.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: containerHigh,
                      child: const Icon(CupertinoIcons.radiowaves_right, color: textSecondary, size: 28),
                    ),
                  ),
                  // Dark Overlay Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  // Text & Icon
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          CupertinoIcons.music_note_2,
                          color: primaryGreen,
                          size: 18,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'رادیو گل‌ها',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Right Side Column: Quran Card (Top) + 3 Utility Cards (Bottom)
          Expanded(
            flex: 8,
            child: Column(
              children: [
                // Top: Quran Hero Card
                Expanded(
                  flex: 121,
                  child: GestureDetector(
                    onTap: () => context.pushNamed(quranHomeRoute),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: containerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/quran_image.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: primaryContainer,
                              child: const Icon(CupertinoIcons.book, color: primaryGreen, size: 36),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'قرآن کریم',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'ادامه مطالعه',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 10,
                                    color: primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Bottom: Row of 3 Utility Cards (Add, Translation, Tafsir)
                Expanded(
                  flex: 56,
                  child: Row(
                    children: [
                      // 1. Add Plus Card
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: containerHigh.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryGreen.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                CupertinoIcons.add,
                                color: primaryGreen,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 2. Translation Box
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: containerHigh,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/quran_translation.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: containerHigh),
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              const Center(
                                child: Text(
                                  'ترجمه',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 3. Tafsir Box
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: containerHigh,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/quran_tafsir.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: containerHigh),
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              const Center(
                                child: Text(
                                  'تفسیر',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Donation Campaigns Section
  // ---------------------------------------------------------------------------
  Widget _buildDonationCampaignsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'پویش‌های اهدا',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pulsing Red Dot Indicator
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: const [
                    Text(
                      'همه',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_left,
                      color: primaryGreen,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Horizontal Campaign Cards ListView
        SizedBox(
          height: 270,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Campaign Card 1: کمک به سیل‌زدگان جنوب
              _buildCampaignCard(
                imagePath: 'assets/images/campaign_flood_aid.png',
                badgeText: 'در حال جمع‌آوری',
                isCompleted: false,
                title: 'کمک به سیل‌زدگان جنوب',
                description: 'تامین بسته‌های معیشتی و پتو برای ۲۰۰ خانواده آسیب‌دیده.',
                progressPercentText: '۷۵٪ تامین شده',
                timeRemainingText: '۳ روز باقی‌مانده',
                progressValue: 0.75,
              ),

              const SizedBox(width: 16),

              // Campaign Card 2: تجهیز کتابخانه مناطق محروم
              _buildCampaignCard(
                imagePath: 'assets/images/campaign_school_library.png',
                badgeText: 'اجرا شده و شفاف',
                isCompleted: true,
                title: 'تجهیز کتابخانه مناطق محروم',
                description: 'تامین کتاب و لوازم تحریر برای ۵ مدرسه در مناطق دورافتاده.',
                progressPercentText: '۱۰۰٪ تامین شده',
                timeRemainingText: 'تکمیل شده',
                progressValue: 1.0,
              ),

              const SizedBox(width: 16),

              // Campaign Card 3: تأمین دارو و درمان نیازمندان
              _buildCampaignCard(
                imagePath: 'assets/images/campaign_medical_aid.png',
                badgeText: 'در حال جمع‌آوری',
                isCompleted: false,
                title: 'تأمین دارو و درمان نیازمندان',
                description: 'تأمین هزینه دارو و درمان برای ۵۰ بیمار نیازمند در مناطق محروم.',
                progressPercentText: '۴۵٪ تامین شده',
                timeRemainingText: '۵ روز باقی‌مانده',
                progressValue: 0.45,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard({
    required String imagePath,
    required String badgeText,
    required bool isCompleted,
    required String title,
    required String description,
    required String progressPercentText,
    required String timeRemainingText,
    required double progressValue,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: containerMid,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Image + Badge
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: containerHigh),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted) ...[
                          const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: primaryGreen, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          badgeText,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Progress Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressPercentText,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      timeRemainingText,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Progress Bar Track
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: outlineVariant.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Trending Discussions Section
  // ---------------------------------------------------------------------------
  Widget _buildTrendingDiscussionsSection(BuildContext context) {
    final topics = [
      {
        'title': 'مجله تفکر',
        'initial': 'ت',
        'subtitle': 'الرحمن كُلُّ مَنْ عَلَيْهَا فَانٍ هر که روی زمین است دستخوش مرگ و فناست...',
        'date': '۱۴۰۵/۵/۶',
        'count': '۱۹۰۸',
        'isActive': false,
      },
      {
        'title': 'امین ادهمی ((آرشیو))',
        'initial': 'ا',
        'subtitle': 'شب عاشقان بی‌دل چه شبی دراز باشد تو بیا کز اول شب درِ صبح باز باشد...',
        'date': '۱۴۰۵/۵/۲۷',
        'count': '۴۴۹',
        'isActive': false,
      },
      {
        'title': 'مجله تفکر از ۲۶ مرداد',
        'initial': 'م',
        'subtitle': 'آل عمران كُنْتُمْ خَيْرَ أُمَّةٍ أُخْرِجَتْ لِلنَّاسِ تَأْمُرُونَ بِالْمَعْرُوفِ...',
        'date': '۱۴۰۵/۵/۲۶',
        'count': '۱۲',
        'isActive': true,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header (Clean without fire icon)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'داغ‌ترین تاپیک‌ها',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: const [
                    Text(
                      'مشاهده همه',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_left,
                      color: primaryGreen,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3 Tafakkur Topic Items
          ...topics.map((item) {
            final bool isActive = item['isActive'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TafakkurDetailScreen(
                        topicTitle: item['title'] as String,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: containerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: containerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            item['initial'] as String,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Main Content (Title + Subtitle)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'فعال',
                                      style: TextStyle(
                                        fontFamily: 'Vazirmatn',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Left Side (Date & Message Count Badge)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['date'] as String,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                          if (item['count'] != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: textPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['count'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: bgSurface,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Fixed Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: containerMid.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(
            color: primaryContainer.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, CupertinoIcons.house_fill, 'خانه'),
          _buildNavItem(1, CupertinoIcons.chat_bubble_2, 'تفکر'),
          _buildNavItem(2, CupertinoIcons.heart, 'اهدا'),
          _buildNavItem(3, CupertinoIcons.person, 'پروفایل'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = _selectedIndex == index;
    final color = isActive ? primaryGreen : textSecondary;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
