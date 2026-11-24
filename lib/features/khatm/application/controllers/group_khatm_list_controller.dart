import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/group_khatm_campaign.dart';
import '../../domain/entities/group_khatm_category.dart';
import '../../domain/repositories/i_khatm_repository.dart';
import '../../infrastructure/repositories/khatm_repository_impl.dart';

class GroupKhatmListState {
  final List<GroupKhatmCampaign> publicCampaigns;
  final List<GroupKhatmCampaign> myCampaigns;
  final List<GroupKhatmCategory> categories;
  final int? selectedCategoryId;
  final String? selectedUnitType; // 'juz', 'hizb', 'surah', or null for all
  final String searchQuery;
  final bool isLoadingPublic;
  final bool isLoadingMy;
  final bool isLoadingCategories;
  final String? errorMessage;

  const GroupKhatmListState({
    this.publicCampaigns = const [],
    this.myCampaigns = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.selectedUnitType,
    this.searchQuery = '',
    this.isLoadingPublic = false,
    this.isLoadingMy = false,
    this.isLoadingCategories = false,
    this.errorMessage,
  });

  GroupKhatmListState copyWith({
    List<GroupKhatmCampaign>? publicCampaigns,
    List<GroupKhatmCampaign>? myCampaigns,
    List<GroupKhatmCategory>? categories,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? selectedUnitType,
    bool clearUnitType = false,
    String? searchQuery,
    bool? isLoadingPublic,
    bool? isLoadingMy,
    bool? isLoadingCategories,
    String? errorMessage,
  }) {
    return GroupKhatmListState(
      publicCampaigns: publicCampaigns ?? this.publicCampaigns,
      myCampaigns: myCampaigns ?? this.myCampaigns,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedUnitType: clearUnitType ? null : (selectedUnitType ?? this.selectedUnitType),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingPublic: isLoadingPublic ?? this.isLoadingPublic,
      isLoadingMy: isLoadingMy ?? this.isLoadingMy,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      errorMessage: errorMessage,
    );
  }
}

final groupKhatmListControllerProvider =
    StateNotifierProvider<GroupKhatmListController, GroupKhatmListState>((ref) {
  final repository = ref.watch(khatmRepositoryProvider);
  return GroupKhatmListController(repository);
});

class GroupKhatmListController extends StateNotifier<GroupKhatmListState> {
  final IKhatmRepository _repository;

  GroupKhatmListController(this._repository) : super(const GroupKhatmListState()) {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      loadCategories(),
      loadPublicCampaigns(),
      loadMyCampaigns(),
    ]);
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoadingCategories: true);
    final result = await _repository.getCategories();
    result.when(
      (categories) => state = state.copyWith(
        categories: categories,
        isLoadingCategories: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingCategories: false,
      ),
    );
  }

  Future<void> loadPublicCampaigns({bool refresh = false}) async {
    if (!refresh && state.publicCampaigns.isNotEmpty && state.isLoadingPublic) return;
    state = state.copyWith(isLoadingPublic: true, errorMessage: null);

    final result = await _repository.getCampaigns(
      categoryId: state.selectedCategoryId,
      unitType: state.selectedUnitType,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    );

    result.when(
      (campaigns) => state = state.copyWith(
        publicCampaigns: campaigns,
        isLoadingPublic: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingPublic: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> loadMyCampaigns({bool refresh = false}) async {
    if (!refresh && state.myCampaigns.isNotEmpty && state.isLoadingMy) return;
    state = state.copyWith(isLoadingMy: true);

    final result = await _repository.getMyCampaigns(tab: 'all');
    result.when(
      (campaigns) => state = state.copyWith(
        myCampaigns: campaigns,
        isLoadingMy: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingMy: false,
      ),
    );
  }

  void selectCategory(int? categoryId) {
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
    loadPublicCampaigns(refresh: true);
  }

  void selectUnitType(String? unitType) {
    if (state.selectedUnitType == unitType) {
      state = state.copyWith(clearUnitType: true);
    } else {
      state = state.copyWith(selectedUnitType: unitType);
    }
    loadPublicCampaigns(refresh: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadPublicCampaigns(refresh: true);
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadPublicCampaigns(refresh: true),
      loadMyCampaigns(refresh: true),
      loadCategories(),
    ]);
  }
}
