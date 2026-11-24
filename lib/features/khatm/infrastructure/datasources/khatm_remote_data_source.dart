import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/remote/tafakor_api_client.dart';
import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_category.dart';

final khatmRemoteDataSourceProvider = Provider<KhatmRemoteDataSource>((ref) {
  final dio = ref.watch(tafakorDioProvider);
  return KhatmRemoteDataSource(dio);
});

/// Remote data source communicating directly with Django Quran Plugin endpoints.
class KhatmRemoteDataSource {
  final Dio _dio;

  KhatmRemoteDataSource(this._dio);

  /// 1. Public showcase list with optional filters
  Future<List<GroupKhatmCampaign>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'category': ?categoryId,
      if (unitType != null && unitType.isNotEmpty) 'unit_type': unitType,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
    };

    final response = await _dio.get(
      'plugins/quran/campaigns/',
      queryParameters: queryParams,
    );

    final data = response.data;
    final List listData;
    if (data is Map && data.containsKey('results')) {
      listData = data['results'] as List;
    } else if (data is List) {
      listData = data;
    } else {
      listData = [];
    }

    return listData
        .map((e) => GroupKhatmCampaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 2. User's personal campaign dashboard ('created' or 'participated')
  Future<List<GroupKhatmCampaign>> getMyCampaigns({
    required String tab, // 'created' | 'participated' | 'all'
  }) async {
    final response = await _dio.get(
      'plugins/quran/campaigns/my/',
      queryParameters: {'tab': tab},
    );

    final data = response.data;
    final List listData = (data is List) ? data : (data['results'] as List? ?? []);

    return listData
        .map((e) => GroupKhatmCampaign.fromJson(e as Map<String, dynamic>))
        .toList();
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

    return GroupKhatmCampaign.fromJson(response.data as Map<String, dynamic>);
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

    return GroupKhatmCampaign.fromJson(response.data as Map<String, dynamic>);
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

    return GroupKhatmCampaign.fromJson(response.data as Map<String, dynamic>);
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
