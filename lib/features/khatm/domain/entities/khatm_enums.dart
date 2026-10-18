/// Unit type for a Khatm (صفحه، حزب، جزء، سوره، آیه).
enum KhatmUnitType {
  page,
  hizb,
  juz,
  surah,
  ayah;

  String get labelFa {
    switch (this) {
      case KhatmUnitType.page:
        return 'صفحه';
      case KhatmUnitType.hizb:
        return 'حزب';
      case KhatmUnitType.juz:
        return 'جزء';
      case KhatmUnitType.surah:
        return 'سوره';
      case KhatmUnitType.ayah:
        return 'آیه';
    }
  }

  /// Maximum units for the entire Holy Quran
  int get maxUnits {
    switch (this) {
      case KhatmUnitType.page:
        return 604;
      case KhatmUnitType.hizb:
        return 120; // 120 Ahzab (Iranian / Hablolmatin convention)
      case KhatmUnitType.juz:
        return 30;
      case KhatmUnitType.surah:
        return 114;
      case KhatmUnitType.ayah:
        return 6236;
    }
  }
}

/// Planning mode: whether based on total sessions or quota per session.
enum KhatmPlanningMode {
  bySessionCount, // براساس جلسه
  byUnitQuota; // براساس [واحد]

  String get labelFa {
    switch (this) {
      case KhatmPlanningMode.bySessionCount:
        return 'براساس جلسه';
      case KhatmPlanningMode.byUnitQuota:
        return 'براساس سهمیه';
    }
  }
}

/// Scheduling cadence / frequency for Khatm sessions.
enum KhatmCadence {
  daily, // روزانه
  everyOtherDay, // یک‌روزدرمیان
  weekly, // هفتگی
  customWeekdays; // روزهای خاص

  String get labelFa {
    switch (this) {
      case KhatmCadence.daily:
        return 'روزانه';
      case KhatmCadence.everyOtherDay:
        return 'یک‌روزدرمیان';
      case KhatmCadence.weekly:
        return 'هفتگی';
      case KhatmCadence.customWeekdays:
        return 'روزهای خاص';
    }
  }
}

/// Status of an individual session in the Khatm plan.
enum KhatmSessionStatus {
  pending, // در انتظار (جلسات آینده)
  current, // امروز (جلسه امروز که هنوز خوانده نشده)
  completed, // تکمیل شده
  missed; // عقب‌افتاده / قضا شده (تاریخ قبل از امروز و تکمیل نشده)

  String get labelFa {
    switch (this) {
      case KhatmSessionStatus.pending:
        return 'در انتظار';
      case KhatmSessionStatus.current:
        return 'امروز';
      case KhatmSessionStatus.completed:
        return 'تکمیل شده';
      case KhatmSessionStatus.missed:
        return 'عقب‌افتاده';
    }
  }
}
