import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Design Tokens (Hayat Dark System)
const Color bgSurface = Color(0xFF121212);
const Color containerLow = Color(0xFF1C1B1B);
const Color containerMid = Color(0xFF201F1F);
const Color containerHigh = Color(0xFF2A2A2A);
const Color primaryGreen = Color(0xFFB4CCBB);
const Color textPrimary = Color(0xFFFFFFFF);
const Color textSecondary = Color(0xFF9E9E9E);
const Color outlineVariant = Color(0xFF282828);

/// TafakkurDetailScreen - Topic detail page matching user screenshot
class TafakkurDetailScreen extends StatelessWidget {
  final String topicTitle;

  const TafakkurDetailScreen({super.key, required this.topicTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar
            _buildTopAppBar(context),

            // 2. Scrollable Posts List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                children: [
                  // Post 1: Text-only post
                  _buildPostCard1(),

                  const SizedBox(height: 16),

                  // Post 2: User Post with Image Attachment
                  _buildPostCard2(),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 3. Bottom Fixed Input Bar (Read-only / No Permission State)
            _buildBottomInputBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top App Bar
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgSurface,
        border: Border(
          bottom: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              CupertinoIcons.chevron_right,
              color: textPrimary,
              size: 24,
            ),
          ),

          const SizedBox(width: 8),

          // Topic Title
          Expanded(
            child: Text(
              topicTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),

          // Options / Ellipsis Button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.ellipsis_vertical,
              color: textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Post Card 1 (Text Post)
  // ---------------------------------------------------------------------------
  Widget _buildPostCard1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: containerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body Text
          const Text(
            'دیگه نون نخر دبرو بازار گندم فروشان این بقال جو می‌فروشد نه مشتری دارد و مغازه‌اش پر از مگس بیش از یک هفته از او کسی چیزی نخریده است\n'
            'مرد اهل دل بود گفت زن عزیزم این بنده خدا به امید ما اینجا بقالی زده این رسم همسایگی و معرفت نیست که ما طالب نفع او نباشیم ما باید پیرو مردان خدا باشیم اگر توانمند هستیم دست یک کم توان را بگیریم آنهایی که مرد خدا هستند از جایی خرید میکنند که رونق ندارد بلکه رزق روزی آن دکان بی رونق زیاد شود و این است رسم مولا علی ع او در دست گیری و جوانمردی بی نظیر بوده است',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14,
              height: 1.6,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Username Tag
          const Text(
            '@aminadhami1405',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              color: textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Share Icon (Left in RTL end)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share, color: textSecondary, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),

              // Like & Comment Count Badges (Right in RTL start)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatBadge(CupertinoIcons.chat_bubble, '۰'),
                  const SizedBox(width: 8),
                  _buildStatBadge(CupertinoIcons.heart, '۰'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Post Card 2 (User Header + Text + Image Attachment)
  // ---------------------------------------------------------------------------
  Widget _buildPostCard2() {
    return Container(
      decoration: BoxDecoration(
        color: containerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header & Date
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Right: User Avatar Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'تفکر',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: bgSurface,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // User Name & Role Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'امین ادهمی',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'عضو تاپیک',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Left: Time/Date + Options
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.clock, size: 14, color: textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '۱۴۰۵/۵/۲۲, ۱۲:۲۸',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.ellipsis_vertical,
                      size: 16,
                      color: textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Post Text Content
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'دقت کنید درخت از وسط لوله آمده است بیرون\n'
              'چون یک کورسو نور از وسط لوله به چشم آمده از وسط آن رشد کرده است\n'
              'نتیجه استمرار\n'
              '@aminadhami1405',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                height: 1.6,
                color: textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Attached Image Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                width: double.infinity,
                color: containerMid,
                child: Image.asset(
                  'assets/images/quran_image.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: containerMid,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: textSecondary,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper Stat Badge Pill
  Widget _buildStatBadge(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: containerMid,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textSecondary),
          const SizedBox(width: 4),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Fixed Read-Only Input Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgSurface,
        border: Border(
          top: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Voice Mic Button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.mic,
              color: textSecondary,
              size: 22,
            ),
          ),

          // Center Pill Warning Message
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: containerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.info_circle,
                    size: 16,
                    color: textSecondary,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'شما اجازه ارسال پیام در این تاپیک را ندارید.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Attachment Paperclip Button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.paperclip,
              color: textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
