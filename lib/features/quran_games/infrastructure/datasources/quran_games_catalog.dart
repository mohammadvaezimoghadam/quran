import 'package:flutter/cupertino.dart';
import '../../domain/models/quran_game_item.dart';

/// Central static catalog providing curated Quranic games data
/// separated from presentation logic.
class QuranGamesCatalog {
  /// Section 1: خفن‌ترین بازی‌های جدید بازار (شامل پرواز هدهد با موتور Flame)
  static QuranGameSection getFeaturedNewGames({int totalStars = 0}) {
    return QuranGameSection(
      title: 'خفن‌ترین بازی‌های جدید بازار',
      actionText: 'بیشتر',
      items: [
        QuranGameItem(
          id: 'hoopoe_flight',
          title: 'پرواز هدهد در آسمان نور',
          category: 'حفظ و کلمات وحی',
          description:
              'با پرواز هدهد در میان دروازه‌های کلمات قرآنی، آیات الهی را مرتب کنید، ستاره کسب نمایید و سوره‌ها را به خاطر بسپارید.',
          badge: 'موتور Flame',
          badgeColor: const Color(0xFFFF9800),
          gradientColors: const [
            Color(0xFF1E2846),
            Color(0xFFE59846),
          ],
          icon: CupertinoIcons.paperplane_fill,
          isPlayable: true,
          stars: totalStars,
          tags: ['آفلاین', 'مرحله‌ای', 'موتور Flame'],
        ),
        const QuranGameItem(
          id: 'quran_beats',
          title: 'ریتم تلاوت (Quranic Beats)',
          category: 'موسیقی و ریتم کلام وحی',
          description:
              'یک بازی ریتمیک هیجان‌انگیز بر مبنای ضرباهنگ لحن و نغمه‌های قاریان برجسته جهان اسلام. با لمس دقیق نت‌ها، آیه را در ذهن بسپارید.',
          badge: 'به‌زودی',
          badgeColor: Color(0xFF00ACC1),
          gradientColors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
          ],
          icon: CupertinoIcons.music_note,
          tags: ['صوتی', 'ریتمیک', 'لحن'],
        ),
        const QuranGameItem(
          id: 'mirrors_of_light',
          title: 'معمای آینه‌های نور',
          category: 'پازل فکری شکست نور',
          description:
              'با زاویه‌دهی به آینه‌ها، پرتو نور آیه را به سمت دل‌های تاریک هدایت کنید. هر معما با آیه «الله نور السماوات و الارض» پیوند دارد.',
          badge: 'به‌زودی',
          badgeColor: Color(0xFFFF7043),
          gradientColors: [
            Color(0xFFE65100),
            Color(0xFFF57C00),
          ],
          icon: CupertinoIcons.sun_max_fill,
          tags: ['فکری', 'پازل', 'نور'],
        ),
        const QuranGameItem(
          id: 'pixel_prophets',
          title: 'جهان پیکسلی قصص قرآن',
          category: 'ماجراجویی داستانی پیکسلی',
          description:
              'سفری جذاب به دوران پیامبران اولوالعزم با گرافیک هنری پیکسلی دو بعدی و مأموریت‌های تاریخی بر اساس روایات معتبر قرآن کریم.',
          badge: 'به‌زودی',
          badgeColor: Color(0xFFAB47BC),
          gradientColors: [
            Color(0xFF4A148C),
            Color(0xFF7B1FA2),
          ],
          icon: CupertinoIcons.cube_box_fill,
          tags: ['ماجراجویی', 'پیکسلی', 'قصص'],
        ),
        const QuranGameItem(
          id: 'luqman_wisdom',
          title: 'افسانه صبر و حکمت',
          category: 'داستان تعاملی و ماجراجویی',
          description:
              'داستانی پندآموز پیرامون حکمت‌های لقمان حکیم و قصه‌های قرآنی با انتخاب‌های سرنوشت‌ساز و اخلاقی بازیکن.',
          badge: 'به‌زودی',
          badgeColor: Color(0xFFFFB300),
          gradientColors: [
            Color(0xFF3E2723),
            Color(0xFF5D4037),
          ],
          icon: CupertinoIcons.book_fill,
          tags: ['داستانی', 'حکمت', 'اخلاقی'],
        ),
      ],
    );
  }

  /// Section 2: گشت و گذار در بازی‌ها (با برچسب ویژه •)
  static QuranGameSection getExploreGames() {
    return const QuranGameSection(
      title: 'گشت و گذار در بازی‌ها',
      tag: 'ویژه •',
      actionText: '',
      items: [
        QuranGameItem(
          id: 'sky_words',
          title: 'کلمات آسمانی (مرتب‌سازی)',
          category: 'مهارت حافظه و چینش کلمات',
          description:
              'کلمات به‌هم‌ریخته آیه را در سریع‌ترین زمان روی خط آسمان مرتب کنید و ستاره‌های نقره‌ای حفظ را به دست آورید.',
          badge: 'حفظ آیه',
          badgeColor: Color(0xFF43A047),
          gradientColors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
          ],
          icon: CupertinoIcons.textformat_abc,
          tags: ['حفظ', 'کلمات', 'سرعت'],
        ),
        QuranGameItem(
          id: 'quran_mench',
          title: 'منچت قرآنی (مسابقه آنلاین)',
          category: 'تخته و تاس آنلاین',
          description:
              'با دوستان خود آنلاین منچ بازی کنید و با پاسخ به پرسش‌های قرآنی در خانه‌های ویژه، زودتر به خانه امن بهشت برسید!',
          badge: 'آنلاین',
          badgeColor: Color(0xFFE53935),
          gradientColors: [
            Color(0xFF0D47A1),
            Color(0xFFC62828),
          ],
          icon: CupertinoIcons.circle_grid_hex_fill,
          tags: ['آنلاین', 'چندنفره', 'تخته'],
        ),
        QuranGameItem(
          id: 'godfather_quran',
          title: 'یاران حق : نبرد با وسوسه‌ها',
          category: 'نقش‌آفرینی فکری و استراتژی',
          description:
              'تشخیص منافقان و شیاطین وسوسه‌گر با استفاده از آیات روشنگر سوره منافقون و بقره.',
          badge: 'هیجانی',
          badgeColor: Color(0xFFD81B60),
          gradientColors: [
            Color(0xFF37474F),
            Color(0xFF546E7A),
          ],
          icon: CupertinoIcons.shield_fill,
          tags: ['استراتژی', 'نقش‌آفرینی'],
        ),
        QuranGameItem(
          id: 'marpoo',
          title: 'مارپو: ماروپله آسمان',
          category: 'بازی دورهمی با مفاهیم گناه و ثواب',
          description:
              'نردبان‌های کارهای نیک شما را بالا می‌برند و مارهای رذایل اخلاقی به پایین می‌کشانند. آموزنده برای کودکان و نوجوانان.',
          badge: 'خانوادگی',
          badgeColor: Color(0xFF8E24AA),
          gradientColors: [
            Color(0xFF4A148C),
            Color(0xFF8E24AA),
          ],
          icon: CupertinoIcons.chart_bar_alt_fill,
          tags: ['خانوادگی', 'آموزنده'],
        ),
      ],
    );
  }

  /// Section 3: بازی‌های کم‌حجم
  static QuranGameSection getLightweightGames() {
    return const QuranGameSection(
      title: 'بازی‌های کم‌حجم',
      actionText: 'بیشتر',
      items: [
        QuranGameItem(
          id: 'zambix_waswas',
          title: 'زامبیکس – نبرد با وسواس',
          category: 'آرکید مهارتی کم‌حجم',
          description:
              'شلیک با تیرهای نوری ذکر استعاذه به افکار منفی و شیاطین برای رهایی قلب انسان.',
          badge: 'کم‌حجم',
          badgeColor: Color(0xFFFB8C00),
          gradientColors: [
            Color(0xFFE65100),
            Color(0xFFFFB300),
          ],
          icon: CupertinoIcons.bolt_fill,
          tags: ['کم‌حجم', 'اکشن فکری'],
        ),
        QuranGameItem(
          id: 'quiz_pick',
          title: 'کوییز پیک قرآنی',
          category: 'اطلاعات عمومی و تدبر در آیات',
          description:
              'هزاران سوال تستی درباره شأن نزول، اعجاز علمی و داستان‌های آموزنده قرآن کریم.',
          badge: 'معما',
          badgeColor: Color(0xFFFDD835),
          gradientColors: [
            Color(0xFF4E342E),
            Color(0xFF6D4C41),
          ],
          icon: CupertinoIcons.question_circle_fill,
          tags: ['معما', 'اطلاعات عمومی'],
        ),
        QuranGameItem(
          id: 'cat_puzzle',
          title: 'پازل گربه و نقوش محراب',
          category: 'لگو و پازل سنتی کاشی‌کاری اسلامی',
          description:
              'آرامش محض با چیدمان قطعات اسلیمی و کاشی‌کاری‌های فیروزه‌ای مساجد تاریخی جهان اسلام.',
          badge: '۱۰۰۰+ مرحله',
          badgeColor: Color(0xFF26A69A),
          gradientColors: [
            Color(0xFF004D40),
            Color(0xFF00897B),
          ],
          icon: CupertinoIcons.sparkles,
          tags: ['پازل', 'آرامش'],
        ),
        QuranGameItem(
          id: 'constellation',
          title: 'اتصال ستارگان وحی',
          category: 'اتصال نقاط و شکل‌گیری آیات',
          description:
              'نقاط درخشان ستاره‌ها را به هم وصل کنید تا صورت فلکی نام سوره‌ها پدیدار شود.',
          badge: 'آفلاین',
          badgeColor: Color(0xFF3949AB),
          gradientColors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
          ],
          icon: CupertinoIcons.star_fill,
          tags: ['آفلاین', 'خطوط نور'],
        ),
      ],
    );
  }

  /// Section 4: چالش‌های جدید رو از دست نده
  static QuranGameSection getUpcomingChallenges() {
    return const QuranGameSection(
      title: 'چالش‌های جدید رو از دست نده',
      actionText: 'بیشتر',
      items: [
        QuranGameItem(
          id: 'weekly_league',
          title: 'لیگ هفتگی حافظان',
          category: 'مسابقات هفتگی آنلاین سراسری',
          description:
              'هر هفته در چالش حفظ یک جزء از قرآن شرکت کنید و در جدول رتبه‌بندی صدرنشین شوید.',
          badge: 'جایزه هفتگی',
          badgeColor: Color(0xFFFFD54F),
          gradientColors: [
            Color(0xFF4527A0),
            Color(0xFF512DA8),
          ],
          icon: CupertinoIcons.rosette,
          tags: ['مسابقه', 'لیگ', 'جایزه'],
        ),
        QuranGameItem(
          id: 'recitation_speed',
          title: 'چالش سرعت تلاوت',
          category: 'سرعت و دقت تشخیص حرکات و اعراب',
          description:
              'آزمون هیجان‌انگیز تشخیص روان‌خوانی و قرائت صحیح کلمات در کمترین زمان ممکن.',
          badge: 'سرعتی',
          badgeColor: Color(0xFF00E676),
          gradientColors: [
            Color(0xFF004D40),
            Color(0xFF00796B),
          ],
          icon: CupertinoIcons.stopwatch_fill,
          tags: ['سرعت', 'روان‌خوانی'],
        ),
        QuranGameItem(
          id: 'tajweed_quiz',
          title: 'آزمون چهارگزینه‌ای تجوید',
          category: 'آموزش و تسلط بر احکام قرائت',
          description:
              'یادگیری تجوید، ادغام، اخفاء و مخارج حروف به روش بازی‌های مرحله‌ای جذاب.',
          badge: 'آموزشی',
          badgeColor: Color(0xFF40C4FF),
          gradientColors: [
            Color(0xFF01579B),
            Color(0xFF0277BD),
          ],
          icon: CupertinoIcons.checkmark_seal_fill,
          tags: ['تجوید', 'آموزش'],
        ),
      ],
    );
  }

  /// دسته‌بندی‌های فیلتر بازی‌ها
  static const List<Map<String, dynamic>> categories = [
    {'title': 'همه بازی‌ها', 'icon': CupertinoIcons.square_grid_2x2},
    {'title': 'حفظ و کلمات وحی', 'icon': CupertinoIcons.book},
    {'title': 'صوت و لحن و ریتم', 'icon': CupertinoIcons.music_note},
    {'title': 'پازل و هوش قرآنی', 'icon': CupertinoIcons.cube_box},
    {'title': 'مسابقات و لیگ آنلاین', 'icon': CupertinoIcons.rosette},
  ];
}
