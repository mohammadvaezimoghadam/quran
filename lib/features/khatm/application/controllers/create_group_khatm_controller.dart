import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_category.dart';
import '../../domain/entities/khatm_enums.dart';
import '../../domain/repositories/i_khatm_repository.dart';
import '../../infrastructure/repositories/khatm_repository_impl.dart';

class CreateGroupKhatmState {
  final String title;
  final GroupKhatmUnitType unitType;
  final int? targetSurah; // 1-114
  final int targetCount; // e.g. 100 for Surah unit
  final int? selectedCategoryId;
  final List<GroupKhatmCategory> categories;
  final String? description;
  final DateTime? deadline;
  final bool isPublic;
  final int? topicId;
  final bool isSubmitting;
  final bool isLoadingCategories;
  final String? errorMessage;
  final String? errorCode;

  const CreateGroupKhatmState({
    this.title = '',
    this.unitType = GroupKhatmUnitType.juz,
    this.targetSurah,
    this.targetCount = 100,
    this.selectedCategoryId,
    this.categories = const [],
    this.description,
    this.deadline,
    this.isPublic = true,
    this.topicId,
    this.isSubmitting = false,
    this.isLoadingCategories = false,
    this.errorMessage,
    this.errorCode,
  });

  factory CreateGroupKhatmState.initial() {
    final now = DateTime.now();
    final defaultDeadline = DateTime(now.year, now.month, now.day + 30, 23, 59, 59);
    return CreateGroupKhatmState(deadline: defaultDeadline);
  }

  CreateGroupKhatmState copyWith({
    String? title,
    GroupKhatmUnitType? unitType,
    int? targetSurah,
    int? targetCount,
    int? selectedCategoryId,
    bool clearCategory = false,
    List<GroupKhatmCategory>? categories,
    String? description,
    bool clearDescription = false,
    DateTime? deadline,
    bool clearDeadline = false,
    bool? isPublic,
    int? topicId,
    bool? isSubmitting,
    bool? isLoadingCategories,
    String? errorMessage,
    String? errorCode,
  }) {
    return CreateGroupKhatmState(
      title: title ?? this.title,
      unitType: unitType ?? this.unitType,
      targetSurah: targetSurah ?? this.targetSurah,
      targetCount: targetCount ?? this.targetCount,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      categories: categories ?? this.categories,
      description: clearDescription ? null : (description ?? this.description),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      isPublic: isPublic ?? this.isPublic,
      topicId: topicId ?? this.topicId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}

final createGroupKhatmControllerProvider = StateNotifierProvider.autoDispose<
    CreateGroupKhatmController, CreateGroupKhatmState>((ref) {
  final repository = ref.watch(khatmRepositoryProvider);
  return CreateGroupKhatmController(repository);
});

class CreateGroupKhatmController extends StateNotifier<CreateGroupKhatmState> {
  final IKhatmRepository _repository;

  CreateGroupKhatmController(this._repository)
      : super(CreateGroupKhatmState.initial()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoadingCategories: true);
    final result = await _repository.getCategories();
    result.when(
      (cats) => state = state.copyWith(
        categories: cats,
        isLoadingCategories: false,
        selectedCategoryId: null,
      ),
      (failure) => state = state.copyWith(isLoadingCategories: false),
    );
  }

  void setTitle(String value) {
    state = state.copyWith(title: value, errorMessage: null);
  }

  void setUnitType(GroupKhatmUnitType unit) {
    state = state.copyWith(
      unitType: unit,
      targetSurah: unit == GroupKhatmUnitType.surah ? (state.targetSurah ?? 36) : null,
    );
  }

  void setTargetSurah(int surahNumber, {int? count}) {
    state = state.copyWith(
      targetSurah: surahNumber,
      targetCount: count ?? state.targetCount,
    );
  }

  void setTargetCount(int count) {
    state = state.copyWith(targetCount: count.clamp(1, 100000));
  }

  void setCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void setDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      state = state.copyWith(clearDescription: true);
    } else {
      state = state.copyWith(description: value.trim());
    }
  }

  void setDeadline(DateTime? value) {
    if (value == null) {
      state = state.copyWith(clearDeadline: true);
    } else {
      final endOfDay = DateTime(value.year, value.month, value.day, 23, 59, 59);
      state = state.copyWith(deadline: endOfDay);
    }
  }

  void setIsPublic(bool value) {
    state = state.copyWith(isPublic: value);
  }

  void setTopicId(int? id) {
    state = state.copyWith(topicId: id);
  }

  /// Create Campaign and return the created campaign model for post-creation flow
  Future<GroupKhatmCampaign?> submit() async {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'لطفاً نیت ختم را وارد کنید');
      return null;
    }

    if (state.unitType == GroupKhatmUnitType.surah && (state.targetSurah == null || state.targetSurah! < 1)) {
      state = state.copyWith(errorMessage: 'لطفاً سوره مورد نظر را انتخاب کنید');
      return null;
    }

    final deadline = state.deadline;
    if (deadline != null && deadline.isBefore(DateTime.now())) {
      state = state.copyWith(errorMessage: 'مهلت زمانی ختم نمی‌تواند در گذشته باشد');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await _repository.createCampaign(
      title: state.title.trim(),
      description: state.description,
      unitType: state.unitType.serverValue,
      targetSurah: state.targetSurah,
      targetCount: state.unitType == GroupKhatmUnitType.surah ? state.targetCount : null,
      categoryId: state.selectedCategoryId,
      deadline: state.deadline?.toUtc().toIso8601String(),
      isPublic: state.isPublic,
      topicId: state.topicId,
    );

    return result.when(
      (campaign) {
        state = state.copyWith(isSubmitting: false);
        return campaign;
      },
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        );
        return null;
      },
    );
  }
}
