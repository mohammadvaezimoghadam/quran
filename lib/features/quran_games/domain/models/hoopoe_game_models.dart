import 'package:flutter/material.dart';

/// Visual and spiritual atmosphere tailored for each Surah stage
@immutable
class SurahAtmosphere {
  final String title;
  final String subtitle;
  final List<Color> skyGradient;
  final Color gateGlowColor;
  final Color gateBorderColor;
  final Color starColor;
  final Color duneColor;
  final String moodDescription;

  const SurahAtmosphere({
    required this.title,
    required this.subtitle,
    required this.skyGradient,
    required this.gateGlowColor,
    required this.gateBorderColor,
    required this.starColor,
    required this.duneColor,
    required this.moodDescription,
  });
}

/// Single word unit for a gate in the flight path
@immutable
class WordGateData {
  final String word;
  final bool isCorrect;
  final int wordIndexInAyah;

  const WordGateData({
    required this.word,
    required this.isCorrect,
    required this.wordIndexInAyah,
  });
}

/// An Ayah prepared for the game with sequential words and contextual distractors
@immutable
class GameAyah {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String fullText;
  final String translation;
  final List<String> words;
  final List<String> distractors;

  const GameAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.fullText,
    required this.translation,
    required this.words,
    required this.distractors,
  });
}

/// A playable Surah stage with level metadata, atmosphere, and star rewards
@immutable
class SurahStage {
  final int stageNumber;
  final int surahNumber;
  final String name;
  final String englishName;
  final String virtueDescription;
  final SurahAtmosphere atmosphere;
  final List<GameAyah> ayahs;

  const SurahStage({
    required this.stageNumber,
    required this.surahNumber,
    required this.name,
    required this.englishName,
    required this.virtueDescription,
    required this.atmosphere,
    required this.ayahs,
  });
}

/// Curated stages with distinct visual atmospheres
class QuranGameStages {
  static const List<SurahStage> stages = [
    // Stage 1: Al-Ikhlas (Midnight Celestial Abyss & Golden Light of Tawheed)
    SurahStage(
      stageNumber: 1,
      surahNumber: 112,
      name: 'الإخلاص',
      englishName: 'Al-Ikhlas',
      virtueDescription: 'سوره اخلاص معادل یک سوم قرآن در معرفت خدای یکتا و بی‌همتاست.',
      atmosphere: SurahAtmosphere(
        title: 'آسمان پرستاره اخلاص',
        subtitle: 'شفق کیهانی و نور طلایی توحید',
        skyGradient: [
          Color(0xFF060914),
          Color(0xFF0F1630),
          Color(0xFF192548),
          Color(0xFF2B3A68),
        ],
        gateGlowColor: Color(0xFFFFD54F),
        gateBorderColor: Color(0xFFFFCA28),
        starColor: Colors.white,
        duneColor: Color(0xFF0A0F20),
        moodDescription: 'آسمان پرستاره نیمه‌شب با دروازه‌های زرین نور',
      ),
      ayahs: [
        GameAyah(
          surahNumber: 112,
          ayahNumber: 1,
          surahName: 'الإخلاص',
          fullText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          translation: 'بگو: او خدای یکتاست.',
          words: ['قُلْ', 'هُوَ', 'اللَّهُ', 'أَحَدٌ'],
          distractors: ['أَعُوذُ', 'رَبِّ', 'الرَّحْمَٰنِ', 'صَمَدٌ'],
        ),
        GameAyah(
          surahNumber: 112,
          ayahNumber: 2,
          surahName: 'الإخلاص',
          fullText: 'اللَّهُ الصَّمَدُ',
          translation: 'خداوند بی‌نیاز است.',
          words: ['اللَّهُ', 'الصَّمَدُ'],
          distractors: ['الْحَمْدُ', 'الْغَفُورُ', 'الْكَبِيرُ', 'الْعَظِيمُ'],
        ),
        GameAyah(
          surahNumber: 112,
          ayahNumber: 3,
          surahName: 'الإخلاص',
          fullText: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          translation: 'نه زاده و نه زاده شده است.',
          words: ['لَمْ', 'يَلِدْ', 'وَلَمْ', 'يُولَدْ'],
          distractors: ['مَا', 'كَانَ', 'إِلَّا', 'يَعْلَمُ'],
        ),
        GameAyah(
          surahNumber: 112,
          ayahNumber: 4,
          surahName: 'الإخلاص',
          fullText: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          translation: 'و هیچ کس همتای او نبوده است.',
          words: ['وَلَمْ', 'يَكُن', 'لَّهُ', 'كُفُوًا', 'أَحَدٌ'],
          distractors: ['شَرِيكٌ', 'مِثْلٌ', 'نِدٌّ', 'مَلِكٌ'],
        ),
      ],
    ),

    // Stage 2: Al-Kawthar (Celestial Oasis, Turquoise Waters & Heavenly Abundance)
    SurahStage(
      stageNumber: 2,
      surahNumber: 108,
      name: 'الكوثر',
      englishName: 'Al-Kawthar',
      virtueDescription: 'کوتاه‌ترین سوره قرآن و مژده خیر کثیر و چشمه جاودان الهی.',
      atmosphere: SurahAtmosphere(
        title: 'چشمه بهشتی کوثر',
        subtitle: 'آسمان نیلگون زمردی و آب زلال',
        skyGradient: [
          Color(0xFF041C2C),
          Color(0xFF09354F),
          Color(0xFF105474),
          Color(0xFF1B748F),
        ],
        gateGlowColor: Color(0xFF4DD0E1),
        gateBorderColor: Color(0xFF26C6DA),
        starColor: Color(0xFFE0F7FA),
        duneColor: Color(0xFF052336),
        moodDescription: 'آسمان فیروزه‌ای چشمه بهشت با دروازه‌های بلورین آب',
      ),
      ayahs: [
        GameAyah(
          surahNumber: 108,
          ayahNumber: 1,
          surahName: 'الكوثر',
          fullText: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          translation: 'همانا ما به تو کوثر (خیر کثیر) عطا کردیم.',
          words: ['إِنَّا', 'أَعْطَيْنَاكَ', 'الْكَوْثَرَ'],
          distractors: ['أَنْزَلْنَا', 'جَعَلْنَا', 'الْقُرْآنَ', 'الْهُدَىٰ'],
        ),
        GameAyah(
          surahNumber: 108,
          ayahNumber: 2,
          surahName: 'الكوثر',
          fullText: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          translation: 'پس برای پروردگارت نماز بخوان و قربانی کن.',
          words: ['فَصَلِّ', 'لِرَبِّكَ', 'وَانْحَرْ'],
          distractors: ['فَاعْبُدْ', 'وَاسْجُدْ', 'وَاشْكُرْ', 'وَاصْبِرْ'],
        ),
        GameAyah(
          surahNumber: 108,
          ayahNumber: 3,
          surahName: 'الكوثر',
          fullText: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          translation: 'همانا دشمن تو خود مقطوع‌النسل و بی‌دنباله است.',
          words: ['إِنَّ', 'شَانِئَكَ', 'هُوَ', 'الْأَبْتَرُ'],
          distractors: ['الظَّالِمُ', 'الْخَاسِرُ', 'الْكَافِرُ', 'الْمُعْتَدِي'],
        ),
      ],
    ),

    // Stage 3: Al-Falaq (The Breaking Dawn & Mountain Solitude)
    SurahStage(
      stageNumber: 3,
      surahNumber: 113,
      name: 'الفلق',
      englishName: 'Al-Falaq',
      virtueDescription: 'پناه بردن به پروردگار سپیده‌دم از شر تاریکی‌ها و حسودان.',
      atmosphere: SurahAtmosphere(
        title: 'سپیده‌دم فلق',
        subtitle: 'شکافتن تاریکی و پرتوهای اولین فجر',
        skyGradient: [
          Color(0xFF141026),
          Color(0xFF281C3F),
          Color(0xFF482B55),
          Color(0xFF754569),
        ],
        gateGlowColor: Color(0xFFFFB74D),
        gateBorderColor: Color(0xFFFFA726),
        starColor: Color(0xFFFFE0B2),
        duneColor: Color(0xFF1C1330),
        moodDescription: 'گرگ و میش سحرگاهی با دروازه‌های طلایی سپیده',
      ),
      ayahs: [
        GameAyah(
          surahNumber: 113,
          ayahNumber: 1,
          surahName: 'الفلق',
          fullText: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          translation: 'بگو: پناه می‌برم به پروردگار سپیده‌دم.',
          words: ['قُلْ', 'أَعُوذُ', 'بِرَبِّ', 'الْفَلَقِ'],
          distractors: ['النَّاسِ', 'الْكَوْثَرِ', 'الصُّبْحِ', 'الْأَرْضِ'],
        ),
        GameAyah(
          surahNumber: 113,
          ayahNumber: 2,
          surahName: 'الفلق',
          fullText: 'مِن شَرِّ مَا خَلَقَ',
          translation: 'از شر تمام آنچه آفریده است.',
          words: ['مِن', 'شَرِّ', 'مَا', 'خَلَقَ'],
          distractors: ['خَيْرِ', 'كُلِّ', 'أَمْرٍ', 'رَبِّ'],
        ),
        GameAyah(
          surahNumber: 113,
          ayahNumber: 3,
          surahName: 'الفلق',
          fullText: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          translation: 'و از شر شب تاریک هنگامی که فرا رسد.',
          words: ['وَمِن', 'شَرِّ', 'غَاسِقٍ', 'إِذَا', 'وَقَبَ'],
          distractors: ['نَفَّاثَاتِ', 'حَاسِدٍ', 'عُقَدٍ', 'نَهَارٍ'],
        ),
        GameAyah(
          surahNumber: 113,
          ayahNumber: 4,
          surahName: 'الفلق',
          fullText: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          translation: 'و از شر زنان جادوگر که در گره‌ها می‌دمند.',
          words: ['وَمِن', 'شَرِّ', 'النَّفَّاثَاتِ', 'فِي', 'الْعُقَدِ'],
          distractors: ['السَّاحِرِينَ', 'الْأَشْرَارِ', 'الْمُفْسِدِينَ', 'الْقُلُوبِ'],
        ),
        GameAyah(
          surahNumber: 113,
          ayahNumber: 5,
          surahName: 'الفلق',
          fullText: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          translation: 'و از شر هر حسود آنگاه که حسد ورزد.',
          words: ['وَمِن', 'شَرِّ', 'حَاسِدٍ', 'إِذَا', 'حَسَدَ'],
          distractors: ['كَافِرٍ', 'ظَالِمٍ', 'عَدُوٍّ', 'مُنَافِقٍ'],
        ),
      ],
    ),

    // Stage 4: An-Nas (Mystic Twilight & Sanctuary from Whispers)
    SurahStage(
      stageNumber: 4,
      surahNumber: 114,
      name: 'الناس',
      englishName: 'An-Nas',
      virtueDescription: 'پناهگاهی جاودان در برابر وسوسه‌گران پنهان و آشکار.',
      atmosphere: SurahAtmosphere(
        title: 'حریم آرامش ناس',
        subtitle: 'شامگاه آرام و نور بنفش امان',
        skyGradient: [
          Color(0xFF0C1428),
          Color(0xFF142442),
          Color(0xFF243B66),
          Color(0xFF3B568C),
        ],
        gateGlowColor: Color(0xFFBA68C8),
        gateBorderColor: Color(0xFFAB47BC),
        starColor: Color(0xFFF3E5F5),
        duneColor: Color(0xFF0C152B),
        moodDescription: 'آسمان ارغوانی آرامش‌بخش با دروازه‌های بنفش یاقوتی',
      ),
      ayahs: [
        GameAyah(
          surahNumber: 114,
          ayahNumber: 1,
          surahName: 'الناس',
          fullText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          translation: 'بگو: پناه می‌برم به پروردگار مردم.',
          words: ['قُلْ', 'أَعُوذُ', 'بِرَبِّ', 'النَّاسِ'],
          distractors: ['إِلَٰهِ', 'مَلِكِ', 'الْفَلَقِ', 'شَرِّ'],
        ),
        GameAyah(
          surahNumber: 114,
          ayahNumber: 2,
          surahName: 'الناس',
          fullText: 'مَلِكِ النَّاسِ',
          translation: 'فرمانروای مردم.',
          words: ['مَلِكِ', 'النَّاسِ'],
          distractors: ['رَبِّ', 'إِلَٰهِ', 'خَالِقِ', 'نُورِ'],
        ),
        GameAyah(
          surahNumber: 114,
          ayahNumber: 3,
          surahName: 'الناس',
          fullText: 'إِلَٰهِ النَّاسِ',
          translation: 'معبودِ مردم.',
          words: ['إِلَٰهِ', 'النَّاسِ'],
          distractors: ['مَلِكِ', 'سَيِّدِ', 'غَفُورِ', 'رَحِيمِ'],
        ),
        GameAyah(
          surahNumber: 114,
          ayahNumber: 4,
          surahName: 'الناس',
          fullText: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          translation: 'از شر وسوسه‌گر پنهانکار.',
          words: ['مِن', 'شَرِّ', 'الْوَسْوَاسِ', 'الْخَنَّاسِ'],
          distractors: ['الشَّيْطَانِ', 'الرَّجِيمِ', 'الظَّالِمِ', 'الْغَاسِقِ'],
        ),
      ],
    ),

    // Stage 5: An-Nasr (Dawn of Divine Victory & Praise)
    SurahStage(
      stageNumber: 5,
      surahNumber: 110,
      name: 'النصر',
      englishName: 'An-Nasr',
      virtueDescription: 'بشارت پیروزی دین خدا و فرود آمدن رحمت و استغفار.',
      atmosphere: SurahAtmosphere(
        title: 'صبح پیروزی و نصر',
        subtitle: 'فروغ درخشان نصر الهی و سپاس',
        skyGradient: [
          Color(0xFF1E1404),
          Color(0xFF382508),
          Color(0xFF5A3C0E),
          Color(0xFF825816),
        ],
        gateGlowColor: Color(0xFFFFD54F),
        gateBorderColor: Color(0xFFFFC107),
        starColor: Color(0xFFFFF8E1),
        duneColor: Color(0xFF261905),
        moodDescription: 'آسمان زرین بامدادان فتح با دروازه‌های درخشان خورشیدی',
      ),
      ayahs: [
        GameAyah(
          surahNumber: 110,
          ayahNumber: 1,
          surahName: 'النصر',
          fullText: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          translation: 'هنگامی که یاری خدا و پیروزی فرا رسد.',
          words: ['إِذَا', 'جَاءَ', 'نَصْرُ', 'اللَّهِ', 'وَالْفَتْحُ'],
          distractors: ['أَمْرُ', 'وَعْدُ', 'فَضْلُ', 'نُورُ'],
        ),
        GameAyah(
          surahNumber: 110,
          ayahNumber: 2,
          surahName: 'النصر',
          fullText: 'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
          translation: 'و ببینی مردم گروه گروه وارد دین خدا می‌شوند.',
          words: ['وَرَأَيْتَ', 'النَّاسَ', 'يَدْخُلُونَ', 'فِي', 'دِينِ', 'اللَّهِ', 'أَفْوَاجًا'],
          distractors: ['يَعْبُدُونَ', 'يَسْتَغْفِرُونَ', 'جَمِيعًا', 'فِرَقًا'],
        ),
        GameAyah(
          surahNumber: 110,
          ayahNumber: 3,
          surahName: 'النصر',
          fullText: 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ إِنَّهُ كَانَ تَوَّابًا',
          translation: 'پس پروردگارت را تسبیح و حمد کن و از او آمرزش بخواه که بسیار توبه‌پذیر است.',
          words: ['فَسَبِّحْ', 'بِحَمْدِ', 'رَبِّكَ', 'وَاسْتَغْفِرْهُ', 'إِنَّهُ', 'كَانَ', 'تَوَّابًا'],
          distractors: ['غَفُورًا', 'رَحِيمًا', 'عَظِيمًا', 'قَرِيبًا'],
        ),
      ],
    ),

    // Stage 6: Al-Fatiha (The Crown Jewel / Mother of the Book)
    SurahStage(
      stageNumber: 6,
      surahNumber: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatiha',
      virtueDescription: 'ام‌الکتاب و شفابخش‌ترین سوره قرآن کریم.',
      atmosphere: SurahAtmosphere(
        title: 'نور اعظم فاتحه',
        subtitle: 'شهد آغازین کتاب خدا و راه مستقیم',
        skyGradient: [
          Color(0xFF0D1E16),
          Color(0xFF16382A),
          Color(0xFF22523D),
          Color(0xFF337357),
        ],
        gateGlowColor: Color(0xFF81C784),
        gateBorderColor: Color(0xFF66BB6A),
        starColor: Color(0xFFE8F5E9),
        duneColor: Color(0xFF0B1912),
        moodDescription: 'بهشت زمردین با دروازه‌های سبز قبای هدایت',
      ),
      ayahs: [
        GameAyah(
          surahNumber: 1,
          ayahNumber: 1,
          surahName: 'الفاتحة',
          fullText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'به نام خداوند بخشنده مهربان.',
          words: ['بِسْمِ', 'اللَّهِ', 'الرَّحْمَٰنِ', 'الرَّحِيمِ'],
          distractors: ['الْحَمْدُ', 'رَبِّ', 'الْعَالَمِينَ', 'مَالِكِ'],
        ),
        GameAyah(
          surahNumber: 1,
          ayahNumber: 2,
          surahName: 'الفاتحة',
          fullText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          translation: 'ستایش مخصوص خداوندی است که پروردگار جهانیان است.',
          words: ['الْحَمْدُ', 'لِلَّهِ', 'رَبِّ', 'الْعَالَمِينَ'],
          distractors: ['الرَّحْمَٰنِ', 'مَالِكِ', 'يَوْمِ', 'الدِّينِ'],
        ),
        GameAyah(
          surahNumber: 1,
          ayahNumber: 3,
          surahName: 'الفاتحة',
          fullText: 'الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'بخشنده و مهربان است.',
          words: ['الرَّحْمَٰنِ', 'الرَّحِيمِ'],
          distractors: ['الْعَظِيمِ', 'الْكَرِيمِ', 'الْغَفُورِ', 'الْحَكِيمِ'],
        ),
      ],
    ),
  ];
}

/// Reactive game state snapshot
@immutable
class HoopoeGameState {
  final int score;
  final int combo;
  final int feathers; // Lives (0..3)
  final int stageIndex;
  final int ayahIndex;
  final int wordIndex;
  final bool isPlaying;
  final bool isPaused;
  final bool isVictory;
  final bool isGameOver;
  final String statusMessage;
  final Map<int, int> stageStars; // stageIndex -> stars (0..3)
  final int unlockedUpToStage;

  const HoopoeGameState({
    this.score = 0,
    this.combo = 0,
    this.feathers = 3,
    this.stageIndex = 0,
    this.ayahIndex = 0,
    this.wordIndex = 0,
    this.isPlaying = false,
    this.isPaused = false,
    this.isVictory = false,
    this.isGameOver = false,
    this.statusMessage = 'برای پرواز روی صفحه ضربه بزنید',
    this.stageStars = const {0: 3},
    this.unlockedUpToStage = 0,
  });

  HoopoeGameState copyWith({
    int? score,
    int? combo,
    int? feathers,
    int? stageIndex,
    int? ayahIndex,
    int? wordIndex,
    bool? isPlaying,
    bool? isPaused,
    bool? isVictory,
    bool? isGameOver,
    String? statusMessage,
    Map<int, int>? stageStars,
    int? unlockedUpToStage,
  }) {
    return HoopoeGameState(
      score: score ?? this.score,
      combo: combo ?? this.combo,
      feathers: feathers ?? this.feathers,
      stageIndex: stageIndex ?? this.stageIndex,
      ayahIndex: ayahIndex ?? this.ayahIndex,
      wordIndex: wordIndex ?? this.wordIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isVictory: isVictory ?? this.isVictory,
      isGameOver: isGameOver ?? this.isGameOver,
      statusMessage: statusMessage ?? this.statusMessage,
      stageStars: stageStars ?? this.stageStars,
      unlockedUpToStage: unlockedUpToStage ?? this.unlockedUpToStage,
    );
  }
}
