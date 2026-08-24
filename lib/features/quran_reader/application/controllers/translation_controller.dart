import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../translation_service.dart';

import '../states/quran_display_settings_state.dart';
import 'quran_display_settings_controller.dart';

const Map<String, String> translatorNameToIdMap = {
  'شیخ حسین انصاریان': 'fa.ansarian',
  'آیت‌الله مکارم شیرازی': 'fa.makarem',
  'استاد فولادوند': 'fa.fooladvand',
  'دکتر الهی قمشه‌ای': 'fa.ghomshei',
  'استاد بهاءالدین خرمشاهی': 'fa.khorramshahi',
  'استاد عبدالمحمد آیتی': 'fa.ayati',
  'استاد محسن قرائتی': 'fa.gharaati',
  'استاد مصطفی خرم‌دل': 'fa.khorramdel',
  'سید جلال‌الدین مجتبوی': 'fa.mojtabavi',
  'محمدکاظم معزی': 'fa.moezzi',
  'استاد ابوالفضل بهرام‌پور': 'fa.bahrampour',
  'دکتر محمد صادقی تهرانی': 'fa.sadeqi',
  'ترجمه بر اساس المیزان (صفوی)': 'fa.safavi',
  'دکتر حسین تاجی کالداری': 'fa.tajikaldari',
  'گروه مترجمان اسلام‌هاوس': 'fa.islamhouse',
  'فارسی فولادوند (خوانش هدایت‌فر)': 'fa.hedayatfar',
  'عربی التفسیر المیسر': 'ar.muyassar',
  'آذربایجانی ممدعلی‌اف': 'az.mammadaliyev',
  'آلمانی بوبنهایم (Bubenheim & Elyas)': 'de.bubenheim',
  'انگلیسی ایروینگ': 'en.irving',
  'انگلیسی شاکر': 'en.shakir',
  'انگلیسی صحیح اینترنشنال': 'en.sahih',
  'انگلیسی پیکتال': 'en.pickthall',
  'انگلیسی یوسف علی': 'en.yusufali',
  'اسپانیایی کورتز': 'es.cortes',
  'فرانسه حمید‌الله': 'fr.hamidullah',
  'ایتالیایی پیکاردو': 'it.piccardo',
  'کردی آسان (برهان امین)': 'ku.asan',
  'هلندی سیرگار': 'nl.siregar',
  'پشتو عبدالوالی خان': 'ps.abdulwali',
  'روسی کولینف': 'ru.kuliev',
  'آلبانیایی احمدی': 'sq.ahmeti',
  'ترکی سازمان دیانت': 'tr.diyanet',
  'اردو جالندھری': 'ur.jalandhry',
};

final selectedTranslationIdProvider = Provider.autoDispose<String>((ref) {
  final translatorName = ref.watch(
    quranDisplaySettingsControllerProvider
        .select((QuranDisplaySettingsState s) => s.translatorName),
  );
  return translatorNameToIdMap[translatorName] ?? 'fa.ansarian';
});

final surahTranslationsProvider =
    FutureProvider.autoDispose.family<Map<int, String>, int>((ref, surahId) async {
  final translationId = ref.watch(selectedTranslationIdProvider);
  final service = ref.watch(translationServiceProvider);

  final result = await service.getTranslationsBySurah(surahId, translationId);
  return result.when(
    (entities) => {
      for (final entity in entities) entity.ayahNumber: entity.text,
    },
    (failure) => <int, String>{},
  );
});
