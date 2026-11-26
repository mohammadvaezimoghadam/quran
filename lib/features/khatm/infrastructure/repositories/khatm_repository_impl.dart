import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../../../common/mixins/dio_exception_mapper.dart';
import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_category.dart';
import '../../domain/entities/khatm_plan.dart';
import '../../domain/repositories/i_khatm_repository.dart';
import '../datasources/khatm_local_datasource.dart';
import '../datasources/khatm_mock_data.dart';
import '../datasources/khatm_remote_data_source.dart';

final khatmRepositoryProvider = Provider<IKhatmRepository>((ref) {
  final remoteDataSource = ref.watch(khatmRemoteDataSourceProvider);
  final localDataSource = ref.watch(khatmLocalDataSourceProvider);
  return KhatmRepositoryImpl(remoteDataSource, localDataSource);
});

class KhatmRepositoryImpl with DioExceptionMapper implements IKhatmRepository {
  final KhatmRemoteDataSource _remoteDataSource;
  final IKhatmLocalDataSource _localDataSource;

  KhatmRepositoryImpl(this._remoteDataSource, this._localDataSource);

  Failure _handleDioError(DioException e, StackTrace stackTrace) {
    debugPrint(
      '⚠️ [KhatmRepository] DioException: ${e.message}, status: ${e.response?.statusCode}, data: ${e.response?.data}',
    );

    // Extract server-provided Persian message if present
    final data = e.response?.data;
    if (data is Map) {
      final serverCode = data['code']?.toString();
      if (data['detail'] is String && (data['detail'] as String).isNotEmpty) {
        return Failure(
          message: data['detail'] as String,
          statusCode: e.response?.statusCode,
          code: serverCode,
          exception: e,
          stackTrace: stackTrace,
        );
      }
      if (data['error'] is String && (data['error'] as String).isNotEmpty) {
        return Failure(
          message: data['error'] as String,
          statusCode: e.response?.statusCode,
          code: serverCode,
          exception: e,
          stackTrace: stackTrace,
        );
      }
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        return Failure(
          message: data['message'] as String,
          statusCode: e.response?.statusCode,
          code: serverCode,
          exception: e,
          stackTrace: stackTrace,
        );
      }
    }

    // Specific fallback for 409 Conflict (e.g. concurrent slot reservation)
    if (e.response?.statusCode == 409) {
      return Failure(
        message:
            'این سهم همین لحظه توسط کاربر دیگری برداشته شد؛ لطفاً سهم آزاد دیگری انتخاب کنید',
        statusCode: 409,
        exception: e,
        stackTrace: stackTrace,
      );
    }

    return mapDioExceptionToFailure(e, stackTrace);
  }

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getCampaignsPage({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getCampaignsPage(
        categoryId: categoryId,
        unitType: unitType,
        status: status,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      return Success(result);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت لیست ختم‌های گروهی: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getCampaigns({
    int? categoryId,
    String? unitType,
    String? status,
    String? search,
    int page = 1,
  }) async {
    final res = await getCampaignsPage(
      categoryId: categoryId,
      unitType: unitType,
      status: status,
      search: search,
      page: page,
    );
    return res.when(
      (pageData) => Success(pageData.items),
      (failure) => Error(failure),
    );
  }

  @override
  Future<Result<PaginatedCampaignsPage, Failure>> getMyCampaignsPage({
    required String tab,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getMyCampaignsPage(
        tab: tab,
        page: page,
        pageSize: pageSize,
      );
      return Success(result);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت ختم‌های من: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<GroupKhatmCampaign>, Failure>> getMyCampaigns({
    required String tab,
  }) async {
    final res = await getMyCampaignsPage(tab: tab);
    return res.when(
      (pageData) => Success(pageData.items),
      (failure) => Error(failure),
    );
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> getCampaignDetail(
    String inviteCode,
  ) async {
    if (inviteCode == 'test-khatm' || inviteCode.startsWith('test-')) {
      return Success(KhatmTestData.getCampaign(inviteCode));
    }
    try {
      final campaign = await _remoteDataSource.getCampaignDetail(inviteCode);
      return Success(campaign);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت اطلاعات ختم: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> reserveSlot(
    String inviteCode, {
    int? unitNumber,
    int quantity = 1,
  }) async {
    if (inviteCode == 'test-khatm' || inviteCode.startsWith('test-')) {
      return Success(
        KhatmTestData.reserveSlot(
          inviteCode,
          unitNumber: unitNumber,
          quantity: quantity,
        ),
      );
    }
    try {
      final campaign = await _remoteDataSource.reserveSlot(
        inviteCode,
        unitNumber: unitNumber,
        quantity: quantity,
      );
      return Success(campaign);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(message: 'خطا در رزرو سهم: $e', stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> completeSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    if (inviteCode == 'test-khatm' || inviteCode.startsWith('test-')) {
      return Success(
        KhatmTestData.completeSlot(
          inviteCode,
          slotId: slotId,
          unitNumber: unitNumber,
        ),
      );
    }
    try {
      final campaign = await _remoteDataSource.completeSlot(
        inviteCode,
        slotId: slotId,
        unitNumber: unitNumber,
      );
      return Success(campaign);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(message: 'خطا در ثبت اتمام سهم: $e', stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Result<GroupKhatmCampaign, Failure>> releaseSlot(
    String inviteCode, {
    int? slotId,
    int? unitNumber,
  }) async {
    if (inviteCode == 'test-khatm' || inviteCode.startsWith('test-')) {
      return Success(
        KhatmTestData.releaseSlot(
          inviteCode,
          slotId: slotId,
          unitNumber: unitNumber,
        ),
      );
    }
    try {
      final campaign = await _remoteDataSource.releaseSlot(
        inviteCode,
        slotId: slotId,
        unitNumber: unitNumber,
      );
      return Success(campaign);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(message: 'خطا در آزادسازی سهم: $e', stackTrace: stackTrace),
      );
    }
  }

  @override
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
  }) async {
    try {
      final payload = <String, dynamic>{
        'title': title,
        'unit_type': unitType,
        'is_public': isPublic,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'target_surah_id': ?targetSurah,
        'target_units': ?targetCount,
        'category_id': ?categoryId,
        if (deadline != null && deadline.isNotEmpty) 'deadline': deadline,
        'publish_to_topic_id': ?topicId,
      };

      final campaign = await _remoteDataSource.createCampaign(payload);
      return Success(campaign);
    } on DioException catch (e, stackTrace) {
      return Error(_handleDioError(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در ایجاد ختم گروهی: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<GroupKhatmCategory>, Failure>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      if (categories.isEmpty) {
        return Success(KhatmTestData.defaultCategories);
      }
      return Success(categories);
    } catch (_) {
      return Success(KhatmTestData.defaultCategories);
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> syncPersonalPlans({
    required List<Map<String, dynamic>> plans,
    String? lastSyncedAt,
  }) async {
    try {
      final res = await _remoteDataSource.syncPersonalPlans(
        plans: plans,
        lastSyncedAt: lastSyncedAt,
      );
      return Success(res);
    } on DioException catch (e, st) {
      return Error(_handleDioError(e, st));
    } catch (e, st) {
      return Error(
        Failure(message: 'خطا در همگام‌سازی ابری ختم‌ها: $e', stackTrace: st),
      );
    }
  }

  @override
  Future<List<KhatmPlan>> getLocalPlans() async {
    return _localDataSource.getAllPlans();
  }

  @override
  Future<void> saveLocalPlan(KhatmPlan plan) async {
    await _localDataSource.savePlan(plan);
  }

  @override
  Future<void> deleteLocalPlan(String planId) async {
    await _localDataSource.deletePlan(planId);
  }
}
