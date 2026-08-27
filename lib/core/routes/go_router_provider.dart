import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/quran_home/presentation/ui/quran_home_screen.dart';
import '../../features/quran_reader/presentation/ui/quran_reader_screen.dart';
import '../../features/splash/presentation/ui/splash_screen.dart';
import '../../features/surah_list/presentation/ui/surah_list_screen.dart';
import 'route_name.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/quran-home',
        name: quranHomeRoute,
        builder: (context, state) => const QuranHomeScreen(),
      ),
      GoRoute(
        path: '/surah-list',
        name: surahListRoute,
        builder: (context, state) => const SurahListScreen(),
      ),
      GoRoute(
        path: '/quran-reader/:id',
        name: quranReaderRoute,
        builder: (context, state) {
          final surahId = int.parse(state.pathParameters['id']!);
          final surahName = state.uri.queryParameters['name'] ?? 'سوره';
          final ayahString = state.uri.queryParameters['ayah'];
          final translationId = state.uri.queryParameters['translationId'];
          final initialAyah = ayahString != null ? int.tryParse(ayahString) : null;
          return QuranReaderScreen(
            surahId: surahId,
            surahName: surahName,
            initialAyahNumber: initialAyah,
            translationId: translationId,
          );
        },
      ),
    ],
  );
});
