import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../entities/group_khatm_campaign.dart';
import '../entities/group_khatm_category.dart';
import '../entities/khatm_plan.dart';

abstract class IKhatmRepository {
  /// Public campaigns list with optional filtering
  Future<Result<List<GroupKhatmCampaign>, Failure>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  });

  /// User's own campaigns ('created', 'participated', or 'all')
  Future<Result<List<GroupKhatmCampaign>, Failure>> getMyCampaigns({
    required String tab,
  });

  /// Fetch full campaign details including all slots
  Future<Result<GroupKhatmCampaign, Failure>> getCampaignDetail(String inviteCode);

  /// Claim / reserve a slot (unitNumber for juz/hizb, quantity for surah)
  Future<Result<GroupKhatmCampaign, Failure>> reserveSlot(
    String inviteCode, {
    int? unitNumber,
    int quantity = 1,
  });

  /// Mark reserved slot as completed / read
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  });

  /// Release a slot back to the public pool
  Future<Result<GroupKhatmCampaign, Failure>> releaseSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  });

  /// Create a new collective Khatm Campaign
  Future<Result<GroupKhatmCampaign, Failure>> createCampaign({
    required String title,
    String? description,
    required String unitType,
    int? targetSurah,
    int? targetCount,
    int? categoryId,
    String? deadline,
    bool isPublic = true,
    int? topicId,
  });

  /// Fetch active categories/intentions
  Future<Result<List<GroupKhatmCategory>, Failure>> getCategories();

  /// Sync offline Hive personal Khatm plans with backend
  Future<Result<Map<String, dynamic>, Failure>> syncPersonalPlans({
    required List<Map<String, dynamic>> plans,
    String? lastSyncedAt,
  });

  /// Local Personal Khatm operations
  Future<List<KhatmPlan>> getLocalPlans();
  Future<void> saveLocalPlan(KhatmPlan plan);
  Future<void> deleteLocalPlan(String planId);
}
