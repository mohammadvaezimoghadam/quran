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

/// Status of a collective Group Khatm Campaign.
enum GroupKhatmStatus {
  active,
  completed,
  expired,
  cancelled;

  String get labelFa {
    switch (this) {
      case GroupKhatmStatus.active:
        return 'در حال برگزاری';
      case GroupKhatmStatus.completed:
        return 'تکمیل شده';
      case GroupKhatmStatus.expired:
        return 'پایان مهلت';
      case GroupKhatmStatus.cancelled:
        return 'متوقف شده';
    }
  }

  static GroupKhatmStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'completed':
        return GroupKhatmStatus.completed;
      case 'expired':
        return GroupKhatmStatus.expired;
      case 'cancelled':
        return GroupKhatmStatus.cancelled;
      case 'active':
      default:
        return GroupKhatmStatus.active;
    }
  }
}

/// Status of an individual slot in a Group Khatm Campaign.
enum GroupKhatmSlotStatus {
  available,
  reserved,
  completed;

  String get labelFa {
    switch (this) {
      case GroupKhatmSlotStatus.available:
        return 'آزاد';
      case GroupKhatmSlotStatus.reserved:
        return 'در حال قرائت';
      case GroupKhatmSlotStatus.completed:
        return 'تکمیل شده';
    }
  }

  static GroupKhatmSlotStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'reserved':
        return GroupKhatmSlotStatus.reserved;
      case 'completed':
        return GroupKhatmSlotStatus.completed;
      case 'available':
      default:
        return GroupKhatmSlotStatus.available;
    }
  }
}

/// Unit division for Group Khatm (30 Juz, 120 Ahzab, or specific Surah).
enum GroupKhatmUnitType {
  juz,
  hizb,
  surah;

  String get labelFa {
    switch (this) {
      case GroupKhatmUnitType.juz:
        return '۳۰ جزء';
      case GroupKhatmUnitType.hizb:
        return '۱۲۰ حزب';
      case GroupKhatmUnitType.surah:
        return 'سوره مشخص';
    }
  }

  String get shortLabelFa {
    switch (this) {
      case GroupKhatmUnitType.juz:
        return 'جزء';
      case GroupKhatmUnitType.hizb:
        return 'حزب';
      case GroupKhatmUnitType.surah:
        return 'سوره';
    }
  }

  String get serverValue {
    switch (this) {
      case GroupKhatmUnitType.juz:
        return 'juz';
      case GroupKhatmUnitType.hizb:
        return 'hizb';
      case GroupKhatmUnitType.surah:
        return 'surah';
    }
  }

  static GroupKhatmUnitType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'hizb':
        return GroupKhatmUnitType.hizb;
      case 'surah':
        return GroupKhatmUnitType.surah;
      case 'juz':
      default:
        return GroupKhatmUnitType.juz;
    }
  }
}

