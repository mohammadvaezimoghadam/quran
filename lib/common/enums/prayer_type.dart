/// Enum representing Islamic Prayer & Astronomical timings
enum PrayerType {
  fajr('صبح'),
  sunrise('طلوع'),
  dhuhr('ظهر'),
  asr('عصر'),
  sunset('غروب'),
  maghrib('مغرب'),
  isha('عشاء'),
  midnight('نیمه‌شب');

  final String titleFa;
  const PrayerType(this.titleFa);
}
