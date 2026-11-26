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
  final bool isLoadingMorePublic;
  final int publicPage;
  final int publicTotalCount;
  final bool publicHasMore;
  final bool isLoadingMy;
  final bool isLoadingMoreMy;
  final int myPage;
  final int myTotalCount;
  final bool myHasMore;
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
    this.isLoadingMorePublic = false,
    this.publicPage = 1,
    this.publicTotalCount = 0,
    this.publicHasMore = false,
    this.isLoadingMy = false,
    this.isLoadingMoreMy = false,
    this.myPage = 1,
    this.myTotalCount = 0,
    this.myHasMore = false,
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
    bool? isLoadingMorePublic,
    int? publicPage,
    int? publicTotalCount,
    bool? publicHasMore,
    bool? isLoadingMy,
    bool? isLoadingMoreMy,
    int? myPage,
    int? myTotalCount,
    bool? myHasMore,
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
      isLoadingMorePublic: isLoadingMorePublic ?? this.isLoadingMorePublic,
      publicPage: publicPage ?? this.publicPage,
      publicTotalCount: publicTotalCount ?? this.publicTotalCount,
      publicHasMore: publicHasMore ?? this.publicHasMore,
      isLoadingMy: isLoadingMy ?? this.isLoadingMy,
      isLoadingMoreMy: isLoadingMoreMy ?? this.isLoadingMoreMy,
      myPage: myPage ?? this.myPage,
      myTotalCount: myTotalCount ?? this.myTotalCount,
      myHasMore: myHasMore ?? this.myHasMore,
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
  static const int defaultPageSize = 10;

  final IKhatmRepository _repository;

  GroupKhatmListController(this._repository) : super(const GroupKhatmListState()) {
    init();
  }

  List<GroupKhatmCampaign> _mergeUniqueCampaigns(
    List<GroupKhatmCampaign> existing,
    List<GroupKhatmCampaign> incoming,
  ) {
    final seenIds = existing.map((c) => c.id).toSet();
    return [
      ...existing,
      ...incoming.where((c) => seenIds.add(c.id)),
    ];
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

    final result = await _repository.getCampaignsPage(
      categoryId: state.selectedCategoryId,
      unitType: state.selectedUnitType,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      page: 1,
      pageSize: defaultPageSize,
    );

    result.when(
      (pageData) => state = state.copyWith(
        publicCampaigns: pageData.items,
        publicPage: 1,
        publicTotalCount: pageData.totalCount,
        publicHasMore: pageData.hasNext,
        isLoadingPublic: false,
        isLoadingMorePublic: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingPublic: false,
        isLoadingMorePublic: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> loadMorePublicCampaigns() async {
    if (!state.publicHasMore ||
        state.isLoadingPublic ||
        state.isLoadingMorePublic) {
      return;
    }

    final nextPage = state.publicPage + 1;
    state = state.copyWith(isLoadingMorePublic: true);

    final result = await _repository.getCampaignsPage(
      categoryId: state.selectedCategoryId,
      unitType: state.selectedUnitType,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      page: nextPage,
      pageSize: defaultPageSize,
    );

    result.when(
      (pageData) => state = state.copyWith(
        publicCampaigns: _mergeUniqueCampaigns(
          state.publicCampaigns,
          pageData.items,
        ),
        publicPage: nextPage,
        publicTotalCount: pageData.totalCount,
        publicHasMore: pageData.hasNext,
        isLoadingMorePublic: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingMorePublic: false,
        errorMessage: failure.message,
      ),
    );
  }

  Future<void> loadMyCampaigns({bool refresh = false}) async {
    if (!refresh && state.myCampaigns.isNotEmpty && state.isLoadingMy) return;
    state = state.copyWith(isLoadingMy: true);

    final result = await _repository.getMyCampaignsPage(
      tab: 'all',
      page: 1,
      pageSize: defaultPageSize,
    );
    result.when(
      (pageData) => state = state.copyWith(
        myCampaigns: pageData.items,
        myPage: 1,
        myTotalCount: pageData.totalCount,
        myHasMore: pageData.hasNext,
        isLoadingMy: false,
        isLoadingMoreMy: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingMy: false,
        isLoadingMoreMy: false,
      ),
    );
  }

  Future<void> loadMoreMyCampaigns() async {
    if (!state.myHasMore || state.isLoadingMy || state.isLoadingMoreMy) return;

    final nextPage = state.myPage + 1;
    state = state.copyWith(isLoadingMoreMy: true);

    final result = await _repository.getMyCampaignsPage(
      tab: 'all',
      page: nextPage,
      pageSize: defaultPageSize,
    );
    result.when(
      (pageData) => state = state.copyWith(
        myCampaigns: _mergeUniqueCampaigns(state.myCampaigns, pageData.items),
        myPage: nextPage,
        myTotalCount: pageData.totalCount,
        myHasMore: pageData.hasNext,
        isLoadingMoreMy: false,
      ),
      (failure) => state = state.copyWith(
        isLoadingMoreMy: false,
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
