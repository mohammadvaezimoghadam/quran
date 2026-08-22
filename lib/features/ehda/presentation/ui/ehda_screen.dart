import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/app_header.dart';
import 'campaign_detail_screen.dart';

// Design Tokens (Hayat Modular Dark System)
const Color bgSurface = Color(0xFF131313);
const Color containerLow = Color(0xFF1C1B1B);
const Color containerMid = Color(0xFF201F1F);
const Color containerHigh = Color(0xFF2A2A2A);
const Color containerHighest = Color(0xFF353534);
const Color primaryGreen = Color(0xFFB4CCBB);
const Color onPrimary = Color(0xFF203529);
const Color primaryContainer = Color(0xFF1A2F23);
const Color onPrimaryContainer = Color(0xFF809787);
const Color textPrimary = Color(0xFFE5E2E1);
const Color textSecondary = Color(0xFFC2C8C2);
const Color outlineVariant = Color(0xFF424843);

/// EhdaScreen - Sleek, compact feed with collapsible transparency toggle & detail view navigation
class EhdaScreen extends StatefulWidget {
  const EhdaScreen({super.key});

  @override
  State<EhdaScreen> createState() => _EhdaScreenState();
}

class _EhdaScreenState extends State<EhdaScreen> {
  int _selectedCategoryIndex = 0;

  // Track expansion state for campaign card
  bool _isCard1Expanded = false;
  int _activeCard1Tab = 2; // 0: معرفی, 1: حامیان, 2: شفافیت

  final List<_CategoryData> _categories = [
    _CategoryData(title: 'همه', badgeCount: 12),
    _CategoryData(title: 'مساجد'),
    _CategoryData(title: 'مدارس', badgeCount: 4),
    _CategoryData(title: 'ایتام'),
    _CategoryData(title: 'درمان'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSurface,
      body: Column(
        children: [
          // 1. Fixed Header
          const AppHeader(title: 'اهدا'),

          // 2. Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // Horizontal Category Chips Filter
                  _buildCategoryFilterRow(),

                  const SizedBox(height: 16),

                  // Campaign Cards Feed
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Campaign Card 1: تجهیز کتابخانه مناطق محروم (Completed / Transparent)
                        _buildCompletedCampaignCard(context),

                        const SizedBox(height: 20),

                        // Campaign Card 2: حمایت از کودکان بی‌سرپرست (Active)
                        _buildActiveCampaignCard(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category Chips Filter Row
  // ---------------------------------------------------------------------------
  Widget _buildCategoryFilterRow() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final item = _categories[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : containerMid,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? primaryGreen
                      : outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? onPrimary : textPrimary,
                    ),
                  ),
                  if (item.badgeCount != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? onPrimary.withValues(alpha: 0.2)
                            : primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? onPrimary : onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Campaign Card 1 (Completed & Transparent)
  // ---------------------------------------------------------------------------
  Widget _buildCompletedCampaignCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: containerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image + Badge (Clickable to open Detail Screen)
          GestureDetector(
            onTap: () => _openCampaignDetail(
              context,
              title: 'تجهیز کتابخانه مناطق محروم',
              charityName: 'موسسه خیریه حیات',
              imagePath: 'assets/images/campaign_school_library.png',
              badgeText: 'اجرا شده و شفاف',
              isCompleted: true,
              progressValue: 1.0,
              targetAmount: '۵۰۰,۰۰۰,۰۰۰ تومان',
              raisedAmount: '۵۰۰,۰۰۰,۰۰۰ تومان',
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/campaign_school_library.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: containerMid),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          containerLow.withValues(alpha: 0.8),
                          containerLow,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: containerMid.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: primaryGreen,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'اجرا شده و شفاف',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'لینک پویش کپی شد',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Vazirmatn'),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: containerMid.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: textPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تجهیز کتابخانه مناطق محروم',
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  children: const [
                    Icon(
                      CupertinoIcons.building_2_fill,
                      size: 14,
                      color: textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'موسسه خیریه حیات',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'پیشرفت پروژه',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '۱۰۰٪',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 7,
                    backgroundColor: primaryGreen.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                ),

                const SizedBox(height: 12),

                // Goal Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'مبلغ هدف',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '۵۰۰,۰۰۰,۰۰۰ تومان',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'جمع‌آوری شده',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '۵۰۰,۰۰۰,۰۰۰ تومان',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Sleek Collapsible Toggle Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCard1Expanded = !_isCard1Expanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: containerMid,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              CupertinoIcons.doc_text_fill,
                              color: primaryGreen,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'گزارش شفافیت و جزئیات',
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _isCard1Expanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsible Expand Area (Animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Inner Tab Selector Bar
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: containerMid,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInnerTabButton('معرفی', 0),
                              ),
                              Expanded(
                                child: _buildInnerTabButton('حامیان (۲۰)', 1),
                              ),
                              Expanded(
                                child: _buildInnerTabButton('شفافیت', 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (_activeCard1Tab == 0) _buildIntroContent(),
                        if (_activeCard1Tab == 1) _buildBackersContent(context),
                        if (_activeCard1Tab == 2) _buildTransparencyContent(context),
                      ],
                    ),
                  ),
                  crossFadeState: _isCard1Expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerTabButton(String title, int index) {
    final bool isSelected = _activeCard1Tab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCard1Tab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryGreen.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryGreen : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroContent() {
    return const Text(
      'این پروژه با هدف تجهیز کتابخانه در مناطق کم‌برخوردار و ایجاد فضای آموزشی مناسب برای کودکان و نوجوانان تعریف شده است.',
      style: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        height: 1.5,
        color: textSecondary,
      ),
    );
  }

  Widget _buildBackersContent(BuildContext context) {
    final top5Backers = [
      {'name': 'محمد رضایی', 'time': '۲ ساعت پیش', 'amount': '۵۰,۰۰۰ تومان'},
      {'name': 'سارا احمدی', 'time': '۵ ساعت پیش', 'amount': '۱۰۰,۰۰۰ تومان'},
      {'name': 'کاربر ناشناس', 'time': 'دیروز', 'amount': '۲۰,۰۰۰ تومان'},
      {'name': 'علی حسینی', 'time': '۲ روز پیش', 'amount': '۲۰۰,۰۰۰ تومان'},
      {'name': 'زهرا کریمی', 'time': '۳ روز پیش', 'amount': '۵۰۰,۰۰۰ تومان'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...top5Backers.map((b) => _BackerItemRow(
              name: b['name']!,
              time: b['time']!,
              amount: b['amount']!,
            )),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AllBackersModalSheet(),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: containerMid,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      CupertinoIcons.search,
                      color: primaryGreen,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'جستجو و مشاهده تمام ۲۰ حامی',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  CupertinoIcons.chevron_left,
                  color: textSecondary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransparencyContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تمامی ۱۲۰ بسته معیشتی تهیه و به دست خانواده‌های تحت پوشش رسید.',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12,
            height: 1.5,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _openCampaignDetail(
            context,
            title: 'تجهیز کتابخانه مناطق محروم',
            charityName: 'موسسه خیریه حیات',
            imagePath: 'assets/images/campaign_school_library.png',
            badgeText: 'اجرا شده و شفاف',
            isCompleted: true,
            progressValue: 1.0,
            targetAmount: '۵۰۰,۰۰۰,۰۰۰ تومان',
            raisedAmount: '۵۰۰,۰۰۰,۰۰۰ تومان',
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: const [
              Text(
                'مشاهده کامل ریز هزینه‌ها و فاکتورها',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_left,
                color: primaryGreen,
                size: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Campaign Card 2 (Active Campaign CTA)
  // ---------------------------------------------------------------------------
  Widget _buildActiveCampaignCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: containerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image + Badge (Clickable to open Detail Screen)
          GestureDetector(
            onTap: () => _openCampaignDetail(
              context,
              title: 'حمایت از کودکان بی‌سرپرست',
              charityName: 'بنیاد نیکوکاری امان',
              imagePath: 'assets/images/campaign_medical_aid.png',
              badgeText: 'در حال جمع‌آوری',
              isCompleted: false,
              progressValue: 0.42,
              targetAmount: '۲۰۰,۰۰۰,۰۰۰ تومان',
              raisedAmount: '۸۴,۰۰۰,۰۰۰ تومان',
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/campaign_medical_aid.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: containerMid),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          containerLow.withValues(alpha: 0.8),
                          containerLow,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: containerMid.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'در حال جمع‌آوری',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'لینک پویش کپی شد',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Vazirmatn'),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: containerMid.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: textPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حمایت از کودکان بی‌سرپرست',
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  children: const [
                    Icon(
                      CupertinoIcons.building_2_fill,
                      size: 14,
                      color: textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'بنیاد نیکوکاری امان',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'پیشرفت پروژه',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '۴۲٪',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.42,
                    minHeight: 7,
                    backgroundColor: primaryGreen.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'مبلغ هدف',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '۲۰۰,۰۰۰,۰۰۰ تومان',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'جمع‌آوری شده',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '۸۴,۰۰۰,۰۰۰ تومان',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Active Action Button CTA: مشارکت در این مهربانی
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showDonationModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: onPrimary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'مشارکت در این مهربانی',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.heart_fill,
                          color: onPrimary,
                          size: 18,
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
    );
  }

  void _openCampaignDetail(
    BuildContext context, {
    required String title,
    required String charityName,
    required String imagePath,
    required String badgeText,
    required bool isCompleted,
    required double progressValue,
    required String targetAmount,
    required String raisedAmount,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CampaignDetailScreen(
          title: title,
          charityName: charityName,
          imagePath: imagePath,
          badgeText: badgeText,
          isCompleted: isCompleted,
          progressValue: progressValue,
          targetAmount: targetAmount,
          raisedAmount: raisedAmount,
        ),
      ),
    );
  }

  void _showDonationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _DonationModalWidget();
      },
    );
  }
}

class _BackerItemRow extends StatelessWidget {
  final String name;
  final String time;
  final String amount;

  const _BackerItemRow({
    required this.name,
    required this.time,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: containerMid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: textPrimary,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationModalWidget extends StatefulWidget {
  const _DonationModalWidget();

  @override
  State<_DonationModalWidget> createState() => _DonationModalWidgetState();
}

class _DonationModalWidgetState extends State<_DonationModalWidget> {
  int _selectedQuickAmountIndex = 1;
  bool _isAnonymous = false;
  final TextEditingController _customAmountController =
      TextEditingController(text: '۵۰,۰۰۰');

  final List<String> _quickAmounts = [
    '۵۰۰,۰۰۰',
    '۱۰۰,۰۰۰',
    '۵۰,۰۰۰',
    '۲۰,۰۰۰',
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: containerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.heart_fill,
                      color: primaryGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'مشارکت در پویش مهربانی',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'حمایت از کودکان بی‌سرپرست و تامین بسته‌های معیشتی',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'مبالغ پیشنهادی سریع (تومان)',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_quickAmounts.length, (index) {
              final isSelected = _selectedQuickAmountIndex == index;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedQuickAmountIndex = index;
                        _customAmountController.text = _quickAmounts[index];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : containerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? primaryGreen
                              : outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _quickAmounts[index],
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? onPrimary : textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          const Text(
            'مبلغ دلخواه پرداختی',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: containerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const Text(
                  'تومان',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _isAnonymous = !_isAnonymous;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Flexible(
                  child: Text(
                    'حمایت به صورت کاربر ناشناس (عدم نمایش نام در لیست حامیان)',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  _isAnonymous
                      ? CupertinoIcons.checkmark_square_fill
                      : CupertinoIcons.square,
                  color: _isAnonymous ? primaryGreen : textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'مشارکت شما با موفقیت ثبت شد. با تشکر از همراهی شما.',
                      style: TextStyle(fontFamily: 'Vazirmatn'),
                    ),
                    backgroundColor: primaryContainer,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: bgSurface,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'پرداخت و ثبت حمایت',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.creditcard,
                    color: bgSurface,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final int? badgeCount;

  _CategoryData({required this.title, this.badgeCount});
}
