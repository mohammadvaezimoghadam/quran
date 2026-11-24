import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_category.dart';
import '../../domain/entities/group_khatm_slot.dart';
import '../../domain/entities/khatm_enums.dart';
import '../../domain/entities/khatm_plan.dart';
import '../../domain/entities/khatm_session_item.dart';

/// In-memory mock and test data store for Group Khatm campaigns.
/// Allows full visual review, interactive testing (claiming, releasing, completing slots,
/// opening reader, and testing wizard) without requiring a live backend.
class KhatmTestData {
  static final List<GroupKhatmCategory> defaultCategories = [
    const GroupKhatmCategory(id: 1, title: 'سلامتی و فرج امام زمان (عج)', slug: 'faraj', icon: ''),
    const GroupKhatmCategory(id: 2, title: 'اموات و درگذشتگان', slug: 'amvat', icon: ''),
    const GroupKhatmCategory(id: 3, title: 'حاجات و شفای بیماران', slug: 'hajat', icon: ''),
    const GroupKhatmCategory(id: 4, title: 'هدیه به اهل‌بیت (ع)', slug: 'ahlulbayt', icon: ''),
  ];

  static KhatmPlan get samplePersonalPlan {
    final now = DateTime.now();
    final sessions = <KhatmSessionItem>[];
    for (int i = 0; i < 120; i++) {
      sessions.add(KhatmSessionItem(
        sessionIndex: i,
        fromUnit: i + 1,
        toUnit: i + 1,
        scheduledDate: now.add(Duration(days: i - 30)),
        isCompleted: i < 30,
        completedAt: i < 30 ? now.subtract(Duration(days: 30 - i)) : null,
        progress: i < 30 ? 1.0 : (i == 30 ? 0.4 : 0.0),
      ));
    }
    return KhatmPlan(
      id: 'test-personal-khatm',
      title: 'ختم روزانه حزب قرآن کریم',
      unitType: KhatmUnitType.hizb,
      rangeFrom: 1,
      rangeTo: 120,
      planningMode: KhatmPlanningMode.bySessionCount,
      sessionCount: 120,
      quotaPerSession: 1,
      cadence: KhatmCadence.daily,
      startDateTime: now.subtract(const Duration(days: 30)),
      endDateTime: now.add(const Duration(days: 90)),
      sessions: sessions,
      createdAt: now.subtract(const Duration(days: 30)),
    );
  }

  static final Map<String, GroupKhatmCampaign> _campaigns = {};

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    final initialCampaign = _createInitialJuzCampaign();
    _campaigns[initialCampaign.inviteCode] = initialCampaign;
  }

  static GroupKhatmCampaign _createInitialJuzCampaign() {
    const totalUnits = 30;
    const completedCount = 12;
    const reservedCount = 8;
    const remainingCount = 10;
    const progress = (completedCount / totalUnits) * 100;

    final slots = <GroupKhatmSlot>[];
    final now = DateTime.now();

    for (int i = 1; i <= totalUnits; i++) {
      if (i <= 6) {
        slots.add(GroupKhatmSlot(
          id: i,
          campaignId: 9999,
          unitNumber: i,
          status: GroupKhatmSlotStatus.completed,
          userId: 100 + i,
          userDisplayName: 'کاربر قرآنی $i',
          isMine: false,
          completedAt: now.subtract(Duration(hours: 12 - i)),
        ));
      } else if (i == 7) {
        // Slot 7 is assigned to current user as active reservation
        slots.add(GroupKhatmSlot(
          id: 7,
          campaignId: 9999,
          unitNumber: 7,
          status: GroupKhatmSlotStatus.reserved,
          userId: 999,
          userDisplayName: 'شما',
          isMine: true,
          reservedAt: now.subtract(const Duration(hours: 2)),
          expiresAt: now.add(const Duration(hours: 22)),
        ));
      } else if (i <= 12) {
        slots.add(GroupKhatmSlot(
          id: i,
          campaignId: 9999,
          unitNumber: i,
          status: GroupKhatmSlotStatus.completed,
          userId: 100 + i,
          userDisplayName: 'کاربر قرآنی $i',
          isMine: false,
          completedAt: now.subtract(Duration(hours: 20 - i)),
        ));
      } else if (i <= 19) {
        slots.add(GroupKhatmSlot(
          id: i,
          campaignId: 9999,
          unitNumber: i,
          status: GroupKhatmSlotStatus.reserved,
          userId: 200 + i,
          userDisplayName: 'همراه قرآنی',
          isMine: false,
          reservedAt: now.subtract(Duration(minutes: 30 * i)),
          expiresAt: now.add(Duration(hours: 18 + (i % 6))),
        ));
      } else {
        slots.add(GroupKhatmSlot(
          id: i,
          campaignId: 9999,
          unitNumber: i,
          status: GroupKhatmSlotStatus.available,
          isMine: false,
        ));
      }
    }

    return GroupKhatmCampaign(
      id: 9999,
      inviteCode: 'test-khatm',
      category: defaultCategories.first,
      creatorDisplayName: 'خادم قرآن',
      title: 'ختم قرآن هدیه به امام رضا (ع)',
      description: 'به نیت سلامتی و تعجیل در فرج امام زمان (عج) و شفای همه بیماران',
      unitType: 'juz',
      unitTypeDisplay: '۳۰ جزء',
      targetUnits: totalUnits,
      reservedUnits: reservedCount,
      completedUnits: completedCount,
      remainingUnits: remainingCount,
      progressPercentage: progress,
      isPublic: true,
      status: GroupKhatmStatus.active,
      statusDisplay: 'در حال برگزاری',
      deadline: now.add(const Duration(hours: 36)),
      createdAt: now.subtract(const Duration(days: 1)),
      isCreator: false,
      slots: slots,
      inviteUrl: 'https://quran.app/khatm/test-khatm',
      myActiveSlotsCount: 1,
    );
  }

  /// Get campaign by invite code (or return default test campaign)
  static GroupKhatmCampaign getCampaign(String code) {
    _ensureInitialized();
    if (_campaigns.containsKey(code)) {
      return _campaigns[code]!;
    }
    return _campaigns['test-khatm']!;
  }

  /// List of all test campaigns for public vitrine
  static List<GroupKhatmCampaign> getAllCampaigns() {
    _ensureInitialized();
    return _campaigns.values.toList();
  }

  /// Interactive slot reservation in memory
  static GroupKhatmCampaign reserveSlot(
    String code, {
    int? unitNumber,
    int quantity = 1,
  }) {
    _ensureInitialized();
    final c = getCampaign(code);
    final targetUnit = unitNumber ?? c.slots.firstWhere((s) => s.isFree, orElse: () => c.slots.first).unitNumber;
    if (targetUnit == null) return c;

    final updatedSlots = c.slots.map((s) {
      if (s.unitNumber == targetUnit) {
        return GroupKhatmSlot(
          id: s.id,
          campaignId: s.campaignId,
          unitNumber: s.unitNumber,
          quantity: s.quantity,
          status: GroupKhatmSlotStatus.reserved,
          userId: 999,
          userDisplayName: 'شما',
          isMine: true,
          reservedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
      }
      return s;
    }).toList();

    final reservedCount = updatedSlots.where((s) => s.isReserved).length;
    final completedCount = updatedSlots.where((s) => s.isCompleted).length;
    final remainingCount = (c.targetUnits - completedCount - reservedCount).clamp(0, c.targetUnits);
    final myCount = updatedSlots.where((s) => s.isMine && s.isReserved).length;

    final updatedCampaign = GroupKhatmCampaign(
      id: c.id,
      inviteCode: c.inviteCode,
      category: c.category,
      creatorDisplayName: c.creatorDisplayName,
      title: c.title,
      description: c.description,
      unitType: c.unitType,
      unitTypeDisplay: c.unitTypeDisplay,
      targetUnits: c.targetUnits,
      targetSurahId: c.targetSurahId,
      targetSurahName: c.targetSurahName,
      reservedUnits: reservedCount,
      completedUnits: completedCount,
      remainingUnits: remainingCount,
      progressPercentage: (completedCount / c.targetUnits) * 100,
      isPublic: c.isPublic,
      status: c.status,
      statusDisplay: c.statusDisplay,
      deadline: c.deadline,
      createdAt: c.createdAt,
      isCreator: c.isCreator,
      slots: updatedSlots,
      inviteUrl: c.inviteUrl,
      myActiveSlotsCount: myCount,
    );

    _campaigns[code] = updatedCampaign;
    return updatedCampaign;
  }

  /// Interactive slot release in memory
  static GroupKhatmCampaign releaseSlot(
    String code, {
    int? slotId,
    int? unitNumber,
  }) {
    _ensureInitialized();
    final c = getCampaign(code);

    final updatedSlots = c.slots.map((s) {
      final matches = (slotId != null && s.id == slotId) ||
          (unitNumber != null && s.unitNumber == unitNumber) ||
          (slotId == null && unitNumber == null && s.isMine);
      if (matches) {
        return GroupKhatmSlot(
          id: s.id,
          campaignId: s.campaignId,
          unitNumber: s.unitNumber,
          quantity: s.quantity,
          status: GroupKhatmSlotStatus.available,
          isMine: false,
        );
      }
      return s;
    }).toList();

    final reservedCount = updatedSlots.where((s) => s.isReserved).length;
    final completedCount = updatedSlots.where((s) => s.isCompleted).length;
    final remainingCount = (c.targetUnits - completedCount - reservedCount).clamp(0, c.targetUnits);
    final myCount = updatedSlots.where((s) => s.isMine && s.isReserved).length;

    final updatedCampaign = GroupKhatmCampaign(
      id: c.id,
      inviteCode: c.inviteCode,
      category: c.category,
      creatorDisplayName: c.creatorDisplayName,
      title: c.title,
      description: c.description,
      unitType: c.unitType,
      unitTypeDisplay: c.unitTypeDisplay,
      targetUnits: c.targetUnits,
      targetSurahId: c.targetSurahId,
      targetSurahName: c.targetSurahName,
      reservedUnits: reservedCount,
      completedUnits: completedCount,
      remainingUnits: remainingCount,
      progressPercentage: (completedCount / c.targetUnits) * 100,
      isPublic: c.isPublic,
      status: c.status,
      statusDisplay: c.statusDisplay,
      deadline: c.deadline,
      createdAt: c.createdAt,
      isCreator: c.isCreator,
      slots: updatedSlots,
      inviteUrl: c.inviteUrl,
      myActiveSlotsCount: myCount,
    );

    _campaigns[code] = updatedCampaign;
    return updatedCampaign;
  }

  /// Interactive slot completion in memory
  static GroupKhatmCampaign completeSlot(
    String code, {
    int? slotId,
    int? unitNumber,
  }) {
    _ensureInitialized();
    final c = getCampaign(code);

    final updatedSlots = c.slots.map((s) {
      final matches = (slotId != null && s.id == slotId) ||
          (unitNumber != null && s.unitNumber == unitNumber) ||
          (slotId == null && unitNumber == null && s.isMine);
      if (matches) {
        return GroupKhatmSlot(
          id: s.id,
          campaignId: s.campaignId,
          unitNumber: s.unitNumber,
          quantity: s.quantity,
          status: GroupKhatmSlotStatus.completed,
          userId: s.userId ?? 999,
          userDisplayName: s.userDisplayName ?? 'شما',
          isMine: true,
          completedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    final reservedCount = updatedSlots.where((s) => s.isReserved).length;
    final completedCount = updatedSlots.where((s) => s.isCompleted).length;
    final remainingCount = (c.targetUnits - completedCount - reservedCount).clamp(0, c.targetUnits);
    final myCount = updatedSlots.where((s) => s.isMine && s.isReserved).length;
    final progress = (completedCount / c.targetUnits) * 100;
    final isDone = progress >= 100.0;

    final updatedCampaign = GroupKhatmCampaign(
      id: c.id,
      inviteCode: c.inviteCode,
      category: c.category,
      creatorDisplayName: c.creatorDisplayName,
      title: c.title,
      description: c.description,
      unitType: c.unitType,
      unitTypeDisplay: c.unitTypeDisplay,
      targetUnits: c.targetUnits,
      targetSurahId: c.targetSurahId,
      targetSurahName: c.targetSurahName,
      reservedUnits: reservedCount,
      completedUnits: completedCount,
      remainingUnits: remainingCount,
      progressPercentage: progress,
      isPublic: c.isPublic,
      status: isDone ? GroupKhatmStatus.completed : c.status,
      statusDisplay: isDone ? 'تکمیل شده' : c.statusDisplay,
      deadline: c.deadline,
      createdAt: c.createdAt,
      isCreator: c.isCreator,
      slots: updatedSlots,
      inviteUrl: c.inviteUrl,
      myActiveSlotsCount: myCount,
    );

    _campaigns[code] = updatedCampaign;
    return updatedCampaign;
  }

  /// Create a new campaign locally for testing wizard end-to-end
  static GroupKhatmCampaign createCampaign({
    required String title,
    String? description,
    required String unitType,
    int? targetSurah,
    int? targetCount,
    int? categoryId,
    String? deadline,
    bool isPublic = true,
  }) {
    _ensureInitialized();
    final code = 'test-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final totalUnits = unitType == 'surah'
        ? (targetCount ?? 100)
        : (unitType == 'hizb' ? 120 : 30);

    final slots = <GroupKhatmSlot>[];
    for (int i = 1; i <= (unitType == 'surah' ? 0 : totalUnits); i++) {
      slots.add(GroupKhatmSlot(
        id: i,
        campaignId: 8888,
        unitNumber: i,
        status: GroupKhatmSlotStatus.available,
        isMine: false,
      ));
    }

    final category = defaultCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => defaultCategories.first,
    );

    final campaign = GroupKhatmCampaign(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      inviteCode: code,
      category: category,
      creatorDisplayName: 'شما',
      title: title,
      description: description,
      unitType: unitType,
      unitTypeDisplay: unitType == 'surah'
          ? 'سوره انتخابی'
          : (unitType == 'hizb' ? '۱۲۰ حزب' : '۳۰ جزء'),
      targetUnits: totalUnits,
      targetSurahId: targetSurah,
      reservedUnits: 0,
      completedUnits: 0,
      remainingUnits: totalUnits,
      progressPercentage: 0.0,
      isPublic: isPublic,
      status: GroupKhatmStatus.active,
      statusDisplay: 'در حال برگزاری',
      deadline: deadline != null ? DateTime.tryParse(deadline) : null,
      createdAt: DateTime.now(),
      isCreator: true,
      slots: slots,
      inviteUrl: 'https://quran.app/khatm/$code',
      myActiveSlotsCount: 0,
    );

    _campaigns[code] = campaign;
    return campaign;
  }
}
