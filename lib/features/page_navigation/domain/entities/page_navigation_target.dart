/// Model that holds the result of page processing.
/// This tells the router which Surah and Ayah to navigate to.
class PageNavigationTarget {
  final int surahId;
  final String surahName;
  final int ayahNumber; // The first Ayah located on this page

  PageNavigationTarget({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
  });
}
