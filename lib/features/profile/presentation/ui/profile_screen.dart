import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/app_header.dart';

/// ProfileScreen - 100% Pixel-Perfect match to user provided Figma/Mockup design
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Design Tokens matching design mockup
  static const Color bgSurface = Color(0xFF131313);
  static const Color containerDark = Color(0xFF1A1919);
  static const Color containerMid = Color(0xFF222121);
  static const Color iconBadgeBg = Color(0xFF2C2B2B);
  static const Color primaryGreen = Color(0xFFB4CCBB);
  static const Color buttonGreenBg = Color(0xFF172B1E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color logoutRed = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Fixed App Header (Pinned at top)
        const AppHeader(title: 'پروفایل'),

        // 2. Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Edit Pencil Badge
                _buildAvatarSection(),

                const SizedBox(height: 12),

                // User Name
                const Text(
                  'علی رضایی',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                // Joined Date Subtitle
                const Text(
                  'عضو از ۱۴۰۱',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Wallet & Donations Summary Card
                _buildWalletCard(),

                const SizedBox(height: 20),

                // 4 Capsule Action Menu Buttons
                _buildActionCapsule(
                  icon: CupertinoIcons.chat_bubble_2,
                  title: 'موضوعات من',
                  onTap: () {},
                ),

                _buildActionCapsule(
                  icon: CupertinoIcons.bookmark,
                  title: 'آیات ذخیره شده',
                  onTap: () {},
                ),

                _buildActionCapsule(
                  icon: CupertinoIcons.creditcard,
                  title: 'تاریخچه پرداخت',
                  onTap: () {},
                ),

                _buildActionCapsule(
                  icon: CupertinoIcons.gear_alt,
                  title: 'تنظیمات برنامه',
                  onTap: () {},
                ),

                const SizedBox(height: 28),

                // Logout Button
                _buildLogoutButton(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Avatar Section with Edit Badge
  // ---------------------------------------------------------------------------
  Widget _buildAvatarSection() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Avatar Image
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: containerMid,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/user_profile_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  CupertinoIcons.person_fill,
                  color: textSecondary,
                  size: 50,
                ),
              ),
            ),
          ),

          // Pencil Edit Badge (Bottom Left in RTL)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: bgSurface,
                  width: 2.5,
                ),
              ),
              child: const Icon(
                CupertinoIcons.pencil,
                color: bgSurface,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Wallet & Donations Summary Card
  // ---------------------------------------------------------------------------
  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: containerDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top Row: Wallet Balance + Increase Credit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Balance Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'موجودی کیف پول',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '۱,۲۵۰,۰۰۰ تومان',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),

              // + افزایش اعتبار Button
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: buttonGreenBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '+ افزایش اعتبار',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: Color(0xFF2A2A2A),
              height: 1,
            ),
          ),

          // Bottom Row: Total Donations + Heart Icon Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donation Amount Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'مجموع کمک‌های نقدی',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '۴,۸۰۰,۰۰۰ تومان',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),

              // Heart Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: iconBadgeBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Capsule Button
  // ---------------------------------------------------------------------------
  Widget _buildActionCapsule({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: containerDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Right Icon Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: iconBadgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Title Text
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),

                const Spacer(),

                // Left Chevron Arrow
                const Icon(
                  CupertinoIcons.chevron_left,
                  color: textSecondary,
                  size: 16,
                ),

                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Logout Button
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              CupertinoIcons.square_arrow_right,
              color: logoutRed,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'خروج از حساب کاربری',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: logoutRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
