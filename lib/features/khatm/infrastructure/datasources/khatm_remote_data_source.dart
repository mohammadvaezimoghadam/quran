import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/remote/tafakor_api_client.dart';
import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_category.dart';
import '../../domain/entities/group_khatm_slot.dart';

final khatmRemoteDataSourceProvider = Provider<KhatmRemoteDataSource>((ref) {
  final dio = ref.watch(tafakorDioProvider);
  return KhatmRemoteDataSource(dio);
});

/// Remote data source communicating directly with Django Quran Plugin endpoints.
class KhatmRemoteDataSource {
  final Dio _dio;

  KhatmRemoteDataSource(this._dio);

  PaginatedCampaignsPage _parsePaginatedCampaigns(dynamic data) {
    final List listData;
    final int totalCount;
    final bool hasNext;

    if (data is Map && data.containsKey('results')) {
      listData = data['results'] as List? ?? [];
      final parsedItems = listData
          .map((e) => GroupKhatmCampaign.fromJson(e as Map<String, dynamic>))
          .toList();
      totalCount = data['count'] as int? ?? parsedItems.length;
      hasNext = data['next'] != null;
      return PaginatedCampaignsPage(
        items: parsedItems,
        totalCount: totalCount,
        hasNext: hasNext,
      );
    } else if (data is List) {
      final parsedItems = data
          .map((e) => GroupKhatmCampaign.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedCampaignsPage(
        items: parsedItems,
        totalCount: parsedItems.length,
        hasNext: false,
      );
    }

    return const PaginatedCampaignsPage(
      items: [],
      totalCount: 0,
      hasNext: false,
    );
  }

  /// 1. Public showcase list with optional filters & pagination metadata
  Future<PaginatedCampaignsPage> getCampaignsPage({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'category': ?categoryId,
      if (unitType != null && unitType.isNotEmpty) 'unit_type': unitType,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
    };

    final response = await _dio.get(
      'plugins/quran/campaigns/',
      queryParameters: queryParams,
    );

    return _parsePaginatedCampaigns(response.data);
  }

  Future<List<GroupKhatmCampaign>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  }) async {
    final pageResult = await getCampaignsPage(
      categoryId: categoryId,
      unitType: unitType,
      status: status,
      search: search,
      page: page,
    );
    return pageResult.items;
  }

  /// 2. User's personal campaign dashboard ('created' | 'participated' | 'all') with pagination
  Future<PaginatedCampaignsPage> getMyCampaignsPage({
    required String tab,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      'plugins/quran/campaigns/my/',
      queryParameters: {
        'tab': tab,
        'page': page,
        'page_size': pageSize,
      },
    );

    return _parsePaginatedCampaigns(response.data);
  }

  Future<List<GroupKhatmCampaign>> getMyCampaigns({
    required String tab, // 'created' | 'participated' | 'all'
    int page = 1,
  }) async {
    final pageResult = await getMyCampaignsPage(tab: tab, page: page);
    return pageResult.items;
  }

  /// 3. Retrieve single campaign with all slots
  Future<GroupKhatmCampaign> getCampaignDetail(String inviteCode) async {
    final response = await _dio.get('plugins/quran/campaigns/$inviteCode/');
    return GroupKhatmCampaign.fromJson(response.data as Map<String, dynamic>);
  }

  /// 4. Atomically claim/reserve a slot
  Future<GroupKhatmCampaign> reserveSlot(
    String inviteCode, {
    int? unitNumber,
    int quantity = 1,
  }) async {
    final payload = <String, dynamic>{
      'unit_number': ?unitNumber,
      'quantity': quantity,
    };

    final response = await _dio.post(
      'plugins/quran/campaigns/$inviteCode/reserve/',
      data: payload,
    );

    return _parseCampaignMutationResponse(response.data);
  }

  /// 5. Mark slot as read / completed
  Future<GroupKhatmCampaign> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    final payload = <String, dynamic>{
      'slot_id': ?slotId,
      'unit_number': ?unitNumber,
    };

    final response = await _dio.post(
      'plugins/quran/campaigns/$inviteCode/complete/',
      data: payload,
    );

    return _parseCampaignMutationResponse(response.data);
  }

  /// 6. Release a reserved slot back to the community
  Future<GroupKhatmCampaign> releaseSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    final payload = <String, dynamic>{
      'slot_id': ?slotId,
      'unit_number': ?unitNumber,
    };

    final response = await _dio.post(
      'plugins/quran/campaigns/$inviteCode/release/',
      data: payload,
    );

    return _parseCampaignMutationResponse(response.data);
  }

  /// Defensive parser for slot mutation endpoints (`reserve`, `complete`, `release`).
  /// Supports direct full campaign JSON, wrapped `{ "campaign": {...} }` / `{ "data": {...} }`,
  /// or lightweight `{ "slot": {...} }` responses without wiping the client's slot list.
  GroupKhatmCampaign _parseCampaignMutationResponse(dynamic rawData) {
    if (rawData is! Map) {
      return GroupKhatmCampaign.fromJson(const <String, dynamic>{});
    }
    final root = Map<String, dynamic>.from(rawData);
    Map<String, dynamic> campaignMap = root;
    if (root['campaign'] is Map) {
      campaignMap = Map<String, dynamic>.from(root['campaign'] as Map);
    } else if (root['data'] is Map &&
        (root['data'] as Map).containsKey('invite_code')) {
      campaignMap = Map<String, dynamic>.from(root['data'] as Map);
    }

    final campaign = GroupKhatmCampaign.fromJson(campaignMap);
    if (campaign.slots.isEmpty && root['slot'] is Map) {
      final slot = GroupKhatmSlot.fromJson(
        Map<String, dynamic>.from(root['slot'] as Map),
      );
      return GroupKhatmCampaign(
        id: campaign.id,
        inviteCode: campaign.inviteCode,
        category: campaign.category,
        creatorId: campaign.creatorId,
        creatorDisplayName: campaign.creatorDisplayName,
        title: campaign.title,
        description: campaign.description,
        unitType: campaign.unitType,
        unitTypeDisplay: campaign.unitTypeDisplay,
        targetUnits: campaign.targetUnits,
        targetSurahId: campaign.targetSurahId,
        targetSurahName: campaign.targetSurahName,
        reservedUnits: campaign.reservedUnits,
        completedUnits: campaign.completedUnits,
        remainingUnits: campaign.remainingUnits,
        progressPercentage: campaign.progressPercentage,
        isPublic: campaign.isPublic,
        status: campaign.status,
        statusDisplay: campaign.statusDisplay,
        deadline: campaign.deadline,
        createdAt: campaign.createdAt,
        isCreator: campaign.isCreator,
        slots: [slot],
        inviteUrl: campaign.inviteUrl,
        myActiveSlotsCount: campaign.myActiveSlotsCount,
      );
    }
    return campaign;
  }

  /// 7. Create a new collective Khatm Campaign
  Future<GroupKhatmCampaign> createCampaign(Map<String, dynamic> payload) async {
    final response = await _dio.post(
      'plugins/quran/campaigns/',
      data: payload,
    );

    return GroupKhatmCampaign.fromJson(response.data as Map<String, dynamic>);
  }

  /// 8. Get active intention/category chips
  Future<List<GroupKhatmCategory>> getCategories() async {
    final response = await _dio.get('plugins/quran/khatm-categories/');
    final List listData = response.data is List ? response.data as List : [];

    return listData
        .map((e) => GroupKhatmCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 9. Sync offline Hive personal Khatm plans with backend
  Future<Map<String, dynamic>> syncPersonalPlans({
    required List<Map<String, dynamic>> plans,
    String? lastSyncedAt,
  }) async {
    final payload = {
      'plans': plans,
      'last_synced_at': ?lastSyncedAt,
    };

    final response = await _dio.post(
      'plugins/quran/personal-khatms/sync/',
      data: payload,
    );

    return response.data as Map<String, dynamic>;
  }
}
