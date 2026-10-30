import '../../../../common/extensions/surah_name_extension.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_quran_reference.dart';

/// In-memory cache and registry mapping Tafakor posts to their Quran Ayah references.
/// Strictly populated from the backend server API responses (Single Source of Truth).
/// No client-side text parsing or heuristics.
abstract final class TafakorQuranRegistry {
  static final Map<int, List<TafakorQuranReference>> _cache = {};

  /// Manually register known references for a post ID.
  static void register(int postId, List<TafakorQuranReference> refs) {
    if (refs.isEmpty) {
      _cache.remove(postId);
      return;
    }
    _cache[postId] = refs;
  }

  /// Register references directly from a raw backend post JSON response (from DRF PostSerializer).
  /// Strictly parses the server's `plugin_references` array.
  static void registerFromRaw(Map<String, dynamic> rawPost) {
    final postId = rawPost['id'];
    if (postId is! int) return;

    final rawRefs = rawPost['plugin_references'];
    if (rawRefs is List && rawRefs.isNotEmpty) {
      final refs = <TafakorQuranReference>[];
      for (final refItem in rawRefs) {
        if (refItem is! Map) continue;
        final plugin = refItem['plugin_identifier'] ?? refItem['plugin'];
        if (plugin != 'quran') continue;

        // Extract metadata provided by the server
        final metadata = refItem['metadata'];
        int? surahNum;
        int? ayahNum;
        String? surahName;

        if (metadata is Map) {
          surahNum = int.tryParse(metadata['surah_number']?.toString() ?? '');
          ayahNum = int.tryParse(metadata['ayah_number']?.toString() ?? '');
          surahName = metadata['surah_name']?.toString();
        }

        // Fallback: parse canonical external_id provided by the server (e.g. "surah:1,ayah:6")
        if (surahNum == null || ayahNum == null) {
          final extId = refItem['external_id']?.toString() ?? '';
          final match = RegExp(r'surah:(\d+),ayah:(\d+)').firstMatch(extId);
          if (match != null) {
            surahNum = int.tryParse(match.group(1)!);
            ayahNum = int.tryParse(match.group(2)!);
          }
        }

        if (surahNum != null && ayahNum != null && surahNum >= 1 && surahNum <= 114) {
          surahName ??= surahNum.surahNameFa;
          final ref = TafakorQuranReference(
            surahNumber: surahNum,
            ayahNumber: ayahNum,
            surahName: surahName,
          );
          if (!refs.contains(ref)) {
            refs.add(ref);
          }
        }
      }

      if (refs.isNotEmpty) {
        _cache[postId] = refs;
        return;
      }
    }

    // If server sent empty references, ensure cache reflects empty
    _cache[postId] = const [];
  }

  /// Retrieves the list of Quran Ayah references for a post as returned by the server.
  /// If the server has no plugin_references for this post, returns an empty list.
  static List<TafakorQuranReference> getReferences(TafakorPost post) {
    return _cache[post.id] ?? const [];
  }

  /// Clears cache.
  static void clear() {
    _cache.clear();
  }
}
