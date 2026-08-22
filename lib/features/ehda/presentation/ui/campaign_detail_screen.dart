import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Design Tokens (Hayat Modular Dark System)
const Color bgSurface = Color(0xFF131313);
const Color containerLow = Color(0xFF1C1B1B);
const Color containerMid = Color(0xFF201F1F);
const Color containerHigh = Color(0xFF2A2A2A);
const Color primaryGreen = Color(0xFFB4CCBB);
const Color onPrimary = Color(0xFF203529);
const Color primaryContainer = Color(0xFF1A2F23);
const Color textPrimary = Color(0xFFE5E2E1);
const Color textSecondary = Color(0xFFC2C8C2);
const Color outlineVariant = Color(0xFF424843);

/// CampaignDetailScreen - Dedicated detailed screen with smooth parallax collapsing header image
class CampaignDetailScreen extends StatefulWidget {
  final String title;
  final String charityName;
  final String imagePath;
  final String badgeText;
  final bool isCompleted;
  final double progressValue;
  final String targetAmount;
  final String raisedAmount;

  const CampaignDetailScreen({
    super.key,
    required this.title,
    required this.charityName,
    required this.imagePath,
    required this.badgeText,
    required this.isCompleted,
    required this.progressValue,
    required this.targetAmount,
    required this.raisedAmount,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  int _activeTab = 2; // 0: معرفی, 1: حامیان, 2: شفافیت (Default)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // 1. Smooth Collapsing Parallax Header Image
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: bgSurface,
            elevation: 4,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.chevron_right,
                  color: textPrimary,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              titlePadding: const EdgeInsets.only(left: 20, right: 60, bottom: 14),
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 12,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.imagePath,
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
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          bgSurface.withValues(alpha: 0.6),
                          bgSurface,
                        ],
                        stops: const [0.0, 0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: containerMid.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isCompleted) ...[
                            const Icon(
                              CupertinoIcons.checkmark_seal_fill,
                              color: primaryGreen,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            widget.badgeText,
                            style: const TextStyle(
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
                ],
              ),
            ),
          ),

          // 2. Scrollable Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Charity Name Subtitle
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.building_2_fill,
                        size: 16,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.charityName,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Stats Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: containerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'پیشرفت پروژه',
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 13,
                                color: textSecondary,
                              ),
                            ),
                            Text(
                              '${(widget.progressValue * 100).toInt()}٪',
                              style: const TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: widget.progressValue,
                            minHeight: 8,
                            backgroundColor:
                                primaryGreen.withValues(alpha: 0.2),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'مبلغ هدف',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.targetAmount,
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'جمع‌آوری شده',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.raisedAmount,
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tab Bar Selector
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: containerMid,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabButton(
                            title: 'معرفی',
                            index: 0,
                          ),
                        ),
                        Expanded(
                          child: _buildTabButton(
                            title: 'حامیان (۲۰)',
                            index: 1,
                          ),
                        ),
                        Expanded(
                          child: _buildTabButton(
                            title: 'شفافیت',
                            index: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tab Content Body
                  if (_activeTab == 0) _buildIntroTabContent(),
                  if (_activeTab == 1) _buildBackersTabContent(),
                  if (_activeTab == 2) _buildTransparencyTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String title, required int index}) {
    final bool isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
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

  Widget _buildIntroTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'توضیحات کامل پروژه',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'این پروژه با هدف تجهیز کتابخانه در مناطق کم‌برخوردار و ایجاد فضای آموزشی مناسب برای کودکان و نوجوانان تعریف شده است. با حمایت خیرین و مردم عزیز، قفسه‌های کتاب استاندارد، میز و صندلی‌های مطالعه، سیستم‌های هوشمند و بیش از ۵۰۰ جلد کتاب مرجع تهیه و نصب گردید.',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 14,
            height: 1.7,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBackersTabContent() {
    final topBackers = [
      {'name': 'محمد رضایی', 'time': '۲ ساعت پیش', 'amount': '۵۰,۰۰۰ تومان'},
      {'name': 'سارا احمدی', 'time': '۵ ساعت پیش', 'amount': '۱۰۰,۰۰۰ تومان'},
      {'name': 'کاربر ناشناس', 'time': 'دیروز', 'amount': '۲۰,۰۰۰ تومان'},
      {'name': 'علی حسینی', 'time': '۲ روز پیش', 'amount': '۲۰۰,۰۰۰ تومان'},
      {'name': 'زهرا کریمی', 'time': '۳ روز پیش', 'amount': '۵۰۰,۰۰۰ تومان'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'آخرین حامیان',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(
              'نمایش ۵ از ۲۰',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11,
                color: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...topBackers.map((b) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: containerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: containerMid,
                      child: Text(
                        b['name']!.substring(0, 1),
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['name']!,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b['time']!,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  b['amount']!,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Show All 20 Backers Button CTA (Matching exact main screen style)
        InkWell(
          onTap: () => _showAllBackersModal(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
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

  void _showAllBackersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AllBackersModalSheet(),
    );
  }

  Widget _buildTransparencyTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: primaryGreen,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'گزارش رسمی اجرای پویش',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'تمامی ۱۲۰ بسته معیشتی و اقلام کتابخانه‌ای تهیه و با حفظ کرامت انسانی به دست مخاطبان رسید. فاکتورهای رسمی زیر به تایید مراجع حسابرسی رسیده است.',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            height: 1.6,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // Expense Breakdown
        const Text(
          'ریز هزینه‌های انجام شده:',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: containerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildExpenseRow('خرید اقلام غذایی و ارزاق', '۵۵,۰۰۰,۰۰۰ تومان'),
              const SizedBox(height: 10),
              _buildExpenseRow('خرید بسته‌های نوشت‌افزار', '۳۰,۰۰۰,۰۰۰ تومان'),
              const SizedBox(height: 10),
              _buildExpenseRow('هزینه حمل و توزیع', '۵,۰۰۰,۰۰۰ تومان'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(height: 1, color: outlineVariant),
              ),
              _buildExpenseRow('جمع کل', '۹۰,۰۰۰,۰۰۰ تومان', isTotal: true),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Invoice Images
        const Text(
          'تصاویر فاکتورها و رسیدها:',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildInvoiceThumbnail('assets/images/invoice_receipt_1.png'),
              const SizedBox(width: 12),
              _buildInvoiceThumbnail('assets/images/invoice_receipt_2.png'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            color: isTotal ? primaryGreen : textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isTotal ? primaryGreen : textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceThumbnail(String path) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: containerMid),
      ),
    );
  }
}

/// AllBackersModalSheet - Bottom sheet to search & browse all supporters
class AllBackersModalSheet extends StatefulWidget {
  const AllBackersModalSheet({super.key});

  @override
  State<AllBackersModalSheet> createState() => _AllBackersModalSheetState();
}

class _AllBackersModalSheetState extends State<AllBackersModalSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allBackers = const [
    {'name': 'محمد رضایی', 'time': '۲ ساعت پیش', 'amount': '۵۰,۰۰۰ تومان'},
    {'name': 'سارا احمدی', 'time': '۵ ساعت پیش', 'amount': '۱۰۰,۰۰۰ تومان'},
    {'name': 'کاربر ناشناس', 'time': 'دیروز', 'amount': '۲۰,۰۰۰ تومان'},
    {'name': 'علی حسینی', 'time': '۲ روز پیش', 'amount': '۲۰۰,۰۰۰ تومان'},
    {'name': 'زهرا کریمی', 'time': '۳ روز پیش', 'amount': '۵۰۰,۰۰۰ تومان'},
    {'name': 'امیرحسین نوری', 'time': '۳ روز پیش', 'amount': '۱۵۰,۰۰۰ تومان'},
    {'name': 'مریم کاظمی', 'time': '۴ روز پیش', 'amount': '۳۰,۰۰۰ تومان'},
    {'name': 'حمیدرضا شریفی', 'time': '۵ روز پیش', 'amount': '۱,۰۰۰,۰۰۰ تومان'},
    {'name': 'نیلوفر طاهری', 'time': '۶ روز پیش', 'amount': '۵۰,۰۰۰ تومان'},
    {'name': 'حسین موسوی', 'time': '۱ هفته پیش', 'amount': '۲۵۰,۰۰۰ تومان'},
    {'name': 'فاطمه ابراهیمی', 'time': '۱ هفته پیش', 'amount': '۱۰۰,۰۰۰ تومان'},
    {'name': 'رضا صادقی', 'time': '۱ هفته پیش', 'amount': '۷۰,۰۰۰ تومان'},
    {'name': 'نازنین قاسمی', 'time': '۲ هفته پیش', 'amount': '۵۰۰,۰۰۰ تومان'},
    {'name': 'مهدی باقری', 'time': '۲ هفته پیش', 'amount': '۴۰,۰۰۰ تومان'},
    {'name': 'الهام مرادی', 'time': '۳ هفته پیش', 'amount': '۲۰۰,۰۰۰ تومان'},
    {'name': 'سینا دهقان', 'time': '۳ هفته پیش', 'amount': '۱۵۰,۰۰۰ تومان'},
    {'name': 'پریسا نجفی', 'time': '۱ ماه پیش', 'amount': '۳۰۰,۰۰۰ تومان'},
    {'name': 'کامران افشار', 'time': '۱ ماه پیش', 'amount': '۸۰,۰۰۰ تومان'},
    {'name': 'زهرا یوسفی', 'time': '۱ ماه پیش', 'amount': '۱۲۰,۰۰۰ تومان'},
    {'name': 'محمدرضا سلیمانی', 'time': '۱ ماه پیش', 'amount': '۴۰۰,۰۰۰ تومان'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allBackers.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b['name']!.contains(_searchQuery);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: containerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                      'لیست کامل حامیان (۲۰ نفر)',
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
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: containerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.search,
                    color: textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        color: textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'جستجوی نام حامی...',
                        hintStyle: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          color: textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      child: const Icon(
                        CupertinoIcons.clear_circled_solid,
                        color: textSecondary,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Supporters Count Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نتایج یافت‌شده: ${filtered.length} نفر',
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const Text(
                  'ترتیب: جدیدترین‌ها',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: outlineVariant),

          // Scrollable Supporters List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'حامی با این مشخصات پیدا نشد.',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: containerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: containerMid,
                                  child: Text(
                                    item['name']!.substring(0, 1),
                                    style: const TextStyle(
                                      fontFamily: 'Vazirmatn',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: const TextStyle(
                                        fontFamily: 'Vazirmatn',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['time']!,
                                      style: const TextStyle(
                                        fontFamily: 'Vazirmatn',
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              item['amount']!,
                              style: const TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
