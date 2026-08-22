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
};

final selectedTranslationIdProvider = Provider<String>((ref) {
  final translatorName = ref.watch(
    quranDisplaySettingsControllerProvider
        .select((QuranDisplaySettingsState s) => s.translatorName),
  );
  return translatorNameToIdMap[translatorName] ?? 'fa.ansarian';
});

final surahTranslationsProvider =
    FutureProvider.family<Map<int, String>, int>((ref, surahId) async {
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
