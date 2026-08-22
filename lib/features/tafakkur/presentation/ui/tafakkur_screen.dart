import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tafakkur_detail_screen.dart';

// Design Tokens (Hayat Dark System)
const Color bgSurface = Color(0xFF121212);
const Color outerCardBg = Color(0xFF181717);
const Color avatarBg = Color(0xFF2C2C2E);
const Color badgeActiveBg = Color(0xFF2D3B32);
const Color badgeActiveText = Color(0xFFA8CFBC);
const Color countBadgeBg = Color(0xFFE5E2E1);
const Color countBadgeText = Color(0xFF121212);
const Color textPrimary = Color(0xFFFFFFFF);
const Color textSecondary = Color(0xFF9E9E9E);
const Color outlineVariant = Color(0xFF282828);

/// TafakkurScreen - 100% Pixel-Perfect match to updated user screenshot
class TafakkurScreen extends StatelessWidget {
  const TafakkurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_TopicItemData> items = [
      _TopicItemData(
        initial: 'ت',
        title: 'تست دونیت',
        subtitle: 'تست',
        date: '۱۴۰۵/۵/۲۷',
        count: null,
      ),
      _TopicItemData(
        initial: 'ا',
        title: 'امین ادهمی ((آرشیو))',
        subtitle: 'شب عاشقان بی‌دل چه شبی دراز باشد تو بیا کز اول شب درِ صبح باز باشد ع...',
        date: '۱۴۰۵/۵/۲۷',
        count: '۴۴۹',
      ),
      _TopicItemData(
        initial: 'ا',
        title: 'امین ادهمی از ۲۶ مرداد',
        isActive: true,
        subtitle: 'بخت جوان دارد آن که با تو قرین است پیر نگردد که در بهشت برین است دی...',
        date: '۱۴۰۵/۵/۲۶',
        count: '۹',
      ),
      _TopicItemData(
        initial: 'م',
        title: 'مجله تفکر از ۲۶ مرداد',
        isActive: true,
        subtitle: 'آل عمران كُنْتُمْ خَيْرَ أُمَّةٍ أُخْرِجَتْ لِلنَّاسِ تَأْمُرُونَ بِالْمَعْرُوفِ وَتَنْهَوْنَ عَنِ الْمُنْكَرِ ...',
        date: '۱۴۰۵/۵/۲۶',
        count: '۱۲',
      ),
      _TopicItemData(
        initial: 'ت',
        title: 'مجله تفکر',
        subtitle: 'الرحمن كُلُّ مَنْ عَلَيْهَا فَانٍ هر که روی زمین است دستخوش مرگ و فناست.(...',
        date: '۱۴۰۵/۵/۶',
        count: '۱۹۰۸',
      ),
      _TopicItemData(
        initial: 'ت',
        title: 'تست اپدیت ۴.۷.۴',
        isActive: true,
        subtitle: 'سلام تست',
        date: '۱۴۰۵/۵/۳',
        count: '۲',
      ),
      _TopicItemData(
        initial: 'ت',
        title: 'تاپیک تست',
        isActive: true,
        subtitle: 'سومین روز وداع شد امروز چند خطی در مورد ولایت فقیه می‌نویسم به زبان...',
        date: '۱۴۰۵/۴/۱۴',
        count: '۱',
      ),
      _TopicItemData(
        initial: 'ت',
        title: 'کانال تفکر',
        isActive: true,
        subtitle: 'سلام',
        date: '۱۴۰۵/۴/۱۰',
        count: '۱',
      ),
    ];

    return Scaffold(
      backgroundColor: bgSurface,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),

              // 1. Search Box Top Header (Fixed at top)
              _buildTopSearchBar(),

              // 2. Main Outer Rounded Card containing Scrollable List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: outerCardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 120,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TafakkurDetailScreen(
                                    topicTitle: item.title,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: _buildTopicListItem(item),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 4. Floating Action Button (+) Bottom Right
          Positioned(
            right: 24,
            bottom: 88,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E2E1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: outlineVariant,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  customBorder: const CircleBorder(),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.add,
                      color: Color(0xFF121212),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Search Pill Header
  // ---------------------------------------------------------------------------
  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bgSurface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: outlineVariant,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'تفکر',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Icon(
              CupertinoIcons.search,
              color: textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Topic List Item
  // ---------------------------------------------------------------------------
  Widget _buildTopicListItem(_TopicItemData item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Right Side Avatar Badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: avatarBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              item.initial,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Middle Content (Title + Active Badge + Subtitle Excerpt)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  if (item.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeActiveBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'فعال',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeActiveText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              Text(
                item.subtitle,
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

        const SizedBox(width: 12),

        // Left Side Metadata Column (Date on top, Count Pill on bottom)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.date,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            if (item.count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: countBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.count!,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: countBadgeText,
                  ),
                ),
              )
            else
              const SizedBox(height: 18),
          ],
        ),
      ],
    );
  }
}

class _TopicItemData {
  final String initial;
  final String title;
  final String subtitle;
  final String date;
  final String? count;
  final bool isActive;

  _TopicItemData({
    required this.initial,
    required this.title,
    required this.subtitle,
    required this.date,
    this.count,
    this.isActive = false,
  });
}
