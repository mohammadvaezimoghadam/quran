enum SurahSortBy {
  number('شماره سوره'),
  name('نام سوره'),
  revelationOrder('ترتیب نزول'),
  juz('شماره جزء'),
  ayahCount('تعداد آیات');

  final String label;
  const SurahSortBy(this.label);
}

enum SortOrder {
  ascending('صعودی'),
  descending('نزولی');

  final String label;
  const SortOrder(this.label);
}
